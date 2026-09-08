#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/Ax-Homelab/Website}"
cd "$ROOT"
mkdir -p public/data n8n src/pages

cat > public/data/github-projects.json <<'EOF'
[]
EOF

cat > public/data/project-status.json <<'EOF'
[
  {
    "id": "lovetap",
    "title": "LoveTap",
    "tagline": "A focused Android app built around a simple, human interaction.",
    "status": "active",
    "progress": 78,
    "next": "Resolve release-blocking bugs and prepare the first release.",
    "tags": ["Android", "App Development", "Release"],
    "githubRepo": null,
    "featured": true
  },
  {
    "id": "project32droid",
    "title": "Project32Droid",
    "tagline": "A 32-bit Android compatibility and emulation experiment.",
    "status": "active",
    "progress": 62,
    "next": "Finish the 32-bit emulator and stabilize the target runtime.",
    "tags": ["Kotlin", "C++", "JNI", "Android NDK"],
    "githubRepo": "Acsaeo/Project32Droid",
    "featured": true
  },
  {
    "id": "cat-axiom",
    "title": "Cat / Axiom",
    "tagline": "A self-hosted, phone-first AI companion with voice and automation.",
    "status": "planning",
    "progress": 12,
    "next": "Start the mobile Jarvis-like app foundation.",
    "tags": ["AI", "Voice", "Automation", "Mobile"],
    "githubRepo": null,
    "featured": true
  }
]
EOF

cat > n8n/github-project-sync.cjs <<'EOF'
const fs = require('fs');
const file = '/site/public/data/github-projects.json';
const encoded = process.argv[2];
if (!encoded) throw new Error('Missing project payload');
const input = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8'));
if (!Array.isArray(input.projects)) throw new Error('projects must be an array');
if (input.projects.length > 100) throw new Error('Too many projects');
for (const p of input.projects) {
  if (typeof p.name !== 'string' || p.name.length > 100) throw new Error('Invalid project name');
  if (typeof p.fullName !== 'string' || !/^[\w.-]+\/[\w.-]+$/.test(p.fullName)) throw new Error('Invalid fullName');
  if (typeof p.url !== 'string' || !p.url.startsWith('https://github.com/')) throw new Error('Invalid URL');
  if (typeof p.description !== 'string' || p.description.length > 500) throw new Error('Invalid description');
  if (!Array.isArray(p.topics) || p.topics.length > 20) throw new Error('Invalid topics');
}
const temporary = file + '.tmp';
fs.writeFileSync(temporary, JSON.stringify(input.projects, null, 2) + '\n', 'utf8');
fs.renameSync(temporary, file);
console.log(JSON.stringify({ ok: true, count: input.projects.length }));
EOF

