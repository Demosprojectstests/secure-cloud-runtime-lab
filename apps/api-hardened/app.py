import ipaddress
import sqlite3
from urllib.parse import urlparse

from flask import Flask, request

app = Flask(__name__)
DB = "/tmp/lab-hard.db"
ALLOWED_HOSTS = {"example.com"}

def db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    return conn

def seed():
    c = db()
    c.execute(
        "CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY, user_id INTEGER, item TEXT)"
    )
    c.execute("DELETE FROM orders")
    c.executemany(
        "INSERT INTO orders (id, user_id, item) VALUES (?, ?, ?)",
        [(1, 1, "alice-secret"), (2, 2, "bob-secret"), (3, 2, "bob-invoice")],
    )
    c.commit()
    c.close()

def current_user_id():
    raw = request.headers.get("X-User-Id", "1")
    try:
        return int(raw)
    except ValueError:
        return None

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/orders/<int:order_id>")
def get_order(order_id):
    uid = current_user_id()
    if uid is None:
        return {"error": "unauthorized"}, 401
    c = db()
    row = c.execute(
        "SELECT * FROM orders WHERE id = ? AND user_id = ?",
        (order_id, uid),
    ).fetchone()
    c.close()
    if not row:
        return {"error": "not found"}, 404
    return dict(row)

@app.get("/search")
def search():
    q = request.args.get("q", "")
    c = db()
    rows = c.execute(
        "SELECT * FROM orders WHERE item LIKE ?",
        (f"%{q}%",),
    ).fetchall()
    c.close()
    return [dict(r) for r in rows]

def blocked_host(hostname: str) -> bool:
    if hostname in {"169.254.169.254", "metadata.google.internal", "localhost"}:
        return True
    try:
        ip = ipaddress.ip_address(hostname)
        return bool(
            ip.is_private
            or ip.is_loopback
            or ip.is_link_local
            or ip.is_reserved
            or ip.is_multicast
        )
    except ValueError:
        return hostname not in ALLOWED_HOSTS

@app.post("/fetch")
def fetch():
    payload = request.get_json(force=True, silent=True) or {}
    url = payload.get("url", "")
    parsed = urlparse(url)
    if parsed.scheme not in {"https"}:
        return {"error": "scheme not allowed"}, 400
    host = parsed.hostname or ""
    if blocked_host(host):
        return {"error": "host not allowed"}, 400
    return {"status": "accepted", "note": "would fetch allowlisted HTTPS only"}

if __name__ == "__main__":
    seed()
    app.run(host="127.0.0.1", port=8081)
