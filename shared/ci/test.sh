#!/bin/bash
set -e

SERVICE=$1

case $SERVICE in
    user-service)
        cd "$SERVICE"
        npm install
        npm test
        ;;
    transaction-service)
        cd "$SERVICE"
        pip install --break-system-packages -r requirements.txt
        pytest --junitxml=reports/junit.xml
        ;;
    *)
        echo "Unknown service: $SERVICE"
        exit 1
        ;;
esac