cat > n8n/axio-github-project-sync.json <<'EOF'
{
  "name": "Axio - Sync Public GitHub Projects",
  "nodes": [
    {
      "parameters": { "rule": { "interval": [ { "field": "hours", "hoursInterval": 6 } ] } },
      "id": "e203f522-15b0-4c65-b5bc-94d50807cfa0",
      "name": "Every 6 Hours",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.2,
      "position": [300, 300]
    },
    {
      "parameters": {
        "url": "https://api.github.com/users/Acsaeo/repos?type=owner&sort=updated&direction=desc&per_page=100",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            { "name": "Accept", "value": "application/vnd.github+json" },
            { "name": "X-GitHub-Api-Version", "value": "2022-11-28" }
          ]
        },
        "options": {}
      },
      "id": "e73ea79a-f2d7-4ac9-9811-b0da1c2d04b8",
      "name": "Get Acsaeo Public Repositories",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [520, 300]
    },
    {
      "parameters": {
        "jsCode": "const repos = $input.all().map(item => item.json);\nconst projects = repos\n  .filter(repo => repo.visibility === 'public' && !repo.fork && !repo.archived && !repo.disabled)\n  .map(repo => ({\n    name: repo.name,\n    fullName: repo.full_name,\n    url: repo.html_url,\n    description: repo.description || 'Public project by Axiolus.',\n    language: repo.language || null,\n    topics: Array.isArray(repo.topics) ? repo.topics.slice(0, 8) : [],\n    stars: Number(repo.stargazers_count || 0),\n    forks: Number(repo.forks_count || 0),\n    updatedAt: repo.updated_at,\n    pushedAt: repo.pushed_at,\n    homepage: repo.homepage || null\n  }));\nreturn [{ json: { payloadB64: Buffer.from(JSON.stringify({ projects })).toString('base64url'), count: projects.length } }];"
      },
      "id": "453d1e70-a56d-46cb-9c0a-bd8f0905440b",
      "name": "Filter and Prepare Public Projects",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [760, 300]
    },
    {
      "parameters": { "command": "node /files/github-project-sync.cjs \"{{$json.payloadB64}}\"" },
      "id": "c9ce9c40-d55b-4be7-b4dd-d339d7e17ce5",
      "name": "Write Public Project Feed",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [1000, 300]
    }
  ],
  "pinData": {},
  "connections": {
    "Every 6 Hours": { "main": [[{ "node": "Get Acsaeo Public Repositories", "type": "main", "index": 0 }]] },
    "Get Acsaeo Public Repositories": { "main": [[{ "node": "Filter and Prepare Public Projects", "type": "main", "index": 0 }]] },
    "Filter and Prepare Public Projects": { "main": [[{ "node": "Write Public Project Feed", "type": "main", "index": 0 }]] }
  },
  "active": false,
  "settings": { "executionOrder": "v1" },
  "versionId": "567a96a0-132b-467f-9e0b-e5f68eb92e81",
  "meta": { "templateCredsSetupCompleted": true },
  "tags": []
}
EOF

