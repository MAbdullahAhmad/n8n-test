# Setup Guide

## Prerequisites

- Docker
- Docker Compose
- A Groq API key

## Repository Files Used During Setup

- `docker-compose.yml`
- `.env.example`
- `docker/start-n8n.sh`
- `workflows/website-monitor.json`

## Initial Setup

1. Create the local environment file:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set:

   - `GROQ_API_KEY`
   - `MONITOR_URL` if you want a different site
   - `CHECK_INTERVAL_HOURS` if you want a different hourly interval
   - `GROQ_MODEL` if you want a different Groq model

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Open the editor:

   ```text
   http://localhost:5678
   ```

5. If n8n asks for first-time owner setup, complete it once in the browser.

## What Startup Does Automatically

- Creates or fixes permissions for the local `data/` directory
- Imports the workflow from `workflows/website-monitor.json`
- Publishes the workflow
- Resets saved workflow comparison state
- Starts n8n and activates the workflow

## Verify Setup

Run:

```bash
docker compose ps
docker compose logs --tail=50 n8n
```

Then confirm in the UI:

- Workflow name: `Website Monitor - Eigensol`
- Workflow state: active
- Schedule trigger: hourly

## Local Data Paths

- `./data/n8n`: n8n application data and SQLite database
- `./data/automation.log`: appended monitoring output
