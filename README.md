# n8n Website Monitor

This project starts a local n8n stack that checks a website every minute, detects content changes by hash and size, asks Groq for a 2-sentence summary when something changes, and appends the result to a local log file.

## What it does

- Checks `MONITOR_URL` every `CHECK_INTERVAL_MINUTES`
- Tracks the previous hash and content length using n8n workflow static data
- Classifies each run as `first_run`, `unchanged`, `site_down`, `increased`, or `decreased`
- Calls Groq for a short summary when the status is `site_down`, `increased`, or `decreased`
- Appends log lines to `./data/automation.log`

## Files

- `docker-compose.yml`: local n8n stack with startup-time workflow import
- `.env.example`: environment variable template
- `workflows/website-monitor.json`: importable n8n workflow
- `docker/start-n8n.sh`: imports and publishes the workflow before `n8n start`

## Setup

1. Copy the env template:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your Groq API key.

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Open [http://localhost:5678](http://localhost:5678).

5. If n8n prompts you to complete the local owner setup in the browser, do that once. The workflow is already imported and published during container startup, so once the editor loads it should be ready to run.

## Runtime behavior

- n8n data persists in `./data/n8n`
- The monitor log is written to `./data/automation.log`
- The workflow skips logging on `first_run` and `unchanged`
- The monitor state survives restarts because it is stored in the persisted n8n workflow data

## Useful commands

Start or restart everything:

```bash
docker compose up -d
```

Stop everything:

```bash
docker compose down
```

Watch startup logs:

```bash
docker compose logs -f n8n
```

Watch the automation log:

```bash
tail -f ./data/automation.log
```

Show the latest 20 log lines:

```bash
tail -20 ./data/automation.log
```

## Verify the workflow is active

- Open the n8n UI
- Go to `Workflows`
- Confirm `Website Monitor - Eigensol` exists
- Open it and confirm it is published and running on the schedule

If the workflow imported but is not active in the UI, toggle it on once. After that, the persisted n8n data directory keeps the workflow state across restarts.
