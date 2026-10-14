import json
import os
import sys
import time
from datetime import datetime
from http.server import BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

# In-memory storage for serverless runtime fallback + file fallback
DATA_DIR = "/tmp/accesspath_data"
os.makedirs(DATA_DIR, exist_ok=True)
DATA_FILE = os.path.join(DATA_DIR, "places.json")
USERS_FILE = os.path.join(DATA_DIR, "users.json")
NOTIFICATIONS_FILE = os.path.join(DATA_DIR, "notifications.json")
HAZARDS_FILE = os.path.join(DATA_DIR, "hazards.json")

# In-memory store persistent across warm lambda invocations
_CACHE = {
    "places": [],
    "users": [],
    "notifications": [],
    "hazards": []
}

def load_data(filepath, key):
    if _CACHE.get(key):
        return _CACHE[key]
    if os.path.exists(filepath):
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
                _CACHE[key] = data
                return data
        except Exception:
            pass
    return []

def save_data(filepath, key, data):
    _CACHE[key] = data
    try:
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

class handler(BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")

    def do_OPTIONS(self):
        self.send_response(204)
        self._send_cors_headers()
        self.end_headers()

    def _read_json_body(self):
        length = int(self.headers.get("Content-Length", 0))
        if length > 0:
            body = self.rfile.read(length).decode("utf-8")
            return json.loads(body)
        return {}

    def _send_json_response(self, status_code, data):
        self.send_response(status_code)
        self._send_cors_headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode("utf-8"))

    def _get_path(self):
        parsed = urlparse(self.path)
        qs = parse_qs(parsed.query)
        if "path" in qs and qs["path"]:
            candidate = qs["path"][0]
            clean = candidate.split("?")[0].rstrip("/")
            return clean if clean else "/"

        forwarded = self.headers.get("x-forwarded-uri") or self.headers.get("x-matched-path")
        target = forwarded if forwarded else parsed.path
        clean = target.split("?")[0].rstrip("/")
        return clean if clean else "/"

    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        req_path = self._get_path()

        # Health check & root info
        if req_path in ["/", "/api", "/api/health", "/health", "/api/index.py"]:
            self._send_json_response(200, {
                "status": "healthy",
                "campus": "IIT (ISM) Dhanbad",
                "platform": "Vercel Serverless Python",
                "service": "AccessPath Backend Engine v2.0",
                "detected_path": req_path
            })
            return

        # Places & Reviews sync
        if req_path in ["/api/places", "/places"]:
            places = load_data(DATA_FILE, "places")
            self._send_json_response(200, {
                "status": "success",
                "count": len(places),
                "places": places
            })
            return

        # Users list
        if req_path in ["/api/users", "/users"]:
            users = load_data(USERS_FILE, "users")
            self._send_json_response(200, {
                "status": "success",
                "count": len(users),
                "users": users
            })
            return

        # Notifications list (filtered specifically by user)
        if req_path in ["/api/notifications", "/notifications"]:
            parsed = urlparse(self.path)
            qs = parse_qs(parsed.query)
            user_param = qs.get("user", [None])[0]
            all_notifs = load_data(NOTIFICATIONS_FILE, "notifications")
            if user_param:
                u_clean = user_param.strip().lower()
                user_notifs = [n for n in all_notifs if n.get("targetUser", "").strip().lower() == u_clean or n.get("targetUserId", "").strip().lower() == u_clean]
            else:
                user_notifs = all_notifs
            self._send_json_response(200, {
                "status": "success",
                "count": len(user_notifs),
                "notifications": user_notifs
            })
            return

        # Hazards & Animal Detection beacons
        if req_path in ["/api/hazards", "/hazards"]:
            hazards = load_data(HAZARDS_FILE, "hazards")
            self._send_json_response(200, {
                "status": "success",
                "count": len(hazards),
                "hazards": hazards
            })
            return

        self._send_json_response(404, {
            "error": "Endpoint not found",
            "path": req_path,
            "raw_path": self.path,
            "x-forwarded-uri": self.headers.get("x-forwarded-uri"),
            "x-matched-path": self.headers.get("x-matched-path")
        })

    def do_POST(self):
        req_path = self._get_path()

        # Places full sync
        if req_path in ["/api/places/sync", "/places/sync"]:
            payload = self._read_json_body()
            incoming = payload.get("places", [])
            existing = load_data(DATA_FILE, "places")
            
            if not existing:
                save_data(DATA_FILE, "places", incoming)
                merged = incoming
            else:
                places_map = {p["id"]: p for p in existing}
                for p in incoming:
                    pid = p["id"]
                    if pid in places_map:
                        seen_users = {f"{r.get('u')}_{r.get('t')}" for r in places_map[pid].get("rv", [])}
                        for r in p.get("rv", []):
                            key = f"{r.get('u')}_{r.get('t')}"
                            if key not in seen_users:
                                places_map[pid].setdefault("rv", []).append(r)
                                seen_users.add(key)
                        if "lo" in p:
                            places_map[pid]["lo"] = p["lo"]
                        if "an" in p:
                            places_map[pid]["an"] = p["an"]
                    else:
                        places_map[pid] = p
                merged = list(places_map.values())
                save_data(DATA_FILE, "places", merged)

            self._send_json_response(200, {
                "status": "synchronized",
                "count": len(merged),
                "places": merged
            })
            return

        # Single Review Submit
        if req_path in ["/api/reviews", "/reviews"]:
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            review = payload.get("review")

            if not place_id or not review:
                self._send_json_response(400, {"error": "Missing placeId or review"})
                return

            places = load_data(DATA_FILE, "places")
            found = False
            for p in places:
                if p["id"] == place_id:
                    p.setdefault("rv", []).append(review)
                    found = True
                    break

            if found:
                save_data(DATA_FILE, "places", places)
                self._send_json_response(200, {"status": "review_added", "placeId": place_id})
            else:
                self._send_json_response(404, {"error": f"Place {place_id} not found"})
            return

        # Upvote / Like Review with targeted notification specifically to author
        if req_path in ["/api/reviews/like", "/reviews/like"]:
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            review_user = payload.get("reviewUser")
            liked_by = payload.get("likedBy", "A fellow student")
            place_name = payload.get("placeName", "Campus Venue")

            places = load_data(DATA_FILE, "places")
            found = False
            for p in places:
                if p["id"] == place_id:
                    for r in p.get("rv", []):
                        if r.get("u") == review_user:
                            r["up"] = r.get("up", 0) + 1
                            found = True
                            break
                    if found:
                        break
            if found:
                save_data(DATA_FILE, "places", places)

            # Generate targeted notification ONLY if review author is known and not liking their own review
            notif = None
            if review_user and review_user.lower() != liked_by.lower():
                notifications = load_data(NOTIFICATIONS_FILE, "notifications")
                notif = {
                    "id": f"notif_{int(time.time() * 1000)}",
                    "targetUser": review_user,
                    "fromUser": liked_by,
                    "title": "Review Upvoted! 👍",
                    "message": f"{liked_by} liked your accessibility feedback on {place_name}!",
                    "placeId": place_id,
                    "time": datetime.utcnow().isoformat() + "Z",
                    "isRead": False
                }
                notifications.insert(0, notif)
                save_data(NOTIFICATIONS_FILE, "notifications", notifications)

            self._send_json_response(200, {
                "status": "liked",
                "placeId": place_id,
                "notificationCreated": notif is not None,
                "notification": notif
            })
            return

        # Mark Notification(s) as Read
        if req_path in ["/api/notifications/read", "/notifications/read"]:
            payload = self._read_json_body()
            user = payload.get("user", "").strip().lower()
            notif_id = payload.get("id")
            notifications = load_data(NOTIFICATIONS_FILE, "notifications")
            for n in notifications:
                if not user or n.get("targetUser", "").strip().lower() == user:
                    if not notif_id or notif_id == "all" or n.get("id") == notif_id:
                        n["isRead"] = True
            save_data(NOTIFICATIONS_FILE, "notifications", notifications)
            self._send_json_response(200, {"status": "success", "message": "Marked read"})
            return

        # Add new venue / place
        if req_path in ["/api/places", "/places"]:
            new_place = self._read_json_body()
            places = load_data(DATA_FILE, "places")
            places.append(new_place)
            save_data(DATA_FILE, "places", places)
            self._send_json_response(201, {"status": "place_created", "place": new_place})
            return

        # Admin: Update lift status
        if req_path in ["/api/admin/lift", "/admin/lift"]:
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            is_operational = payload.get("isLiftOperational", True)

            places = load_data(DATA_FILE, "places")
            for p in places:
                if p["id"] == place_id:
                    p["lo"] = is_operational
                    break
            save_data(DATA_FILE, "places", places)
            self._send_json_response(200, {"status": "lift_status_updated", "placeId": place_id, "isOperational": is_operational})
            return

        # Admin: Update notice
        if req_path in ["/api/admin/notice", "/admin/notice"]:
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            notice = payload.get("adminNotice")

            places = load_data(DATA_FILE, "places")
            for p in places:
                if p["id"] == place_id:
                    p["an"] = notice
                    break
            save_data(DATA_FILE, "places", places)
            self._send_json_response(200, {"status": "notice_updated", "placeId": place_id, "adminNotice": notice})
            return

        # User Registration
        if req_path in ["/api/users", "/users"]:
            user = self._read_json_body()
            users = load_data(USERS_FILE, "users")
            users = [u for u in users if u.get("id") != user.get("id")]
            users.append(user)
            save_data(USERS_FILE, "users", users)
            self._send_json_response(200, {"status": "user_saved", "user": user})
            return

        # Broadcast safety hazard beacon (animal or obstacle)
        if req_path in ["/api/hazards", "/hazards"]:
            hazard = self._read_json_body()
            hazards = load_data(HAZARDS_FILE, "hazards")
            hazards = [h for h in hazards if h.get("id") != hazard.get("id")]
            hazards.insert(0, hazard)
            hazards = hazards[:50]
            save_data(HAZARDS_FILE, "hazards", hazards)

            # Auto-generate campus safety broadcast notification for students
            notifs = load_data(NOTIFICATIONS_FILE, "notifications")
            threat_icon = "🐕" if hazard.get("threatClass") == "dog" else ("🐒" if hazard.get("threatClass") == "monkey" else ("🐂" if hazard.get("threatClass") == "cattle" else "⚠️"))
            new_notif = {
                "id": f"notif_hazard_{int(time.time()*1000)}",
                "targetUser": "all",
                "fromUser": hazard.get("reportedBy", "Campus Safety Patrol"),
                "title": f"{threat_icon} Safety Alert: {hazard.get('title')}",
                "message": f"{hazard.get('description', 'Detected on campus path.')} Pinned on Map.",
                "placeId": hazard.get("id"),
                "time": datetime.utcnow().isoformat(),
                "isRead": False
            }
            notifs.insert(0, new_notif)
            save_data(NOTIFICATIONS_FILE, "notifications", notifs[:100])

            self._send_json_response(201, {
                "status": "hazard_broadcasted",
                "hazard": hazard
            })
            return

        self._send_json_response(404, {
            "error": "Endpoint not found",
            "path": req_path,
            "raw_path": self.path,
            "x-forwarded-uri": self.headers.get("x-forwarded-uri"),
            "x-matched-path": self.headers.get("x-matched-path")
        })
