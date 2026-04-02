# Workflow Nodes

## Workflow Identity

- Workflow ID: `website-monitor-eigensol`
- Workflow name: `Website Monitor - Eigensol`

## Node 1: Schedule Trigger

- Type: `n8n-nodes-base.scheduleTrigger`
- Purpose: starts the workflow on an hourly interval
- Key input: `CHECK_INTERVAL_HOURS`

Behavior:

- Uses an hours-based interval
- Reads the value from the environment, defaulting to `1`

## Node 2: Fetch Site

- Type: `n8n-nodes-base.httpRequest`
- Purpose: fetches the monitored website

Key behavior:

- Uses `GET`
- Reads `MONITOR_URL` from the environment
- Requests text output
- Returns full response metadata
- Uses `neverError` so non-2xx responses can still be classified by the workflow

## Node 3: Classify Change

- Type: `n8n-nodes-base.code`
- Purpose: compares the latest response against saved workflow state and decides whether to notify

Responsibilities:

- normalize the fetched response
- compute an MD5 hash
- compare new length vs old length
- classify the current state
- decide whether this run should notify
- build the Groq prompt
- persist the new comparison state

Status outputs:

- `first_run`
- `unchanged`
- `site_down`
- `increased`
- `decreased`

Notification reasons:

- `startup`
- `daily_heartbeat`
- `change`

## Node 4: Summarize With Groq

- Type: `n8n-nodes-base.httpRequest`
- Purpose: sends a prompt to Groq's chat completions API

Key behavior:

- Uses `POST`
- Sends `Authorization: Bearer ${GROQ_API_KEY}`
- Uses `GROQ_MODEL`
- Passes `summaryPrompt` from the previous node

## Node 5: Append Log File

- Type: `n8n-nodes-base.code`
- Purpose: formats the final line and appends it to disk

Key behavior:

- Reads the Groq response
- Falls back to a default message if Groq fails
- Writes to `/files/automation.log`
- Returns the written line in node output
