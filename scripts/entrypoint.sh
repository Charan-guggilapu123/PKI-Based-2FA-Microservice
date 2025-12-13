#!/usr/bin/env bash

# Set PYTHONPATH if not already set
export PYTHONPATH="${PYTHONPATH:-/srv/app/vendor:/srv/app}"
export PYTHONUNBUFFERED=1

echo "=== Starting PKI-2FA Microservice ==="
echo "Python: $(python --version)"
echo "PYTHONPATH: $PYTHONPATH"
echo "CWD: $(pwd)"
echo "Files in /srv/app:"
ls -la /srv/app/

# Create data directories
mkdir -p /data /cron
touch /cron/last_code.txt

# Start cron in background
echo "Starting cron..."
service cron start 2>&1 >/dev/null || cron 2>&1 >/dev/null || true &

# Wait a bit for cron to settle
sleep 1

# Start uvicorn
echo "Starting uvicorn..."
cd /srv/app
exec python -m uvicorn app.server:app --host 0.0.0.0 --port 8080 --log-level info