cat > src/pages/projects.astro <<'EOF'
---
const title = 'Axiolus / Projects';
---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="robots" content="noindex, nofollow, noarchive" />
    <title>{title}</title>
    <style>
      :root{color-scheme:dark;--bg:#0b0c0e;--panel:#121418;--line:#292e37;--ink:#eef0f3;--muted:#9299a6;--accent:#9ff5c1}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.5 ui-monospace,SFMono-Regular,Consolas,monospace}main{width:min(1100px,calc(100% - 32px));margin:auto;padding:48px 0 80px}nav{display:flex;gap:18px;margin-bottom:46px;font-size:.82rem}a{color:var(--accent)}h1{font-size:clamp(2.6rem,8vw,5rem);letter-spacing:-.09em;line-height:.9;margin:0}h2{margin:0;font-size:1.2rem}p{color:var(--muted)}.intro{max-width:700px;margin:18px 0 46px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:12px}.card{border:1px solid var(--line);border-radius:10px;background:var(--panel);padding:19px;transition:transform .18s,border-color .18s}.card:hover{transform:translateY(-3px);border-color:#667080}.top{display:flex;justify-content:space-between;gap:12px}.status{color:var(--accent);font-size:.72rem;letter-spacing:.09em;text-transform:uppercase}.bar{height:5px;border-radius:99px;background:#252b34;margin:20px 0 8px;overflow:hidden}.fill{height:100%;background:var(--accent)}.small{font-size:.82rem}.tags{color:var(--muted);font-size:.76rem}.section{margin-top:56px}.repo{border-left:2px solid #45505e;padding-left:12px}.empty{color:var(--muted);border:1px dashed var(--line);border-radius:10px;padding:18px}
    </style>
  </head>
  <body><main>
    <nav><a href={import.meta.env.BASE_URL}>home</a><a href={`${import.meta.env.BASE_URL}projects/`}>projects</a><a href={`${import.meta.env.BASE_URL}homelab/`}>ax-homelab</a></nav>
    <h1>AXIOLUS<br/>/ PROJECTS</h1><p class="intro">Selected work across Android, native systems, self-hosted AI, automation, and game modification. The repository feed refreshes automatically; the milestone layer stays deliberately human.</p>
    <section><h2>Current focus</h2><div id="featured" class="grid section" aria-live="polite"></div></section>
    <section class="section"><h2>Public GitHub</h2><div id="github" class="grid section" aria-live="polite"></div></section>
  </main><script>
    const base=import.meta.env.BASE_URL; const esc=v=>String(v??'').replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
    const renderStatus=p=>`<article class="card"><div class="top"><h2>${esc(p.title)}</h2><span class="status">${esc(p.status)}</span></div><p>${esc(p.tagline)}</p><div class="bar"><div class="fill" style="width:${Math.max(0,Math.min(100,Number(p.progress)||0))}%"></div></div><div class="small">${esc(p.progress)}% complete</div><p><b>next →</b> ${esc(p.next)}</p><p class="tags">${(p.tags||[]).map(esc).join(' · ')}</p></article>`;
    const renderRepo=r=>`<article class="card repo"><div class="top"><h2>${esc(r.name)}</h2><a href="${esc(r.url)}" target="_blank" rel="noreferrer">GitHub ↗</a></div><p>${esc(r.description)}</p><p class="tags">${[r.language,...(r.topics||[])].filter(Boolean).map(esc).join(' · ')}</p><p class="small">updated ${esc(new Date(r.updatedAt).toLocaleDateString())}</p></article>`;
    Promise.all([fetch(base+'data/project-status.json',{cache:'no-store'}),fetch(base+'data/github-projects.json',{cache:'no-store'})]).then(async([a,b])=>[await a.json(),await b.json()]).then(([status,repos])=>{document.querySelector('#featured').innerHTML=status.map(renderStatus).join('');document.querySelector('#github').innerHTML=repos.length?repos.map(renderRepo).join(''):'<p class="empty">Public GitHub projects will appear here after the first sync.</p>';}).catch(()=>{document.querySelector('#featured').innerHTML='<p class="empty">Project signal unavailable.</p>';});
  </script></body>
</html>
EOF

cat > src/pages/homelab.astro <<'EOF'
---
const title = 'Axiolus / Ax-Homelab';
const capabilities = [
  ['Private AI workspace', 'Conversations, models, tool-assisted workflows, and personal AI experiments.'],
  ['Voice and presence', 'Speech, wake-word experiments, display ideas, and a phone-first companion direction.'],
  ['Automation layer', 'Personal workflows, APIs, notifications, and agent-driven project operations.'],
  ['Personal cloud', 'Self-owned files, media, sync, remote access, and useful services.'],
  ['Development lab', 'Android, native code, web apps, game tooling, mods, and deployed experiments.']
];
---
<!doctype html><html lang="en"><head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width"/><meta name="robots" content="noindex, nofollow, noarchive"/><title>{title}</title><style>:root{color-scheme:dark;--bg:#0b0c0e;--panel:#121418;--line:#292e37;--ink:#eef0f3;--muted:#9299a6;--accent:#9ff5c1}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.5 ui-monospace,SFMono-Regular,Consolas,monospace}main{width:min(1000px,calc(100% - 32px));margin:auto;padding:48px 0 80px}nav{display:flex;gap:18px;margin-bottom:46px;font-size:.82rem}a{color:var(--accent)}h1{font-size:clamp(2.6rem,8vw,5rem);letter-spacing:-.09em;line-height:.9;margin:0}.intro{max-width:690px;color:var(--muted);margin:22px 0 46px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:12px}.card{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:20px}.card:hover{border-color:#667080}h2{font-size:1.05rem;margin:0 0 10px}p{color:var(--muted);margin:0}.signal{margin-top:42px;border-top:1px solid var(--line);padding-top:20px;color:var(--accent);font-size:.82rem}</style></head><body><main><nav><a href={import.meta.env.BASE_URL}>home</a><a href={`${import.meta.env.BASE_URL}projects/`}>projects</a><a href={`${import.meta.env.BASE_URL}homelab/`}>ax-homelab</a></nav><h1>AX<br/>HOMELAB</h1><p class="intro">Axiolus’ personal systems lab: self-owned infrastructure that turns ideas into tools, experiments, and reliable daily services.</p><section class="grid">{capabilities.map(([name,description])=><article class="card"><h2>{name}</h2><p>{description}</p></article>)}</section><p class="signal">● Built, operated, and continuously evolved by Axiolus.</p></main></body></html>
EOF

docker compose up -d --build axio-portfolio
printf '\nDone. Import n8n/axio-github-project-sync.json in n8n, run it manually once, then activate it.\n'
