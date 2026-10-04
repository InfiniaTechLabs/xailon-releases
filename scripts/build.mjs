import { mkdir, readFile, writeFile, copyFile, readdir } from 'node:fs/promises';
import { marked } from 'marked';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const out = path.join(root, 'dist');
await mkdir(path.join(out, 'guide'), { recursive: true });
await copyFile(path.join(root, 'node_modules/@fontsource-variable/manrope/files/manrope-latin-wght-normal.woff2'), path.join(out, 'manrope.woff2'));
for (const name of await readdir(path.join(root, 'site'))) {
  await copyFile(path.join(root, 'site', name), path.join(out, name));
}
for (const name of ['install.sh', 'install.ps1', 'USER_GUIDE.md', 'LICENSE', 'NOTICE']) {
  await copyFile(path.join(root, name), path.join(out, name));
}
const release = JSON.parse(await readFile(path.join(root, 'release.json'), 'utf8'));
await writeFile(path.join(out, 'latest-version.txt'), `${release.version}\n`);
await copyFile(path.join(root, 'release.json'), path.join(out, 'release.json'));
const mark = [' ▄███▄  ', '███ ▀██▄', '████▄▀▀ ', ' ▀██▌   '];
let pixels = '';
mark.forEach((line, row) => [...line].forEach((cell, col) => {
  if (cell === ' ') return;
  const y = row * 2 + (cell === '▄' ? 1 : 0);
  const height = ['▀', '▄'].includes(cell) ? 1 : 2;
  const width = cell === '▌' ? .5 : 1;
  pixels += `<rect x="${col}" y="${y}" width="${width}" height="${height}"/>`;
}));
await writeFile(path.join(out, 'saqr.svg'), `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8" shape-rendering="crispEdges" fill="#526749"><title>Saqr, the Xailon falcon</title>${pixels}</svg>`);
const headings = [];
const slug = text => text.replace(/<[^>]*>/g, '').toLowerCase().replace(/[^a-z0-9\s-]/g, '').trim().replace(/\s+/g, '-');
marked.use({ renderer: {
  heading({ tokens, depth }) {
    const text = this.parser.parseInline(tokens);
    const id = slug(text);
    if (depth === 2) headings.push({ text, id });
    return `<h${depth} id="${id}">${text}</h${depth}>\n`;
  },
  table(token) { return `<div class="table-scroll" role="region" aria-label="Reference table" tabindex="0">${marked.Renderer.prototype.table.call(this, token)}</div>`; }
}});
let markdown = await readFile(path.join(root, 'USER_GUIDE.md'), 'utf8');
markdown = markdown.replace(/- \[Installation\][\s\S]*?- \[Troubleshooting\][^\n]*\n/, '');
let content = marked(markdown).replaceAll('href="install.sh"', 'href="/install.sh"').replaceAll('href="install.ps1"', 'href="/install.ps1"');
const chunks = content.split(/(?=<h2 )/);
content = chunks.map((chunk, index) => index ? `<section class="guide-section">${chunk}</section>` : chunk).join('');
const home = await readFile(path.join(root, 'site/index.html'), 'utf8');
const header = home.match(/<header class="site-header[\s\S]*?<\/header>/)[0].replace('href="#workflow"', 'href="/#workflow"').replace('href="#install"', 'href="/#install"');
const footer = home.match(/<footer class="site-footer[\s\S]*?<\/footer>/)[0];
await writeFile(path.join(out, 'guide/index.html'), `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>User guide — Xailon</title><meta name="description" content="Install and update Xailon on macOS, Windows, and Linux. Learn the CLI, TUI, desktop app, provider setup, and approvals."><link rel="canonical" href="https://xailoncode.infinialabs.ai/guide/"><link rel="icon" href="/saqr.svg" type="image/svg+xml"><link rel="stylesheet" href="/styles.css"><script type="module" src="/app.js"></script></head><body><a class="skip" href="#main">Skip to content</a>${header}<main class="wrap guide-layout" id="main"><aside class="guide-nav"><label for="guide-search">Find in the guide</label><input id="guide-search" type="search" placeholder="Try “provider” or “update”" autocomplete="off"><p class="guide-search-status" id="guide-search-status" role="status"></p><nav aria-label="User guide sections"><ul>${headings.map(({text,id})=>`<li><a href="#${id}">${text}</a></li>`).join('')}</ul></nav><a class="download-guide" href="/USER_GUIDE.md" download>Download the guide (.md) ↗</a></aside><article class="guide-article">${content}</article></main>${footer}</body></html>`);
await writeFile(path.join(out, 'robots.txt'), 'User-agent: *\nAllow: /\nSitemap: https://xailoncode.infinialabs.ai/sitemap.xml\n');
await writeFile(path.join(out, 'sitemap.xml'), '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://xailoncode.infinialabs.ai/</loc></url><url><loc>https://xailoncode.infinialabs.ai/guide/</loc></url></urlset>');
await writeFile(path.join(out, '404.html'), '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Page not found — Xailon</title><link rel="stylesheet" href="/styles.css"><main class="wrap closing"><h1>That page isn’t here.</h1><p>Let’s get you back to the work.</p><a class="button" href="/">Back to Xailon</a></main></html>');
console.log(`Built Xailon website and guide for ${release.version}`);
