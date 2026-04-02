# API and Interface Reference

## Purpose

This project does not expose a custom web API of its own. Its interfaces are operational and integration-facing:

- local n8n UI and health endpoints
- Groq Chat Completions API
- environment-variable configuration
- on-disk log format
- workflow status vocabulary

## Local Endpoints

### n8n Editor

- URL: `http://localhost:5678`
- Purpose: workflow inspection, executions, and manual control

### n8n Health Check

- URL: `http://127.0.0.1:5678/healthz`
- Method: `GET`
- Used by: Docker health check

## External API

### Groq Chat Completions

- URL: `https://api.groq.com/openai/v1/chat/completions`
- Method: `POST`
- Authentication: `Authorization: Bearer <GROQ_API_KEY>`
- Content-Type: `application/json`

Request fields used by this project:

- `model`
- `messages`
- `max_tokens`

Response fields read by this project:

- `choices[0].message.content`
- fallback: `message`
- fallback: `error.message`

## Environment Variables

### Required

- `GROQ_API_KEY`: authenticates the Groq API request

### Optional

- `MONITOR_URL`: target site to monitor
- `CHECK_INTERVAL_HOURS`: hours between checks
- `GROQ_MODEL`: model name sent to Groq

### Internal n8n Runtime Flags

Defined in `docker-compose.yml`:

- `N8N_PORT`
- `N8N_HOST`
- `N8N_PROTOCOL`
- `N8N_BLOCK_ENV_ACCESS_IN_NODE=false`
- `NODE_FUNCTION_ALLOW_BUILTIN=crypto,fs`

## Workflow Status Vocabulary

### `first_run`

First scheduled run after startup state reset.

### `unchanged`

The fetched content matched the previous saved content.

### `site_down`

The site appears unavailable or unhealthy based on fetch errors, status code, response size, or error text.

### `increased`

The content changed and the normalized content length grew.

### `decreased`

The content changed and the normalized content length shrank.

## Notification Reasons

### `startup`

Notification sent after startup even when nothing changed.

### `daily_heartbeat`

Notification sent once per day on the first unchanged run of that day.

### `change`

Notification sent when the site changes or appears down.

## Log Format

File:

- `./data/automation.log`

Line format:

```text
[<ISO_TIMESTAMP>] STATUS: <status> | <message>
```

Example:

```text
[2026-04-01T03:00:00.000Z] STATUS: unchanged | Nothing updated on the monitored site today. Monitoring is still running normally.
```
