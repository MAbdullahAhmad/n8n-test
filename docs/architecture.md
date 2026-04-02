# Architecture

## High-Level Design

The project is a single-service n8n deployment with a supporting permission-initialization service. Its logic lives primarily inside one imported workflow and one startup script.

## Components

### Docker Compose

`docker-compose.yml` defines:

- `init-permissions`: prepares the local `data/` directory with the right ownership
- `n8n`: runs the n8n application, startup script, workflow import, and monitoring workflow

### Startup Script

`docker/start-n8n.sh` is responsible for:

- importing the workflow JSON
- publishing the workflow
- clearing saved workflow static data in SQLite
- launching `n8n start`

### Workflow Definition

`workflows/website-monitor.json` contains the monitoring pipeline.

### Persistent Storage

- n8n database and state: `./data/n8n`
- appended operational log: `./data/automation.log`

## Runtime Data Flow

1. Schedule Trigger fires
2. HTTP Request fetches the monitored site
3. Code node computes hash and classification
4. Notification decision is made
5. HTTP Request sends a prompt to Groq
6. Code node formats and appends the final log line

## State Model

Workflow static data stores:

- last content hash
- last content length
- last response status code
- last check timestamp
- last daily heartbeat date

Startup intentionally clears this saved state so each container boot begins with a fresh baseline.

## Reliability Notes

- The monitored site fetch is configured to avoid hard failure on non-2xx responses
- Groq failures do not stop log creation; the workflow falls back to a placeholder message
- The workflow remains file-based and self-contained, with no external database beyond n8n's SQLite store
