from flask import Flask, request, jsonify
import sqlite3
import time

app = Flask(__name__)
DB_FILE = "fithealth.db"

# Create table if it doesn't exist
def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS records (
                user_id TEXT NOT NULL PRIMARY KEY,
                timestamp INTEGER NOT NULL,
                heart_rate INTEGER NOT NULL,
                blood_pressure TEXT NOT NULL,
                notes BLOB
            )
        ''')

@app.route("/record", methods=["POST"])
def insert_record():
    data = request.json
    with sqlite3.connect(DB_FILE) as conn:
        conn.execute(
            "INSERT OR REPLACE INTO records VALUES (?, ?, ?, ?, ?)",
            (data["user_id"], int(time.time()), data["heart_rate"], data["blood_pressure"], data.get("notes", b"")),
        )
    return jsonify({"status": "ok"})

@app.route("/record/<user_id>", methods=["GET"])
def fetch_record(user_id):
    with sqlite3.connect(DB_FILE) as conn:
        cur = conn.execute(
            "SELECT * FROM records WHERE user_id=? ORDER BY timestamp DESC LIMIT 1", (user_id,)
        )
        row = cur.fetchone()
    if not row:
        return jsonify({"error": "Not found"}), 404
    return jsonify(dict(zip(["user_id", "timestamp", "heart_rate", "blood_pressure", "notes"], row)))

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
