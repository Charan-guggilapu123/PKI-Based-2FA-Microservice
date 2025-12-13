#!/usr/bin/env bash
set -e

# Set PYTHONPATH if not already set
export PYTHONPATH="${PYTHONPATH:-/srv/app/vendor}:/srv/app"

echo "Starting PKI-2FA Microservice..."
echo "PYTHONPATH: $PYTHONPATH"
echo "Current directory: $(pwd)"

# Create directories
mkdir -p /data /cron
touch /cron/last_code.txt

# Start cron in the background with better error handling
echo "Starting cron service..."
if command -v service &> /dev/null; then
    service cron start 2>&1 || true
elif command -v cron &> /dev/null; then
    cron 2>&1 || true
else
    echo "Warning: cron service not available"
fi

# Give cron a moment to start
sleep 1

# Start uvicorn in the foreground (keeps container running)
echo "Starting uvicorn API server on 0.0.0.0:8080..."
exec python -m uvicorn app.server:app --host 0.0.0.0 --port 8080 --log-level info
