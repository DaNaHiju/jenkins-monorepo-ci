#!/bin/bash
set -e

SERVICE=$1

case $SERVICE in
    user-service)
        cd "$SERVICE"
        npm install
        npm run lint
        ;;
    transaction-service)
        cd "$SERVICE"
        pip install --break-system-packages -r requirements.txt
        flake8 .
        ;;
    *)
        echo "Unknown service: $SERVICE"
        exit 1
        ;;
esac
