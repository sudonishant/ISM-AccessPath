#!/usr/bin/env python3
"""
AccessPath - IIT (ISM) Dhanbad Accessibility Backend Server
Provides real-time cross-device synchronization for places, reviews,
floor status, and campus admin notices.
"""

import json
import os
import sys
import time
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
DATA_FILE = os.path.join(DATA_DIR, "places.json")
USERS_FILE = os.path.join(DATA_DIR, "users.json")
NOTIFICATIONS_FILE = os.path.join(DATA_DIR, "notifications.json")
HAZARDS_FILE = os.path.join(DATA_DIR, "hazards.json")
PORT = 8080

os.makedirs(DATA_DIR, exist_ok=True)

def load_data(filepath, default):
    if os.path.exists(filepath):
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"[Error loading {filepath}]: {e}")
    return default

def save_data(filepath, data):
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

class SyncHandler(BaseHTTPRequestHandler):
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

    def do_GET(self):
        # APK Direct Download Endpoint
        if self.path in ["/download/apk", "/api/download/apk", "/AccessPath_IIT_ISM_Dhanbad.apk"]:
            apk_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "AccessPath_IIT_ISM_Dhanbad.apk")
            if os.path.exists(apk_path):
                file_size = os.path.getsize(apk_path)
                self.send_response(200)
                self._send_cors_headers()
                self.send_header("Content-Type", "application/vnd.android.package-archive")
                self.send_header("Content-Disposition", 'attachment; filename="AccessPath_IIT_ISM_Dhanbad.apk"')
                self.send_header("Content-Length", str(file_size))
                self.end_headers()
                with open(apk_path, "rb") as f:
                    while chunk := f.read(65536):
                        self.wfile.write(chunk)
                return
            else:
                self._send_json_response(404, {"error": "APK file not found on server"})
                return

        # Health check
        if self.path == "/" or self.path == "/api/health":
            self._send_json_response(200, {
                "status": "healthy",
                "campus": "IIT (ISM) Dhanbad",
                "service": "AccessPath Sync Engine v1.0",
                "timestamp": str(os.path.getmtime(DATA_FILE)) if os.path.exists(DATA_FILE) else None
            })
            return

        # Places & Reviews sync
        if self.path == "/api/places":
            places = load_data(DATA_FILE, [])
            self._send_json_response(200, {
                "status": "success",
                "count": len(places),
                "places": places
            })
            return

        # Users list (for admin sync)
        if self.path == "/api/users":
            users = load_data(USERS_FILE, [])
            self._send_json_response(200, {
                "status": "success",
                "count": len(users),
                "users": users
            })
            return

        # Notifications list (filtered specifically by user)
        if self.path.startswith("/api/notifications"):
            parsed = urlparse(self.path)
            qs = parse_qs(parsed.query)
            user_param = qs.get("user", [None])[0]
            all_notifs = load_data(NOTIFICATIONS_FILE, [])
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
        if self.path == "/api/hazards":
            hazards = load_data(HAZARDS_FILE, [])
            self._send_json_response(200, {
                "status": "success",
                "count": len(hazards),
                "hazards": hazards
            })
            return

        self._send_json_response(404, {"error": "Endpoint not found"})

    def do_POST(self):
        # Replace or seed entire places collection
        if self.path == "/api/places/sync":
            payload = self._read_json_body()
            incoming = payload.get("places", [])
            existing = load_data(DATA_FILE, [])
            
            # Smart merge: keep newest reviews and status
            if not existing:
                save_data(DATA_FILE, incoming)
                merged = incoming
            else:
                # Map by ID
                places_map = {p["id"]: p for p in existing}
                for p in incoming:
                    pid = p["id"]
                    if pid in places_map:
                        # Merge reviews uniquely
                        seen_users = {f"{r.get('u')}_{r.get('t')}" for r in places_map[pid].get("rv", [])}
                        for r in p.get("rv", []):
                            key = f"{r.get('u')}_{r.get('t')}"
                            if key not in seen_users:
                                places_map[pid].setdefault("rv", []).append(r)
                                seen_users.add(key)
                        # Admin override
                        if "lo" in p:
                            places_map[pid]["lo"] = p["lo"]
                        if "an" in p:
                            places_map[pid]["an"] = p["an"]
                    else:
                        places_map[pid] = p
                merged = list(places_map.values())
                save_data(DATA_FILE, merged)

            self._send_json_response(200, {
                "status": "synchronized",
                "count": len(merged),
                "places": merged
            })
            return

        # Add single review to place
        if self.path == "/api/reviews":
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            review = payload.get("review")

            if not place_id or not review:
                self._send_json_response(400, {"error": "Missing placeId or review"})
                return

            places = load_data(DATA_FILE, [])
            found = False
            for p in places:
                if p["id"] == place_id:
                    p.setdefault("rv", []).append(review)
                    found = True
                    break

            if found:
                save_data(DATA_FILE, places)
                self._send_json_response(200, {"status": "review_added", "placeId": place_id})
            else:
                self._send_json_response(404, {"error": f"Place {place_id} not found"})
            return

        # Upvote / Like Review with targeted notification specifically to author
        if self.path == "/api/reviews/like":
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            review_user = payload.get("reviewUser")
            liked_by = payload.get("likedBy", "A fellow student")
            place_name = payload.get("placeName", "Campus Venue")

            places = load_data(DATA_FILE, [])
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
                save_data(DATA_FILE, places)

            notif = None
            if review_user and review_user.lower() != liked_by.lower():
                notifications = load_data(NOTIFICATIONS_FILE, [])
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
                save_data(NOTIFICATIONS_FILE, notifications)

            self._send_json_response(200, {
                "status": "liked",
                "placeId": place_id,
                "notificationCreated": notif is not None,
                "notification": notif
            })
            return

        # Mark Notification(s) as Read
        if self.path == "/api/notifications/read":
            payload = self._read_json_body()
            user = payload.get("user", "").strip().lower()
            notif_id = payload.get("id")
            notifications = load_data(NOTIFICATIONS_FILE, [])
            for n in notifications:
                if not user or n.get("targetUser", "").strip().lower() == user:
                    if not notif_id or notif_id == "all" or n.get("id") == notif_id:
                        n["isRead"] = True
            save_data(NOTIFICATIONS_FILE, notifications)
            self._send_json_response(200, {"status": "success", "message": "Marked read"})
            return

        # Add new custom place
        if self.path == "/api/places":
            new_place = self._read_json_body()
            places = load_data(DATA_FILE, [])
            places.append(new_place)
            save_data(DATA_FILE, places)
            self._send_json_response(201, {"status": "place_created", "place": new_place})
            return

        # Admin: Update lift status
        if self.path == "/api/admin/lift":
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            is_operational = payload.get("isLiftOperational", True)

            places = load_data(DATA_FILE, [])
            for p in places:
                if p["id"] == place_id:
                    p["lo"] = is_operational
                    break
            save_data(DATA_FILE, places)
            self._send_json_response(200, {"status": "lift_status_updated", "placeId": place_id, "isOperational": is_operational})
            return

        # Admin: Update campus advisory / notice
        if self.path == "/api/admin/notice":
            payload = self._read_json_body()
            place_id = payload.get("placeId")
            notice = payload.get("adminNotice")

            places = load_data(DATA_FILE, [])
            for p in places:
                if p["id"] == place_id:
                    p["an"] = notice
                    break
            save_data(DATA_FILE, places)
            self._send_json_response(200, {"status": "notice_updated", "placeId": place_id, "adminNotice": notice})
            return

        # User register / record
        if self.path == "/api/users":
            user = self._read_json_body()
            users = load_data(USERS_FILE, [])
            users = [u for u in users if u.get("id") != user.get("id")]
            users.append(user)
            save_data(USERS_FILE, users)
            self._send_json_response(200, {"status": "user_saved", "user": user})
            return

        # Broadcast safety hazard beacon (animal or obstacle)
        if self.path == "/api/hazards":
            hazard = self._read_json_body()
            hazards = load_data(HAZARDS_FILE, [])
            hazards = [h for h in hazards if h.get("id") != hazard.get("id")]
            hazards.insert(0, hazard)
            hazards = hazards[:50]
            save_data(HAZARDS_FILE, hazards)

            # Auto-generate campus safety broadcast notification for students
            notifs = load_data(NOTIFICATIONS_FILE, [])
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
            save_data(NOTIFICATIONS_FILE, notifs[:100])

            self._send_json_response(201, {
                "status": "hazard_broadcasted",
                "hazard": hazard
            })
            return

        self._send_json_response(404, {"error": "Endpoint not found"})

def run_server():
    server_address = ("0.0.0.0", PORT)
    httpd = HTTPServer(server_address, SyncHandler)
    print(f"🚀 AccessPath Sync Engine running on http://0.0.0.0:{PORT}")
    print(f"   - Local:    http://127.0.0.1:{PORT}")
    print(f"   - Emulator: http://10.0.2.2:{PORT}")
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down backend server.")
        httpd.server_close()

if __name__ == "__main__":
    run_server()
