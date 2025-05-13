#!/bin/bash

OUTFILE="stats_log_$(date +%s).txt"
DURATION=60
INTERVAL=1

echo "[*] Logging docker stats to $OUTFILE for $DURATION seconds ..."
echo "Time,Container,CPU %,Memory Usage" >> $OUTFILE

END=$((SECONDS + DURATION))
while [ $SECONDS -lt $END ]; do
  TIMESTAMP=$(date +%s)
  docker stats --no-stream --format "$TIMESTAMP,{{.Name}},{{.CPUPerc}},{{.MemUsage}}" >> $OUTFILE
  sleep $INTERVAL
done

echo "[✓] Logging complete: $OUTFILE"
