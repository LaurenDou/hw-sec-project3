import os
import time
from flask import Flask, request, jsonify
from sqlcipher3 import dbapi2 as sqlite

app = Flask(__name__)
DB_FILE = "fithealth.db"
SQLCIPHER_KEY = os.environ.get("SQLCIPHER_KEY")

if not SQLCIPHER_KEY:
    raise RuntimeError("SQLCIPHER_KEY environment variable not set")

# ------------------ DB Init -----------------------------------

def init_db() -> None:
    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        conn.execute("PRAGMA cipher_migrate;")
        conn.execute("""
            CREATE TABLE IF NOT EXISTS records (
                user_id        TEXT    NOT NULL PRIMARY KEY,
                timestamp      INTEGER NOT NULL,
                heart_rate     INTEGER NOT NULL,
                blood_pressure TEXT    NOT NULL,
                notes          BLOB
            )
        """)

# ------------------ REST API ----------------------------------

@app.post("/record")
def insert_record():
    data = request.get_json()
    user_id = data["user_id"]
    timestamp = int(time.time())
    heart_rate = data["heart_rate"]
    blood_pressure = data["blood_pressure"]
    notes = data.get("notes", "")

    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        conn.execute("PRAGMA cipher_migrate;")
        conn.execute(
            "INSERT OR REPLACE INTO records VALUES (?, ?, ?, ?, ?)",
            (user_id, timestamp, heart_rate, blood_pressure, notes)
        )

    return jsonify({"status": "success"}), 200

@app.get("/record/<user_id>")
def get_record(user_id):
    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        conn.execute("PRAGMA cipher_migrate;")
        row = conn.execute(
            "SELECT * FROM records WHERE user_id = ?", (user_id,)
        ).fetchone()

    if not row:
        return jsonify({"error": "user not found"}), 404

    return jsonify({
        "user_id": row[0],
        "timestamp": row[1],
        "heart_rate": row[2],
        "blood_pressure": row[3],
        "notes": row[4],
    })

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
