import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { installerCommand } from '../site/app.js';

test('install and update commands select the requested component on every platform', () => {
  for (const platform of ['macos','linux','windows']) {
    for (const component of ['cli','desktop','all']) {
      for (const action of ['install','update']) {
        const command = installerCommand(platform,component,action);
        assert.match(command,/https:\/\/xailoncode\.infinialabs\.ai\/install\.(sh|ps1)/);
        if (action==='update') assert.match(command,/update/);
        if (component!=='cli') assert.ok(command.includes(component));
        assert.ok(!command.includes('ExecutionPolicy'));
      }
    }
  }
  assert.throws(()=>installerCommand('unknown'));
});
test('guide headings, internal anchors, and script links resolve', async () => {
  const html=await readFile(new URL('../dist/guide/index.html',import.meta.url),'utf8');
  const ids=new Set([...html.matchAll(/id="([^"]+)"/g)].map(match=>match[1]));
  for (const match of html.matchAll(/href="#([^"]+)"/g)) assert.ok(ids.has(match[1]), `Missing anchor: ${match[1]}`);
  assert.ok(html.includes('href="/install.sh"'));
  assert.ok(html.includes('href="/install.ps1"'));
  assert.ok(!html.includes('CLOUDFLARE_API_TOKEN='));
});
test('installer endpoints are not cached and use plain text', async () => {
  const headers=await readFile(new URL('../dist/_headers',import.meta.url),'utf8');
  for (const endpoint of ['/install.sh','/install.ps1','/latest-version.txt']) {
    assert.ok(headers.includes(`${endpoint}\n  Content-Type: text/plain; charset=utf-8\n  Cache-Control: no-store`));
  }
});

test('copyable install commands are limited to published components', async () => {
  const { platformAvailable } = await import('../site/app.js');
  assert.equal(platformAvailable('macos', 'cli', ['macos'], []), true);
  assert.equal(platformAvailable('macos', 'all', ['macos'], []), false);
  assert.equal(platformAvailable('windows', 'cli', ['macos'], ['macos']), false);
  assert.equal(platformAvailable('macos', 'all', ['macos'], ['macos']), true);
  const home = await readFile(new URL('../dist/index.html', import.meta.url), 'utf8');
  const guide = await readFile(new URL('../dist/guide/index.html', import.meta.url), 'utf8');
  assert.ok(!home.includes('{{CLI_PLATFORMS}}'));
  for (const match of home.matchAll(/href="\/guide\/#([^"]+)"/g)) {
    assert.ok(guide.includes(`id="${match[1]}"`), `Missing feature guide: ${match[1]}`);
  }
});
