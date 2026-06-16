#!/bin/bash
set -e

SERVICE=$1

case $SERVICE in
    user-service)
        cd "$SERVICE"
        npm audit --audit-level=high
        ;;
    transaction-service)
        cd "$SERVICE"
        pip install --break-system-packages pip-audit
        pip-audit -r requirements.txt
        ;;
    *)
        echo "Unknown service: $SERVICE"
        exit 1
        ;;
esac
