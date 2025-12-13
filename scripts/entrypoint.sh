#!/usr/bin/env bash

# Set PYTHONPATH if not already set
export PYTHONPATH="${PYTHONPATH:-/srv/app/vendor:/srv/app}"

echo "=== Starting PKI-2FA Microservice ==="
echo "PYTHONPATH: $PYTHONPATH"
echo "Current directory: $(pwd)"
echo "Python version: $(python --version)"
echo "Working directory contents: $(ls -la)"

# Create directories
mkdir -p /data /cron
touch /cron/last_code.txt
echo "[INFO] Data directories created"

# Start cron in the background with error suppression
echo "[INFO] Starting cron service..."
{
    if command -v service &> /dev/null; then
        service cron start 2>&1 || true
    elif command -v cron &> /dev/null; then
        cron 2>&1 || true
    else
        echo "[WARN] cron command not found, skipping cron"
    fi
} &
CRON_PID=$!
sleep 2
echo "[INFO] Cron service started (PID: $CRON_PID)"

# Start uvicorn in the foreground (keeps container running)
echo "[INFO] Starting uvicorn API server on 0.0.0.0:8080..."
python -m uvicorn app.server:app --host 0.0.0.0 --port 8080 --log-level info --access-log 2>&1

# If uvicorn exits, container should exit
EXIT_CODE=$?
echo "[ERROR] Uvicorn exited with code: $EXIT_CODE"
exit $EXIT_CODE
