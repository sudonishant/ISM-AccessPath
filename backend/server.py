#!/usr/bin/env python3
"""
AccessPath - IIT (ISM) Dhanbad Accessibility Backend Server
Provides real-time cross-device synchronization for places, reviews,
floor status, and campus admin notices.
"""

import json
import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
DATA_FILE = os.path.join(DATA_DIR, "places.json")
USERS_FILE = os.path.join(DATA_DIR, "users.json")
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
