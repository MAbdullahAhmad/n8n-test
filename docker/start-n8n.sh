#!/bin/sh

set -eu

WORKFLOW_ID="website-monitor-eigensol"
WORKFLOW_FILE="/workflows/website-monitor.json"

mkdir -p /home/node/.n8n

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

echo "Resetting saved monitor state for workflow $WORKFLOW_ID..."
node - <<'NODE'
const sqlite3 = require('/usr/local/lib/node_modules/n8n/node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3');
const db = new sqlite3.Database('/home/node/.n8n/database.sqlite');
db.run(
  'UPDATE workflow_entity SET staticData = NULL, updatedAt = STRFTIME(\'%Y-%m-%d %H:%M:%f\', \'NOW\') WHERE id = ?',
  ['website-monitor-eigensol'],
  function (err) {
    if (err) {
      console.error(err.message);
      process.exitCode = 1;
    }
    db.close((closeErr) => {
      if (closeErr) {
        console.error(closeErr.message);
        process.exitCode = 1;
      }
    });
  },
);
NODE

exec n8n start
