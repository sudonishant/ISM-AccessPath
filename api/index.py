import json
import os
import sys
from http.server import BaseHTTPRequestHandler

# In-memory storage for serverless runtime fallback + file fallback
DATA_DIR = "/tmp/accesspath_data"
os.makedirs(DATA_DIR, exist_ok=True)
DATA_FILE = os.path.join(DATA_DIR, "places.json")
USERS_FILE = os.path.join(DATA_DIR, "users.json")

# In-memory store persistent across warm lambda invocations
_CACHE = {
    "places": [],
    "users": []
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
        forwarded = self.headers.get("x-forwarded-uri") or self.headers.get("x-matched-path")
        target = forwarded if forwarded else self.path
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

        self._send_json_response(404, {
            "error": "Endpoint not found",
            "path": req_path,
            "raw_path": self.path,
            "x-forwarded-uri": self.headers.get("x-forwarded-uri"),
            "x-matched-path": self.headers.get("x-matched-path")
        })
