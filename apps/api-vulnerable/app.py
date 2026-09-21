"""INTENTIONAL VULNERABILITIES — local lab only. Do not expose."""
import sqlite3
from flask import Flask, request, jsonify
import urllib.request

app = Flask(__name__)
DB = "/tmp/lab-vuln.db"

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

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/orders/<int:order_id>")
def get_order(order_id):
    # BOLA: no ownership check
    c = db()
    row = c.execute("SELECT * FROM orders WHERE id = ?", (order_id,)).fetchone()
    c.close()
    if not row:
        return {"error": "not found"}, 404
    return dict(row)

@app.get("/search")
def search():
    q = request.args.get("q", "")
    # SQLi: string concat
    c = db()
    rows = c.execute(f"SELECT * FROM orders WHERE item LIKE '%{q}%'").fetchall()
    c.close()
    return [dict(r) for r in rows]

@app.post("/fetch")
def fetch():
    url = request.get_json(force=True, silent=True) or {}
    url = url.get("url", "")
    # SSRF: fetches attacker-controlled URL
    try:
        with urllib.request.urlopen(url, timeout=3) as resp:
            body = resp.read(512).decode("utf-8", errors="replace")
        return {"status": resp.status, "body": body}
    except Exception as exc:
        return {"error": str(exc)}, 400

if __name__ == "__main__":
    seed()
    app.run(host="127.0.0.1", port=8080)
