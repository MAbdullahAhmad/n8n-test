# Troubleshooting

## Workflow Exists but Does Not Run

Check:

```bash
docker compose logs --tail=100 n8n
```

Look for:

- workflow activation errors
- env access errors
- startup import failures

## Env Vars Are Not Available in the Workflow

This project requires:

```text
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
```

If that is removed, workflow activation can fail because `$env` is used in node expressions and prompts.

## Code Node Fails to Load `crypto` or `fs`

This project requires:

```text
NODE_FUNCTION_ALLOW_BUILTIN=crypto,fs
```

If that setting is removed, the workflow cannot hash content or append the log file.

## Workflow Was Edited but Changes Did Not Apply

Restart n8n:

```bash
docker compose restart n8n
```

The workflow is imported during container startup, so file changes are applied on restart.

## Permissions Errors Under `data/`

The stack includes `init-permissions` to correct local ownership, but if permissions are still wrong:

```bash
docker compose down
docker compose up -d
```

## Groq Summaries Are Missing

Check:

- `.env` contains a valid `GROQ_API_KEY`
- the Groq API is reachable
- container logs for HTTP request failures

The workflow will still append a fallback message if the Groq request fails.

## No New Log Lines Appear

Possible reasons:

- the site is unchanged and the run is not the startup notification
- the site is unchanged and it is not the daily heartbeat
- the workflow is inactive
- the workflow has not reached its next scheduled interval yet

Use the n8n `Executions` tab to confirm whether runs are happening.
