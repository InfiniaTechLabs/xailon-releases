export function installerCommand(platform, component = 'cli', action = 'install') {
  if (!['macos', 'windows', 'linux'].includes(platform)) throw new Error('Unknown platform');
  if (!['cli', 'desktop', 'all'].includes(component)) throw new Error('Unknown component');
  if (!['install', 'update'].includes(action)) throw new Error('Unknown action');
  const base = 'https://xailoncode.infinialabs.ai';
  if (platform === 'windows') {
    if (component === 'cli' && action === 'install') return `irm ${base}/install.ps1 | iex`;
    return `& ([scriptblock]::Create((irm '${base}/install.ps1'))) -Action ${action} -Component ${component}`;
  }
  const options = [action === 'update' ? 'update' : '', component !== 'cli' ? `--component ${component}` : ''].filter(Boolean).join(' ');
  return `curl -fsSL ${base}/install.sh | sh${options ? ` -s -- ${options}` : ''}`;
}

function initialize() {
  const tabs = [...document.querySelectorAll('[data-platform]')];
  const component = document.querySelector('#component');
  const action = document.querySelector('#action');
  const command = document.querySelector('#command-text');
  const status = document.querySelector('#copy-status');
  let platform = /Win/.test(navigator.platform) ? 'windows' : /Linux/.test(navigator.platform) ? 'linux' : 'macos';
  function update() {
    tabs.forEach(tab => { const active = tab.dataset.platform === platform; tab.setAttribute('aria-selected', String(active)); tab.tabIndex = active ? 0 : -1; });
    command.textContent = installerCommand(platform, component.value, action.value);
    document.querySelector('#install-hint').textContent = platform === 'windows'
      ? 'Run in PowerShell. Native installers may request administrator approval.'
      : platform === 'linux'
        ? 'Run in your shell. Native packages resolve dependencies; desktop is x86-64 only.'
        : 'Run in Terminal. The installer detects Apple Silicon or Intel.';
    document.querySelector('#inspect-script').href = platform === 'windows' ? '/install.ps1' : '/install.sh';
    status.textContent = '';
  }
  if (tabs.length) {
    tabs.forEach((tab, index) => {
      tab.addEventListener('click', () => { platform = tab.dataset.platform; update(); });
      tab.addEventListener('keydown', event => {
        let next;
        if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
        else if (event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length;
        else if (event.key === 'Home') next = 0;
        else if (event.key === 'End') next = tabs.length - 1;
        if (next !== undefined) { event.preventDefault(); tabs[next].click(); tabs[next].focus(); }
      });
    });
    component.addEventListener('change', update); action.addEventListener('change', update);
    document.querySelector('#copy-command').addEventListener('click', async () => {
      try { await navigator.clipboard.writeText(command.textContent); status.textContent = 'Command copied. Paste it into your terminal.'; }
      catch { status.textContent = 'Select the command above and copy it manually.'; }
    });
    document.querySelectorAll('[data-desktop-link]').forEach(link => link.addEventListener('click', () => { component.value = 'desktop'; update(); }));
    update();
  }
  const search = document.querySelector('#guide-search');
  if (search) {
    const sections = [...document.querySelectorAll('.guide-section')];
    const links = [...document.querySelectorAll('.guide-nav li')];
    search.addEventListener('input', () => {
      const query = search.value.trim().toLocaleLowerCase();
      let count = 0;
      sections.forEach(section => { const match = section.textContent.toLocaleLowerCase().includes(query); section.hidden = !match; count += Number(match); });
      links.forEach(item => { const id = item.querySelector('a').hash.slice(1); item.hidden = Boolean(document.getElementById(id)?.closest('.guide-section')?.hidden); });
      document.querySelector('#guide-search-status').textContent = query ? `${count} ${count === 1 ? 'section matches' : 'sections match'} “${search.value.trim()}”.` : '';
    });
    search.addEventListener('keydown', event => { if (event.key === 'Escape') { search.value = ''; search.dispatchEvent(new Event('input')); } });
  }
}
if (typeof document !== 'undefined') initialize();
