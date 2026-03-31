#!/bin/sh

set -eu

WORKFLOW_ID="website-monitor-eigensol"
WORKFLOW_FILE="/workflows/website-monitor.json"
SENTINEL_FILE="/home/node/.n8n/.website-monitor-imported"

mkdir -p /home/node/.n8n

if [ ! -f "$SENTINEL_FILE" ]; then
  echo "Importing website monitor workflow..."

  if output="$(n8n import:workflow --input="$WORKFLOW_FILE" 2>&1)"; then
    echo "$output"
  else
    echo "$output"
    if ! echo "$output" | grep -qi "already exists"; then
      exit 1
    fi
  fi

  n8n publish:workflow --id="$WORKFLOW_ID" >/dev/null 2>&1 || true
  touch "$SENTINEL_FILE"
fi

exec n8n start
