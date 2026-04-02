# n8n Website Monitor

This repository contains a self-starting local n8n project that monitors a website on a schedule, classifies changes, summarizes alerts with Groq, and writes timestamped log entries to disk.

## Quick Start

1. Copy the environment template:

   ```bash
   cp .env.example .env
   ```

2. Add your Groq API key to `.env`.

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Open [http://localhost:5678](http://localhost:5678).

5. Confirm the workflow `Website Monitor - Eigensol` exists and is active.

## Documentation

- [Documentation Index](docs/README.md)
- [Setup Guide](docs/setup.md)
- [User Guide](docs/user-guide.md)
- [User Flow](docs/user-flow.md)
- [Architecture](docs/architecture.md)
- [Modules and Files](docs/modules.md)
- [Workflow Nodes](docs/workflow-nodes.md)
- [API and Interface Reference](docs/api-reference.md)
- [Developer Guide](docs/developer-guide.md)
- [Operations Guide](docs/operations.md)
- [Troubleshooting](docs/troubleshooting.md)

## At a Glance

- Checks `MONITOR_URL` every `CHECK_INTERVAL_HOURS`
- Imports and publishes the workflow automatically during container startup
- Clears saved comparison state on each container start so the next scheduled run becomes a fresh startup baseline
- Sends Groq-generated notifications on startup, once per day when nothing has changed, and immediately when a change is detected
- Appends log output to `./data/automation.log`
