# User Guide

## What the System Does

The monitor checks the configured website on a schedule, compares the current content to the previous saved version, asks Groq to summarize notable events, and writes a human-readable log line to disk when a notification should be sent.

## Where to Look

- n8n editor: `http://localhost:5678`
- Workflow: `Website Monitor - Eigensol`
- Log file: `./data/automation.log`

## Common User Tasks

### Check Whether the Workflow Is Running

In the n8n UI:

1. Open `Workflows`
2. Open `Website Monitor - Eigensol`
3. Open the `Executions` tab

### Inspect the Latest Run

In the n8n UI:

1. Open the latest execution
2. Click any node
3. Review the input and output payloads

### Watch Log Output

```bash
tail -f ./data/automation.log
```

### See Recent Log Entries

```bash
tail -20 ./data/automation.log
```

## Notification Rules

- On startup: one Groq-generated message is sent even if nothing changed
- During the day: unchanged checks stay silent
- Once per day: one unchanged heartbeat message is sent through Groq
- When a real change is detected: a Groq-generated message is sent on that check

## Status Values You May See

- `first_run`
- `unchanged`
- `site_down`
- `increased`
- `decreased`

These statuses appear in workflow data and in log lines.
