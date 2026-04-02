# Operations Guide

## Daily Commands

### Start the Stack

```bash
docker compose up -d
```

### Stop the Stack

```bash
docker compose down
```

### Restart n8n

```bash
docker compose restart n8n
```

### View Service Status

```bash
docker compose ps
```

## Logs

### n8n Container Logs

```bash
docker compose logs -f n8n
```

### Automation Output Log

```bash
tail -f ./data/automation.log
```

## What to Expect Operationally

- Startup imports and republishes the workflow
- Startup clears saved comparison state
- The first scheduled run after a restart is a startup baseline
- The workflow writes only when a notification is supposed to be sent

## Data Persistence

Persisted between runs:

- n8n database
- n8n config
- workflow record
- log file

Reset on container start by design:

- workflow comparison static data

## Updating the Workflow

If you edit `workflows/website-monitor.json`, run:

```bash
docker compose restart n8n
```

The startup script will re-import and re-publish the workflow on boot.

## Checking Health

Use:

```bash
docker compose ps
docker compose logs --tail=50 n8n
```

Healthy startup usually includes:

- workflow import success
- workflow activation success
- editor available on port `5678`
