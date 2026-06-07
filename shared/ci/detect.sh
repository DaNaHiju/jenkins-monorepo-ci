#!/bin/bash
set -e

# Base ref to compare against. Default: previous commit (fine for push-to-main builds).
BASE="${1:-HEAD~1}"

# Services we know about — the source of truth for filtering
SERVICES="user-service transaction-service"

# All files changed between BASE and the current commit
CHANGED_FILES=$(git diff --name-only "$BASE" HEAD)

# Rule: if anything under shared/ changed, it affects everyone -> run ALL services
if echo "$CHANGED_FILES" | grep -q '^shared/'; then
    for svc in $SERVICES; do echo "$svc"; done
    exit 0
fi

# Otherwise: only the services whose own folder changed
for svc in $SERVICES; do
    if echo "$CHANGED_FILES" | grep -q "^${svc}/"; then
        echo "$svc"
    fi
done