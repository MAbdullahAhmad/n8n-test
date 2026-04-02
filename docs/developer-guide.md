# Developer Guide

## Overview

The repository is intentionally small. Most behavior lives in:

- `docker-compose.yml`
- `docker/start-n8n.sh`
- `workflows/website-monitor.json`

## Development Principles

- Keep the project self-starting with `docker compose up -d`
- Prefer updating the workflow JSON over manual UI edits
- Keep the startup script deterministic
- Treat `.env` as local-only and keep `.env.example` in sync with real config usage

## How Startup Works

1. `init-permissions` prepares `./data`
2. `n8n` runs `docker/start-n8n.sh`
3. The script imports the workflow
4. The script publishes the workflow
5. The script resets `workflow_entity.staticData`
6. The script launches `n8n start`

## How to Change the Schedule

Edit the `Schedule Trigger` node in `workflows/website-monitor.json`.

Current behavior:

- interval field: `hours`
- environment variable: `CHECK_INTERVAL_HOURS`

After changing the workflow file:

```bash
docker compose restart n8n
```

## How to Change Notification Logic

Edit the `Classify Change` code node in `workflows/website-monitor.json`.

This node controls:

- status classification
- daily heartbeat rules
- startup notification behavior
- Groq prompt construction

## How to Change the Output Format

Edit the `Append Log File` code node in `workflows/website-monitor.json`.

This node controls:

- Groq fallback behavior
- log line format
- file append path

## How to Change the Startup Reset Behavior

Edit `docker/start-n8n.sh`.

Current behavior:

- clears saved workflow static state on every container start
- does not delete the workflow or n8n database

## Safe Editing Checklist

- keep workflow ID stable unless you intentionally want a new workflow record
- keep `MONITOR_URL`, `GROQ_API_KEY`, and `GROQ_MODEL` env-driven
- keep `N8N_BLOCK_ENV_ACCESS_IN_NODE=false` because the workflow uses `$env`
- keep `NODE_FUNCTION_ALLOW_BUILTIN=crypto,fs` because Code nodes rely on both modules
