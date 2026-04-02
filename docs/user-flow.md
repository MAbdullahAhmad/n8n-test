# User Flow

## Overview

The workflow is driven by a schedule trigger and follows a simple decision flow:

1. Trigger on the configured hourly interval
2. Fetch the target website
3. Compare the current response to the last saved state
4. Decide whether a notification should be sent
5. Ask Groq for a 2-sentence summary
6. Append the final message to the log file

## Startup Flow

When the container starts:

1. The startup script imports and publishes the workflow
2. Saved workflow comparison state is cleared
3. n8n starts and activates the workflow
4. On the first scheduled run after startup, the workflow treats the site as a fresh baseline
5. A Groq summary is generated even if nothing changed yet

## Normal Unchanged Flow

On most hourly checks:

1. The site is fetched
2. The content hash matches the saved hash
3. The workflow sees `unchanged`
4. No message is sent unless it is the first unchanged run of a new day

## Daily Heartbeat Flow

Once per day on the first unchanged run:

1. The workflow sees `unchanged`
2. The stored daily heartbeat date is older than today
3. A Groq prompt is created asking for a short “nothing updated” summary
4. The summary is appended to the log

## Change Alert Flow

When the hash or size changes:

1. The workflow classifies the change as `increased`, `decreased`, or `site_down`
2. A change-specific Groq prompt is created
3. Groq returns a 2-sentence summary
4. The message is appended immediately on that run

## Restart Behavior

- A container restart clears saved comparison state
- The next scheduled run becomes the new startup baseline
- Daily unchanged notification tracking resets with the startup state reset
