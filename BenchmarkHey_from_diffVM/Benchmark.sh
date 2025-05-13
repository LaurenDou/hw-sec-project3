#!/bin/bash

TDX_IP="34.41.88.216"  
DURATION="2m"          
READ_COUNT=900
WRITE_COUNT=100

echo "[*] Starting benchmark: 900 GETs, 100 POSTs"

# Generate POST payloads
POST_DATA='{"user_id":"alice","heart_rate":70,"blood_pressure":"120/80","notes":"benchmark"}'

# Run GETs in the background
hey -n $READ_COUNT -c 100 http://$TDX_IP:5000/record/alice > read_results.txt &
READ_PID=$!

# Run POSTs in the background
hey -n $WRITE_COUNT -c 20 -m POST -H "Content-Type: application/json" -d "$POST_DATA" \
    http://$TDX_IP:5000/record > write_results.txt &
WRITE_PID=$!

# Wait for both to complete
wait $READ_PID
wait $WRITE_PID

echo "[✓] Benchmark complete. Results:"
echo "--- READS ---"
grep -E "Requests/sec|Average|p9[59]" read_results.txt
echo "--- WRITES ---"
grep -E "Requests/sec|Average|p9[59]" write_results.txt
