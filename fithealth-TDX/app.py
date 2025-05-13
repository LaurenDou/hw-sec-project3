import os
import base64
import time
from flask import Flask, request, jsonify
from sqlcipher3 import dbapi2 as sqlite

app = Flask(__name__)
DB_FILE = "fithealth.db"

SQLCIPHER_KEY = os.environ.get("SQLCIPHER_KEY")
if not SQLCIPHER_KEY:
    raise RuntimeError("SQLCIPHER_KEY env-var not set")

# ----------------------------------------------------------------------
def init_db() -> None:
    """Create table if it doesn’t exist (runs once at container start)."""
    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        conn.execute("PRAGMA cipher_migrate;")
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS records (
                user_id        TEXT    NOT NULL PRIMARY KEY,
                timestamp      INTEGER NOT NULL,
                heart_rate     INTEGER NOT NULL,
                blood_pressure TEXT    NOT NULL,
                notes          BLOB
            )
            """
        )
# ------------------- REST endpoints ----------------------------------
@app.post("/record")
def insert_record():
    data = request.json
    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        conn.execute(
            "INSERT OR REPLACE INTO records VALUES (?, ?, ?, ?, ?)",
            (
                data["user_id"],
                int(time.time()),
                data["heart_rate"],
                data["blood_pressure"],
                data.get("notes", b""),
            ),
        )
    return jsonify(status="ok")

@app.get("/record/<user_id>")
def fetch_record(user_id: str):
    with sqlite.connect(DB_FILE) as conn:
        conn.execute(f"PRAGMA key = '{SQLCIPHER_KEY}';")
        cur = conn.execute(
            "SELECT * FROM records WHERE user_id = ? ORDER BY timestamp DESC LIMIT 1",
            (user_id,),
        )
        row = cur.fetchone()

    if not row:
        return jsonify(error="Not found"), 404

    record = dict(
        zip(
            ["user_id", "timestamp", "heart_rate", "blood_pressure", "notes"],
            row,
        )
    )

    # ---------- make notes JSON-friendly ----------
    notes = record["notes"]
    if isinstance(notes, str):
        notes = notes.encode()

    record["notes"] = base64.b64encode(notes).decode() if notes else ""
    return jsonify(record)

# ----------------------------------------------------------------------
if __name__ == "__main__":
    init_db() 
    app.run(host="0.0.0.0", port=5000)
