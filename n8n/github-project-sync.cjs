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
