#!/usr/bin/env bash
set -e

# Set PYTHONPATH if not already set
export PYTHONPATH="${PYTHONPATH:-/srv/app/vendor}"

# Start cron in the background
echo "Starting cron service..."
service cron start || cron || true
mkdir -p /cron
touch /cron/last_code.txt

# Start uvicorn in the foreground (keeps container running)
echo "Starting uvicorn API server..."
exec python -m uvicorn app.server:app --host 0.0.0.0 --port 8080
