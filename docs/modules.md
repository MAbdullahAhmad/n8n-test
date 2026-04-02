# Modules and Files

## Repository Layout

```text
.
├── README.md
├── docker-compose.yml
├── docker/
│   └── start-n8n.sh
├── workflows/
│   └── website-monitor.json
├── docs/
│   ├── README.md
│   ├── setup.md
│   ├── user-guide.md
│   ├── user-flow.md
│   ├── architecture.md
│   ├── modules.md
│   ├── workflow-nodes.md
│   ├── api-reference.md
│   ├── developer-guide.md
│   ├── operations.md
│   └── troubleshooting.md
└── data/
    └── .gitkeep
```

## File Responsibilities

### `README.md`

Top-level project overview and navigation into the docs set.

### `docker-compose.yml`

Defines the runtime services, environment wiring, volume mounts, and health checks.

### `docker/start-n8n.sh`

Performs pre-start workflow import, publish, and state reset.

### `workflows/website-monitor.json`

Defines the workflow graph, node configuration, prompt generation, and log-writing logic.

### `data/`

Holds runtime data created after startup.

### `docs/`

Holds all detailed user, developer, operational, and reference documentation.

## Runtime-Generated Files

The following appear after startup and are not source files:

- `data/n8n/database.sqlite`
- `data/n8n/config`
- `data/n8n/*-wal`
- `data/automation.log`
