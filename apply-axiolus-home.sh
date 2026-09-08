#!/usr/bin/env bash
set -euo pipefail
cd "${1:-$HOME/Ax-Homelab/Website}"
mkdir -p n8n
stamp=$(date +%Y%m%d-%H%M%S)
mkdir -p "backups/$stamp"
cp src/components/{nav,home,projects,contact,footer}.astro src/layouts/Layout.astro src/pages/index.astro "backups/$stamp/"

cat > src/layouts/Layout.astro <<'EOF'
---
const { title } = Astro.props;
---
<!doctype html><html lang="en"><head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><title>{title} | Axiolus</title><meta name="description" content="Axiolus builds self-owned digital systems, Android experiments, AI companions, and homelab infrastructure."/><meta name="robots" content="noindex,nofollow,noarchive,nosnippet"/><meta name="theme-color" content="#05090b"/><link rel="icon" href={`${import.meta.env.BASE_URL}favicon.png`}/></head><body class="bg-[var(--background)] sm:px-28 lg:px-20 px-7"><slot/></body></html>
<style is:global>@font-face{font-family:Mont;src:url('/portfolio/fonts/montserrat-latin-wght-normal.woff2')} :root{--background:#05090b;--component-bg:#081416e8;--sec:#27f6e8;--coral:#ff7a6a;--white:#ddfefa;--white-icon:#b6e7e2a8;--white-icon-tr:#27f6e81a;--line:#27f6e826}*{font-family:Mont,system-ui,sans-serif;box-sizing:border-box;margin:0}*::selection{background:var(--sec);color:var(--background)}html{scroll-behavior:smooth}body{min-height:100vh;background:radial-gradient(circle at 88% 4%,#0c3a3c55,transparent 28rem),radial-gradient(circle at 8% 72%,#063d4a44,transparent 30rem),var(--background);color:var(--white)}</style>
EOF

cat > src/components/nav.astro <<'EOF'
---
const links=[['Home','#home'],['Projects','#projects'],['Contact','#contact']];
---
<nav class="fixed left-1/2 -translate-x-1/2 top-5 z-50 w-[min(720px,88vw)] rounded-full border border-[var(--line)] bg-[var(--component-bg)] backdrop-blur-xl"><div class="flex justify-around p-3">{links.map(([label,href])=><a href={href} class="text-sm text-[var(--white-icon)] hover:text-[var(--sec)] transition">{label}</a>)}</div></nav>
EOF

cat > src/components/home.astro <<'EOF'
---
import LetterGlitch from "../React/LetterGlitch.tsx";
---
<section id="home" class="min-h-[92vh] flex items-center pt-24"><div class="max-w-5xl mx-auto w-full grid lg:grid-cols-[1.35fr_.65fr] gap-12 items-center"><div><p class="tracking-[.25em] text-xs text-[var(--sec)] mb-5">HI, I’M AXIOLUS</p><h1 class="text-5xl md:text-7xl font-medium leading-[.9]">Systems Builder<br/>& Creative<br/><span class="text-[var(--sec)]">Technologist</span></h1><p class="mt-7 max-w-xl text-lg md:text-xl text-[var(--white-icon)]">I build self-owned digital systems—from Android apps and emulator tooling to AI companions, automations, and homelab infrastructure that feels alive.</p><a href="#projects" class="inline-block mt-8 rounded-full border border-[var(--sec)] bg-[#27f6e814] px-6 py-3 text-[var(--sec)] hover:bg-[var(--sec)] hover:text-[#05090b] transition">Explore projects ↓</a></div><div class="h-[290px] rounded-3xl overflow-hidden border border-[var(--line)]"><LetterGlitch client:load glitchColors={["#27f6e8","#14b8a6","#1e8bff"]} glitchSpeed={38} centerVignette={false} outerVignette={true} smooth={true}/></div></div></section>
EOF

cat > src/components/projects.astro <<'EOF'
<section id="projects" class="py-24 border-t border-[var(--line)]"><div class="max-w-5xl mx-auto"><p class="text-[var(--sec)] text-sm tracking-[.18em]">CURRENT SIGNAL</p><h2 class="text-4xl md:text-5xl mt-2">Projects</h2><div id="axiolus-featured" class="grid md:grid-cols-3 gap-4 mt-9"></div><div class="flex justify-between items-end mt-16"><div><p class="text-[var(--sec)] text-sm tracking-[.18em]">AUTOMATIC FEED</p><h3 class="text-3xl mt-2">Public GitHub</h3></div><a href="/portfolio/projects/" class="text-[var(--sec)]">All projects ↗</a></div><div id="axiolus-github" class="grid md:grid-cols-2 gap-4 mt-8"></div></div></section>
<script>const base='/portfolio/';const e=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));const status=p=>`<article class="rounded-2xl border border-[var(--line)] bg-[var(--component-bg)] p-5"><p class="text-xs text-[var(--sec)] uppercase">${e(p.status)}</p><h3 class="text-2xl mt-2">${e(p.title)}</h3><p class="mt-3 text-[var(--white-icon)]">${e(p.tagline)}</p><div class="h-1 bg-[#ffffff12] mt-6"><div class="h-full bg-[var(--sec)]" style="width:${e(p.progress)}%"></div></div><p class="mt-2 text-sm">${e(p.progress)}% · ${e(p.next)}</p></article>`;const repo=r=>`<a class="rounded-2xl border border-[var(--line)] p-5 hover:border-[var(--sec)] transition" target="_blank" rel="noreferrer" href="${e(r.url)}"><p class="text-[var(--sec)] text-sm">${e(r.language||'PROJECT')}</p><h3 class="text-xl mt-2">${e(r.name)} ↗</h3><p class="mt-3 text-[var(--white-icon)]">${e(r.description)}</p></a>`;Promise.all([fetch(base+'data/project-status.json'),fetch(base+'data/github-projects.json')]).then(async x=>[await x[0].json(),await x[1].json()]).then(([a,b])=>{document.querySelector('#axiolus-featured').innerHTML=a.map(status).join('');document.querySelector('#axiolus-github').innerHTML=b.map(repo).join('')||'<p class="text-[var(--white-icon)]">No public projects yet.</p>'})</script>
EOF

