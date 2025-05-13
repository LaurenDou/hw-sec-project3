#!/usr/bin/env bash
set -euo pipefail

# Step 1: Inject SQLCipher key (hardcoded or from env var)
if [[ -z "${SQLCIPHER_KEY:-}" ]]; then
  echo "[fithealth] Using fallback static SQLCipher key"
  export SQLCIPHER_KEY="default_static_key_1234567890abcdef"
fi
echo "[fithealth] SQLCipher key injected ✔"

# Step 2: Initialize the encrypted database
rm -f /app/fithealth.db
echo "[fithealth] initializing DB …"
python3 -c 'from app import init_db; init_db()'

# Step 3: Start the Flask app via Gunicorn
echo "[fithealth] starting FitHealth service …"
exec gunicorn -w "$(nproc)" -k gevent -b 0.0.0.0:5000 app:app