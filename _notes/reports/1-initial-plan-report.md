<html><head></head><body><h1>n8n Website Monitor — Full Setup Guide</h1>
<h2>What This Does</h2>
<ul>
<li>Checks https://eigensol.com every 1 minute</li>
<li>Hashes the content, detects if changed</li>
<li>Classifies change: site down / content increased / content decreased</li>
<li>Uses Groq API to generate a 2-sentence message</li>
<li>Appends result with timestamp to ~/automation.log</li>
</ul>
<hr>
<h2>Step 1 — Start n8n Locally</h2>
<pre><code class="language-bash">docker run -it --rm \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
</code></pre>
<p>Open browser: http://localhost:5678
Create a free account when prompted (local only).</p>
<hr>
<h2>Step 2 — Get Groq API Key</h2>
<ol>
<li>Go to https://console.groq.com</li>
<li>Sign up free</li>
<li>Go to API Keys → Create key</li>
<li>Copy it — you'll paste it in n8n</li>
</ol>
<hr>
<h2>Step 3 — Build the Flow</h2>
<p>In n8n UI: click <strong>"New Workflow"</strong>, then add nodes in this order:</p>
<hr>
<h3>Node 1 — Schedule Trigger</h3>
<ul>
<li>Node type: <code>Schedule Trigger</code></li>
<li>Set: Every <strong>1 minute</strong></li>
</ul>
<hr>
<h3>Node 2 — Fetch Website</h3>
<ul>
<li>Node type: <code>HTTP Request</code></li>
<li>Method: <code>GET</code></li>
<li>URL: <code>https://eigensol.com</code></li>
<li>Response Format: <code>Text</code></li>
<li>Name it: <code>Fetch Site</code></li>
</ul>
<hr>
<h3>Node 3 — Hash + Compare (Code Node)</h3>
<ul>
<li>Node type: <code>Code</code></li>
<li>Language: JavaScript</li>
<li>Paste this code:</li>
</ul>
<pre><code class="language-javascript">const crypto = require('crypto');
const fs = require('fs');

const content = $input.first().json.data || '';
const newHash = crypto.createHash('md5').update(content).digest('hex');
const newLength = content.length;

const stateFile = '/home/node/.n8n/site_state.json';
let oldHash = '';
let oldLength = 0;
let status = 'unchanged';

try {
  const state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
  oldHash = state.hash;
  oldLength = state.length;
} catch(e) {
  // first run, no state yet
}

// Save new state
fs.writeFileSync(stateFile, JSON.stringify({ hash: newHash, length: newLength }));

if (oldHash === '') {
  status = 'first_run';
} else if (newHash === oldHash) {
  status = 'unchanged';
} else if (content.includes('error') || content.includes('502') || content.includes('503') || newLength &lt; 500) {
  status = 'site_down';
} else if (newLength &gt; oldLength) {
  status = 'increased';
} else {
  status = 'decreased';
}

return [{ json: { status, newHash, oldHash, newLength, oldLength, content: content.slice(0, 300) } }];
</code></pre>
<hr>
<h3>Node 4 — IF: Skip if Unchanged</h3>
<ul>
<li>Node type: <code>IF</code></li>
<li>Condition: <code>{{ $json.status }}</code> <strong>is not equal to</strong> <code>unchanged</code></li>
<li>Also add: <code>{{ $json.status }}</code> <strong>is not equal to</strong> <code>first_run</code></li>
<li>True branch → continue. False branch → stop.</li>
</ul>
<hr>
<h3>Node 5 — Call Groq API</h3>
<ul>
<li>Node type: <code>HTTP Request</code></li>
<li>Method: <code>POST</code></li>
<li>URL: <code>https://api.groq.com/openai/v1/chat/completions</code></li>
<li>Headers:
<ul>
<li><code>Authorization</code>: <code>Bearer YOUR_GROQ_API_KEY</code></li>
<li><code>Content-Type</code>: <code>application/json</code></li>
</ul>
</li>
<li>Body (JSON):</li>
</ul>
<pre><code class="language-json">{
  "model": "llama3-8b-8192",
  "messages": [
    {
      "role": "user",
      "content": "Website eigensol.com status changed. Status: {{ $json.status }}. Old size: {{ $json.oldLength }} chars. New size: {{ $json.newLength }} chars. Write exactly 2 short sentences summarizing what happened. Be direct."
    }
  ],
  "max_tokens": 100
}
</code></pre>
<hr>
<h3>Node 6 — Format Log Entry (Code Node)</h3>
<ul>
<li>Node type: <code>Code</code></li>
<li>Language: JavaScript</li>
<li>Paste:</li>
</ul>
<pre><code class="language-javascript">const groqResponse = $input.first().json;
const message = groqResponse.choices[0].message.content.trim();
const status = $('IF').first().json.status;

const timestamp = new Date().toISOString();
const logLine = `[${timestamp}] STATUS: ${status} | ${message}\n`;

return [{ json: { logLine } }];
</code></pre>
<hr>
<h3>Node 7 — Write to Log File</h3>
<ul>
<li>Node type: <code>Execute Command</code></li>
<li>Command:</li>
</ul>
<pre><code class="language-bash">echo "{{ $json.logLine }}" &gt;&gt; ~/automation.log
</code></pre>
<hr>
<h2>Step 4 — Activate</h2>
<ul>
<li>Click <strong>Save</strong> (top right)</li>
<li>Toggle <strong>Active</strong> switch ON</li>
<li>n8n will now run every minute automatically</li>
</ul>
<hr>
<h2>Step 5 — Check the Log</h2>
<p>Open a terminal anytime:</p>
<pre><code class="language-bash">tail -f ~/automation.log
</code></pre>
<p>Or view last 20 entries:</p>
<pre><code class="language-bash">tail -20 ~/automation.log
</code></pre>
<hr>
<h2>How to Use n8n UI</h2>

Action | How
-- | --
See all workflows | Left sidebar → Workflows
See run history | Open workflow → click "Executions" tab
See each node's output | Click any node after a run → see input/output JSON
Debug a run | Click "Execute Workflow" manually to test once
Edit a node | Click it → edit on right panel
Add a new node | Click + between any two nodes


<hr>
<h2>Sample Log Output</h2>
<pre><code>[2026-03-31T21:05:01.000Z] STATUS: increased | The website eigensol.com has gained new content since the last check. Page size increased from 4200 to 5100 characters.
[2026-03-31T21:06:01.000Z] STATUS: unchanged | (skipped)
[2026-03-31T21:07:01.000Z] STATUS: site_down | eigensol.com appears to be down or returning an error. The page content dropped below expected size thresholds.
</code></pre>
<hr>
<h2>Notes</h2>
<ul>
<li>State is saved in <code>~/.n8n/site_state.json</code> between runs</li>
<li>Groq free tier is generous — this usage costs ~$0</li>
<li>To stop: <code>Ctrl+C</code> the Docker container, or toggle workflow OFF in UI</li>
<li>To persist across reboots, remove <code>--rm</code> from the docker run command</li>
</ul></body></html>