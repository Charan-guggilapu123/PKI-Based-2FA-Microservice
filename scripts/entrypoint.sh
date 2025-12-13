#!/usr/bin/env bash
set -e

# Setup environment
export PYTHONPATH="${PYTHONPATH:-/srv/app/vendor:/srv/app}"
export PYTHONUNBUFFERED=1
export DATA_DIR="${DATA_DIR:-/data}"

# Create data directories
mkdir -p /data /cron
touch /cron/last_code.txt 2>/dev/null || true

# Start cron in background (optional - don't fail if it doesn't work)
service cron start 2>/dev/null >/dev/null || cron 2>/dev/null >/dev/null || true &

# Give cron a moment to start
sleep 1

# Start uvicorn from /srv/app
cd /srv/app
exec python -m uvicorn app.server:app --host 0.0.0.0 --port 8080 --log-level info