cat > src/components/contact.astro <<'EOF'
<section id="contact" class="py-24 border-t border-[var(--line)]"><div class="max-w-5xl mx-auto grid md:grid-cols-2 gap-10"><div><p class="text-[var(--sec)] text-sm tracking-[.18em]">LET’S BUILD</p><h2 class="text-4xl md:text-5xl mt-2">Contact</h2><p class="text-[var(--white-icon)] mt-5 max-w-md">Have an idea, collaboration, or project in mind? Send a signal.</p></div><form id="contact-form" class="space-y-4"><input class="ax-input" name="name" required maxlength="100" placeholder="Name"/><input class="ax-input" name="email" required type="email" maxlength="254" placeholder="Email"/><textarea class="ax-input" name="message" required maxlength="4000" rows="6" placeholder="Message"></textarea><input name="website" tabindex="-1" autocomplete="off" class="hidden"/><input name="startedAt" id="startedAt" type="hidden"/><button class="rounded-xl border border-[var(--sec)] px-5 py-3 text-[var(--sec)] hover:bg-[var(--sec)] hover:text-[#05090b] transition" type="submit">Send message</button><p id="contact-status" class="text-sm text-[var(--white-icon)]"></p></form></div></section><style>.ax-input{width:100%;border:1px solid var(--line);border-radius:.75rem;background:#061315;color:var(--white);padding:.85rem;outline:none}.ax-input:focus{border-color:var(--sec)}</style><script>const f=document.querySelector('#contact-form'),s=document.querySelector('#contact-status');document.querySelector('#startedAt').value=Date.now();f.addEventListener('submit',async ev=>{ev.preventDefault();s.textContent='Sending…';const r=await fetch('/n8n/webhook/axio-contact',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(Object.fromEntries(new FormData(f)))}).catch(()=>null);if(r?.ok){f.reset();s.textContent='Signal received. Thank you.'}else s.textContent='Could not send right now. Please try again later.'})</script>
EOF

cat > src/components/footer.astro <<'EOF'
--- const year=new Date().getFullYear(); ---
<footer class="py-12 border-t border-[var(--line)] text-center text-sm text-[var(--white-icon)]">Built and operated by Axiolus · © {year}</footer>
EOF

cat > src/pages/index.astro <<'EOF'
---
import Layout from '@/layouts/Layout.astro'; import Nav from '@/components/nav.astro'; import Home from '@/components/home.astro'; import Projects from '@/components/projects.astro'; import Contact from '@/components/contact.astro'; import Footer from '@/components/footer.astro';
---
<Layout title="Axiolus"><Nav/><Home/><Projects/><Contact/><Footer/></Layout>
EOF

cat > n8n/axio-contact-form.json <<'EOF'
{"name":"Axio - Public Contact Form","nodes":[{"parameters":{"httpMethod":"POST","path":"axio-contact","responseMode":"responseNode","options":{}},"id":"webhook","name":"Contact Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[300,300],"webhookId":"0a266519-4d7a-46a5-bf7e-89e4237d59fb"},{"parameters":{"jsCode":"const b=$json.body??{}; const clean=v=>String(v??'').trim(); const name=clean(b.name),email=clean(b.email),message=clean(b.message); if(b.website||Date.now()-Number(b.startedAt||0)<1500) throw new Error('Rejected'); if(!name||name.length>100||!/^\\S+@\\S+\\.\\S+$/.test(email)||!message||message.length>4000) throw new Error('Invalid contact form'); const d=$getWorkflowStaticData('global'); const ip=$json.headers?.['x-forwarded-for']||'unknown'; const now=Date.now(); const hits=(d[ip]||[]).filter(t=>now-t<3600000); if(hits.length>=5) throw new Error('Rate limit'); hits.push(now);d[ip]=hits; return [{json:{replyTo:email,subject:`Axiolus contact: ${name}`,text:`From: ${name} <${email}>\\n\\n${message}`}}];"},"id":"validate","name":"Validate and Rate Limit","type":"n8n-nodes-base.code","typeVersion":2,"position":[520,300]},{"parameters":{"fromEmail":"REPLACE_WITH_VERIFIED_BREVO_SENDER","toEmail":"bitsurah@gmail.com","subject":"={{ $json.subject }}","emailFormat":"text","text":"={{ $json.text }}","options":{"replyTo":"={{ $json.replyTo }}"}},"id":"email","name":"Send Contact Email","type":"n8n-nodes-base.emailSend","typeVersion":2,"position":[760,300]},{"parameters":{"respondWith":"json","responseBody":"={\"ok\":true}","options":{}},"id":"respond","name":"Respond Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1000,300]}],"connections":{"Contact Webhook":{"main":[[{"node":"Validate and Rate Limit","type":"main","index":0}]]},"Validate and Rate Limit":{"main":[[{"node":"Send Contact Email","type":"main","index":0}]]},"Send Contact Email":{"main":[[{"node":"Respond Success","type":"main","index":0}]]}},"active":false,"settings":{"executionOrder":"v1"},"tags":[]}
EOF

docker compose up -d --build axio-portfolio
printf '\nDone. Backup: backups/%s\nImport n8n/axio-contact-form.json, configure SMTP, then activate it.\n' "$stamp"
