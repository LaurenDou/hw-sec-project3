#!/usr/bin/env bash
set -euo pipefail

echo "[fithealth] generating TDX quote using trustauthority-cli ..."
QUOTE=$(trustauthority-cli evidence --tdx --config /etc/trustauthority-cli/config.json || echo MOCK-QUOTE)

echo "[fithealth] submitting quote to attestation service (simulated) ..."
echo "$QUOTE" > /tmp/tdx_quote.json
echo "[fithealth] quote trusted ✔ (simulated)"

echo "[fithealth] fetching SQLCipher key from Google Secret Manager …"
SQLCIPHER_KEY=$(gcloud secrets versions access latest --secret="fithealth-sqlcipher-key" 2>/dev/null || true)
echo "[fithealth] Retrieved key: $SQLCIPHER_KEY"

if [[ -z "$SQLCIPHER_KEY" || "$SQLCIPHER_KEY" =~ "<html" ]]; then
  echo "[fithealth] ERROR: could not fetch SQLCipher key – check Secret Manager access" >&2
  exit 1
fi
export SQLCIPHER_KEY
echo "[fithealth] secret retrieved ✔"

# 🔥 Remove broken DB
rm -f /app/fithealth.db

# 🔁 Call init_db BEFORE Gunicorn loads app
echo "[fithealth] initializing DB …"
python3 -c 'from app import init_db; init_db()'

echo "[fithealth] starting FitHealth service …"
exec gunicorn -w "$(nproc)" -k gevent -b 0.0.0.0:5000 app:app
