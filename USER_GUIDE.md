# XailonCode user guide

For XailonCode **0.2.21** · CLI, terminal UI, and desktop app

- [Installation](#installation)
- [Connect a model](#connect-a-model)
- [Use the terminal UI](#use-the-terminal-ui)
- [Use the command line](#use-the-command-line)
- [Use the desktop app](#use-the-desktop-app)
- [Rich responses and display controls](#rich-responses-and-display-controls)
- [MCP servers and shared Mods](#mcp-servers-and-shared-mods)
- [Live mods](#live-mods)
- [Infinia Marketplace](#infinia-marketplace)
- [Call skills, recipes, and plugins](#call-skills-recipes-and-plugins)
- [Answer clarifying questions](#answer-clarifying-questions)
- [Chat apps: Slack, Teams, and Telegram](#chat-apps-slack-teams-and-telegram)
- [Search past sessions and set reminders](#search-past-sessions-and-set-reminders)
- [Code navigation](#code-navigation)
- [Reuse Claude Code and Codex hooks](#reuse-claude-code-and-codex-hooks)
- [Verification evidence](#verification-evidence)
- [Project privacy and spending](#project-privacy-and-spending)
- [Approvals and workspace access](#approvals-and-workspace-access)
- [Configuration and saved sessions](#configuration-and-saved-sessions)
- [Network proxy](#network-proxy)
- [Updates and removal](#updates-and-removal)
- [Troubleshooting](#troubleshooting)

XailonCode runs its agent and stores sessions on your computer. Prompts and relevant
project content are sent to the model endpoint you configure. Using a remote
provider can incur that provider's charges; a locally hosted endpoint keeps model
requests local. You do not need a XailonCode account.

## Installation

**v0.2.18 availability:** Apple Silicon macOS CLI, TUI, local server, and desktop app.
Windows, Linux, and Intel Mac packages are pending; the commands below document
installer support, not a promise that every platform has a published package.
Check the release asset list before installing. macOS builds are ad-hoc signed
and are not Apple-notarized.

Download from [XailonCode Releases](https://github.com/InfiniaTechLabs/xailon-releases/releases).
Choose the operating system and processor shown in the release asset name.
`aarch64` means ARM64 / Apple Silicon; `x86_64` means Intel/AMD 64-bit.

### One-command install and update

The installer detects your OS and CPU, downloads the selected release, verifies
SHA-256 before running or copying it, and includes the matching sandbox helper.
The default component is the CLI plus TUI. Add the desktop option for the GUI.
Review the script first if you prefer: [install.sh](install.sh) or
[install.ps1](install.ps1).

**macOS / Linux — install CLI + TUI:**

```bash
curl -fsSL https://xailoncode.infinialabs.ai/install.sh | sh
```

**macOS / Linux — install both CLI and desktop, or update both:**

```bash
curl -fsSL https://xailoncode.infinialabs.ai/install.sh | sh -s -- --component all
curl -fsSL https://xailoncode.infinialabs.ai/install.sh | sh -s -- update --component all
```

Use `--component desktop` to install the GUI with the CLI setup tools needed
for provider configuration. `--component all` has the same complete installation. Linux ARM64 currently supports only `--component cli`.
Use `--version v0.2.18` to pin a version and `--dry-run` to see the plan without
changing your machine. Portable CLI installations default to `~/.local/bin`;
`--prefix /absolute/path` chooses another prefix. Native Linux package
installations use their system locations instead.

**Windows PowerShell — install CLI + TUI:**

```powershell
irm https://xailoncode.infinialabs.ai/install.ps1 | iex
```

**Windows PowerShell — install or update both:**

```powershell
& ([scriptblock]::Create((irm 'https://xailoncode.infinialabs.ai/install.ps1'))) -Component all
& ([scriptblock]::Create((irm 'https://xailoncode.infinialabs.ai/install.ps1'))) -Action update -Component all
```

Windows accepts `-Component cli|desktop|all`, `-Version v0.2.18`, and `-DryRun`.
It uses native MSI installers and installs the Microsoft Visual C++ runtime if
missing, checking Microsoft's Authenticode signature first. The desktop MSI
handles WebView2. Native package installation can ask for administrator approval.
Linux uses apt/dnf where available; portable AppImage installation extracts the
app so FUSE is not required. The scripts do not install Rust or Node.js.

Close XailonCode before an update and reopen it afterward. Configuration and saved
sessions are retained. Use the same component selection when updating as when
installing. On macOS, the installer updates an existing desktop app in your user
Applications folder or `/Applications`; a new install uses `~/Applications`.

### Verify a download

Download the package and its matching `.sha256` file into the same folder.
On macOS, for example:

```bash
shasum -a 256 -c xailon-aarch64-apple-darwin.tar.bz2.sha256
```

On Linux, use `sha256sum -c` instead of `shasum -a 256 -c`.
The result must say `OK` before you install. On Windows, run:

```powershell
Get-FileHash .\xailon-x86_64-pc-windows-msvc.zip -Algorithm SHA256
Get-Content .\xailon-x86_64-pc-windows-msvc.zip.sha256
```

Compare the full hash, ignoring letter case. A mismatch means the download does
not match the published package: download it again rather than running it.
The combined `SHA256SUMS` contains hashes for every asset in the release.

### macOS

Apple Silicon packages require an Apple Silicon Mac. Use the Intel package on an
Intel Mac. The release notes identify the build's minimum macOS version and the
platforms actually tested.

**Desktop:** verify the `.dmg`, open it, and drag **Xailon Desktop** into
**Applications**. Run `xailon configure` after installing the CLI below, then open
the app. The app uses the same saved model configuration as the CLI.

**CLI / TUI:** use the `.pkg` installer if attached, or extract the archive into a
new folder and install its binaries:

```bash
mkdir -p xailon-download "$HOME/.local/bin"
tar -xjf xailon-aarch64-apple-darwin.tar.bz2 -C xailon-download
install -m 755 xailon-download/xailon xailon-download/xailond "$HOME/.local/bin/"
export PATH="$HOME/.local/bin:$PATH"
xailon --version
```

Substitute `x86_64` in the archive name for an Intel Mac. Add the `export PATH`
line to your shell profile to keep it for future terminals. The `.pkg` instead
installs to `/usr/local/xailon/bin` and creates links in `/usr/local/bin`.

The initial preview is not Apple-notarized. If macOS blocks an unnotarized app,
review the release and checksum, then follow Apple's per-app instructions in
[Safely open apps on your Mac](https://support.apple.com/en-lamr/102445).
After an attempted launch, the per-app exception appears in **System Settings →
Privacy & Security → Open Anyway** when available. Do not disable Gatekeeper globally.

### Linux

The CLI packages target glibc-based distributions with glibc 2.35 or newer.
Choose x86-64 or ARM64 to match `uname -m`.

For Debian/Ubuntu, install the downloaded CLI `.deb`. For an x86-64 desktop,
install both packages together so the desktop can use the CLI's sandbox helper:

```bash
sudo apt install ./xailon-x86_64-unknown-linux-gnu.deb
sudo apt install ./xailon-desktop-x86_64-unknown-linux-gnu.deb
```

For RPM-based distributions, use `sudo dnf install ./xailon-<target>.rpm` with the
actual downloaded filename. An AppImage is also offered for the x86-64 desktop
when listed in the release:

```bash
chmod +x xailon-desktop-x86_64-unknown-linux-gnu.AppImage
./xailon-desktop-x86_64-unknown-linux-gnu.AppImage
```

A CLI tarball install must keep **all three executables together**: `xailon`,
`xailond`, and `xailon-linux-sandbox`. Do not omit the helper. The native packages
also install the AppArmor integration where supported; prefer them on systems
that restrict unprivileged user namespaces. Do not turn off sandbox protections
to work around a missing helper.

### Windows

Use the x86-64 `.msi` for the CLI and the separate desktop `.msi` for the GUI.
The CLI installer adds its directory to the machine PATH. Open a new PowerShell
window after installation and run `xailon --version`.

For a portable CLI install, extract the `.zip` into a permanent directory and keep
`xailon.exe`, `xailond.exe`, and `xailon-windows-sandbox.exe` together. Add that
directory to your user PATH. Do not run directly inside the compressed-folder view.
Unsigned packages may display a Windows publisher warning. Check the release
notes and checksum before deciding whether to run the downloaded software.

## Connect a model

The recommended setup is interactive:

```bash
xailon configure
xailon info --check
```

Choose your provider and a model that your account or server actually supports.
Saved settings are shared with the desktop app. API keys use the operating
system keyring by default. XailonCode does not automatically load `.env` files.

For a shell-only OpenAI-compatible setup:

```bash
export XAILON_PROVIDER=openai
export XAILON_MODEL="your-model-id"
export OPENAI_BASE_URL="https://your-provider.example/v1"
export OPENAI_API_KEY="your-provider-key"
xailon info --check
```

Replace every placeholder. For OpenAI's endpoint, use
`https://api.openai.com/v1`. For a local OpenAI-compatible endpoint, use its local
URL and model id; set a nonempty placeholder key only when that server does not
require authentication. PowerShell uses `$env:XAILON_PROVIDER = "openai"` and the
same `$env:NAME = "value"` syntax for the other variables.

### Custom endpoints

Connect any OpenAI-, Anthropic-, or Ollama-compatible server, such as a company
gateway, an inference provider, or a model server on your machine. On first run,
`xailon configure` offers **OpenAI-Compatible Endpoint**. Later, choose
**Custom Providers → Add A Custom Provider**.

1. Choose the API format, a display name, and the endpoint URL, for example
   `https://api.example.com/v1` or `http://localhost:8000/v1`.
2. Enter an API key if the endpoint requires one. It is stored in the keyring.
3. XailonCode asks the endpoint for its models and shows every model it serves.
   Type to search when the list is long, then choose a default.
4. If the endpoint does not list its models, enter model ids separated by commas.

The model list stays current after setup. Each new desktop or client session
reloads it from the endpoint, and running `xailon configure` for the provider
fetches it again. Models added on the server appear without editing
configuration; models the server no longer lists disappear from the picker. If
the endpoint cannot be reached, the last loaded list is kept. Custom providers
set up before 0.2.15 also refresh this way.

Applications launched from Finder or the Windows Start menu do not necessarily
inherit shell exports. Persist your settings with `xailon configure` for desktop
use, then restart the app if you changed its provider configuration.

## Use the terminal UI

```bash
cd your-project
xailon tui
```

The Saqr falcon appears in the welcome screen. Describe a concrete task, for
example: “Explain the request routing, then propose a test for missing input.”
Review edits and test results before accepting them into your project.

| Key | Action |
| --- | --- |
| Enter | Send; while the agent is working, steer the running turn with your message |
| Tab while the agent is working | Queue the message to send after the turn |
| Alt+Enter, Shift+Enter, or Ctrl+J | Insert a newline; terminal support varies |
| `/` | Browse commands |
| `@` | Find and attach a project file |
| Up / Down in a popup | Select a suggestion; the list scrolls with selection |
| Tab in a popup | Complete the selected command or file |
| Enter in a popup | Run the command or insert the file |
| Esc | Close a popup, or interrupt a running turn |
| Ctrl+T | Open the transcript pager; `q` closes it |
| Ctrl+O | Cycle tool output: collapsed, expanded, hidden |
| Ctrl+L | Show or hide the todo panel |
| Ctrl+G | Move focus through open mod panes; Esc returns to the composer |
| PgUp / PgDn | Scroll the transcript |
| Ctrl+V or Alt+V | Paste an image when supported |
| Ctrl+D | Quit with empty input while idle |

Useful commands:

| Command | Purpose |
| --- | --- |
| `/help` | Commands and keyboard shortcuts |
| `/model` | Select a model |
| `/plan [task]` | Plan first: read-only until you approve the plan |
| `/permission` | Choose Read only, Ask, Auto, or Full access |
| `/mode` | Set `auto`, `approve`, `smart_approve`, or `chat` |
| `/goal <text>` | Set a goal the agent must reach; `/goal` shows it, `/goal off` clears it |
| `/details` | Show tool calls collapsed, expanded, or hidden, and reasoning on or off |
| `/plugins` | Add the Infinia Marketplace, then browse and install plugins |
| `/<name>` | Run a skill, recipe, or command by name; `@name` also calls it |
| `/mods` | Open shared plugin Markdown panels |
| `/evidence` | Inspect the latest verification report and check freshness |
| `/routing` | Show the active model route and estimated spending |
| `/status` | Session, model, context, and usage details |
| `/diff` | Review the workspace's Git diff |
| `/compact` | Summarize the conversation to free context |
| `/resume` | Choose a previous session |
| `/clear` | Clear the conversation |
| `/exit` | Quit |

While a turn runs, the status line names what the agent is doing (waiting for the
model, thinking, responding, or running a tool) with a timer for that step and the
total. Messages you send with Enter join the running turn, so you can correct course
without interrupting; press Tab instead to queue a message for afterwards.

The latest todo list stays pinned above the input, with done, in-progress, and
pending items, until you send your next message. With `/plan`, the finished plan
opens in a review dialog: scroll with PgUp/PgDn, then **Approve**, **Refine** with
feedback, or **Stay** in plan mode. The status line also shows the active
permission preset and any goal.

Use `xailon tui --inline` to keep completed output in terminal scrollback.
Use `xailon tui --resume` to resume the most recent session. Set
`XAILON_DEFAULT_UI=tui` to make a bare `xailon` open the TUI in an interactive terminal.

## Use the command line

```bash
xailon session                         # interactive line-mode interface
xailon exec "Explain the test setup"  # one task for scripts
xailon exec "Review this project" --sandbox read-only
xailon session list                    # saved sessions
xailon session search "rate limiter"   # full-text search of past sessions
xailon --help
```

The line-mode interface also shows Saqr. Enter sends, Ctrl+J inserts a newline,
Tab completes, and Ctrl+D exits. `xailon --plain` selects the line interface even
when the TUI is your default.

For structured output:

```bash
git diff | xailon exec "Review this diff" --json
```

`exec` writes the final answer to stdout and progress to stderr. With `--json`,
stdout contains JSONL protocol events and the final summary. It never asks for
interactive approval: an action requiring approval is denied. Exit codes include
`0` for success, `2` for configuration/argument errors, `4` for denied actions,
`5` for provider/authentication errors, and `130` for interruption.

`xailond` is the optional local HTTP server. The desktop app runs its engine in
process, so starting `xailond` is not required to use the GUI.

## Use the desktop app

1. Configure your provider with the CLI, then launch **Xailon Desktop**.
2. Under **Open a project**, choose **Browse folders…**, or enter a folder path
   and select **Add project**. Canceling the picker leaves the form available;
   an invalid path stays in the field so you can correct it.
3. Select the project and start a thread. Give the thread a clear task.
4. Read the conversation and tool results. Use **Review changes** for diffs and
   **Terminal** when you need a shell.
5. Answer approval requests deliberately. Pending requests also appear in
   **Approvals** in the sidebar.
6. Open **Settings** to choose System, Light, or Dark appearance, and to review
   model, sandbox, and approval settings.

Select **Activity & Tasks** in the toolbar to open a side panel with
**Activity**, **Tasks**, and **Output** tabs. Activity is a timeline of the
current request's tool calls and reasoning summaries, using your display
preferences. When the agent writes a task plan, it appears as a plan card with
completion counts; only the latest plan per request stays in the conversation,
and earlier versions remain in Activity. Failed plan updates stay visible. Use
the arrow keys to move between tabs and Esc to close the panel.

Reopening a thread shows its earlier messages, the latest 200 at first; select
**Show earlier messages** at the top for more.

To attach files, paste an image, drag files onto the message box, or select the
paperclip. Images are sent to the model as images (the app warns when the model
cannot read them); other files are passed by path. Each file can be up to 20 MB.

When a turn changes files, a card at its end lists them with lines added and
removed. Select a file to see that turn's diff, or **Review all** for the whole
thread. File names in the answer that match a changed file open its diff too.

**Settings → Models** lists your providers. Enter or replace an API key (it is
stored in the keyring and never shown again), add a custom OpenAI-compatible
endpoint and fetch its models, and choose the active provider. The model picker in
the message bar switches the current thread's model and reasoning effort from its
next turn.

Enter sends a message; Shift+Enter adds a newline. Esc interrupts a running turn.
On macOS, Cmd+1 opens Threads, Cmd+2 Approvals, Cmd+3 Automations, Cmd+4 Skills &
plugins, and Cmd+, Settings. Use Ctrl instead of Cmd on Windows/Linux.

Forms have visible labels, keyboard focus outlines, and consistent controls.
Use Tab and Shift+Tab to move through fields and buttons. Native file pickers
keep your operating system's keyboard behavior.

**Automations** lets you create scheduled tasks. Check the selected project,
prompt, schedule, and enabled state before saving. Use **Run now** to test an
automation and inspect its result. The application must be running for its
in-process scheduler to execute tasks.

**Open a document folder…** creates a Cowork project for reports and documents.
Its container-based tools may require Docker or Podman; installing XailonCode alone
does not install a container runtime.

## Rich responses and display controls

Desktop conversations render Markdown tables, task lists, strikethrough, links,
headings, lists, quotes, highlighted code blocks, and mathematical notation.
Wide tables scroll horizontally; code blocks include **Copy code**.

Open **Response display** above the conversation:

- **Stream responses** shows text as it arrives. Turn it off to show responses when the turn finishes.
- Set **Tool calls** and **Reasoning** independently to **Expanded**, **Collapsed**, or **Hidden**.
- **Collapse all tool calls** folds existing tool output in one action.

These preferences change presentation only. Approvals and errors remain visible.
Reasoning shows only summaries supplied by the provider, when available.

## MCP servers and shared Mods

Open desktop **Extensions → MCP servers → Add MCP server**. Choose a local process
(executable plus one argument per line) or a remote **Streamable HTTP** endpoint.
Legacy SSE is not supported. Credential rows store references to Xailon's secret
store, rather than placing secret values in the server configuration.

**Save server** saves configuration without starting it. **Test saved connection**
starts the saved process or connects to the remote server, initializes MCP, and
lists tools without invoking them. Expand a tool to inspect its input schema.
You can enable, disable, edit, or remove servers. Start a new thread to load changes.

Under **Extensions → Plugins & hooks**, enter a Git URL or `plugin@marketplace`,
optionally pinned to a branch, tag, or commit. **Review changes** shows the source,
exact commit, changed files, and contributed executable hooks and MCP servers.
Runnable code requires explicit acknowledgement. **Review update** lets you
inspect an update before applying its reviewed snapshot.

**Extensions → Mods** displays shared Markdown panels. Use `xailon mods` in the
CLI or `/mods` in the TUI; append `plugin/panel` to open a specific panel.
Static mods add typed lifecycle hooks and Markdown panels; [live mods](#live-mods)
add an interface that updates as you work. XailonCode does not load Claude Code
TypeScript function modules; those need porting to Xailon's protocols.

## Live mods

A live mod adds its own interface to XailonCode:

- **Panes** with text, lists, tables, progress bars, sparklines and buttons.
- **A band** above the prompt.
- **A status line entry** and **toasts**.
- **Slash commands.**

It runs as a Node.js process for each session. It hears what happens in the session (prompts, turns, tool calls, changed files, todos and token totals) and redraws as it goes. Live mods need Node.js 22 or later on your `PATH`, or set `XAILON_NODE` to the `node` to use.

Install a live mod like any plugin, from a marketplace or a Git URL. The install
review lists its panes, commands, band and status entry, and shows
`live mod: node <script>` under the code that runs. A mod runs with your
permissions, so install only mods you trust. Each mod can show only what its manifest declares;
anything else it sends is dropped and noted in its log.

**In the terminal UI:**

- Right panes open in a sidebar when the terminal is at least 110 columns wide, and
  at the bottom when it is narrower. Bands sit above the prompt, status entries
  appear on the status line, and toasts at the top right.
- **Ctrl+G** moves focus through the open panes; Esc or another Ctrl+G past the last
  pane returns to the composer. In a focused pane, a button's key presses it, Enter
  activates the selected row, and other keys go to the mod. Clicking a button works
  too.
- A mod's commands appear when you type `/`. A name that clashes with another
  command becomes `/<plugin>:<name>`.

| Command | Purpose |
| --- | --- |
| `/mods` | List live and static mods with their state, panes and commands |
| `/mods open <plugin>/<pane>` | Open a pane |
| `/mods close <plugin>/<pane>` | Close a pane |
| `/mods restart <plugin>` | Restart a mod |
| `/mods logs <plugin>` | Show a mod's recent log lines |

**In the desktop app**, each thread runs its own mods. Panes open in docks beside
and below the conversation, status entries show as chips in the thread header, and
mod commands appear in the composer's slash menu. **Extensions → Mods** shows each
live mod's state, panes, commands and logs, with a restart button.

If a mod crashes, its panes, band and status entry disappear. XailonCode restarts it
after 1, 2, then 4 seconds, at most three times a minute. After that it stays
stopped until `/mods restart`.

### Write a live mod

A live mod is a folder with an `xailon.mod.json` manifest and a Node script. It
speaks newline-delimited JSON-RPC 2.0 over stdin and stdout, and writes anything
else to stderr. While you work on it, load it without installing:

```bash
xailon --mod-dir ./hello-pane
```

XailonCode restarts the mod when a file in the folder changes. This one counts the
session's tool calls in a right pane, with a reset button, a status entry, and a
`/tools-reset` command.

`hello-pane/xailon.mod.json`:

```json
{
  "api_version": 2,
  "name": "hello-pane",
  "description": "Counts this session's tool calls",
  "runtime": { "node": "mod.mjs" },
  "panes": [{ "id": "tools", "title": "Tools", "placement": "right", "open": true }],
  "commands": [{ "name": "tools-reset", "description": "Reset the tool counter" }],
  "status": true
}
```

`hello-pane/mod.mjs`:

```js
import { createInterface } from "node:readline";

const send = (message) => process.stdout.write(JSON.stringify({ jsonrpc: "2.0", ...message }) + "\n");
const notify = (method, params) => send({ method, params });
let calls = 0;

const draw = () => {
  notify("ui/pane/render", {
    id: "tools",
    tree: {
      type: "box",
      children: [
        { type: "text", spans: [{ text: `Tool calls: ${calls}`, fg: "accent", bold: true }] },
        { type: "button", id: "reset", label: "Reset", key: "r" },
      ],
    },
  });
  notify("ui/status/set", { text: `tools ${calls}` });
};

createInterface({ input: process.stdin }).on("line", (line) => {
  const message = JSON.parse(line);
  if (message.method === "initialize") send({ id: message.id, result: { api_version: 2 } });
  if (message.method === "event" && message.params.type === "tool_started") calls += 1;
  if (message.method === "ui/action" || message.method === "command/run") calls = 0;
  if (message.method === "command/run") send({ id: message.id, result: { markdown: "Counter reset." } });
  if (message.method === "shutdown") process.exit(0);
  if (["event", "ui/action", "command/run"].includes(message.method)) draw();
});
```

The host sends `initialize` (answer with `{ "api_version": 2 }`), `event` notifications, `ui/action` (a button or list item was activated), `ui/key`, `command/run` (answer with `{ "markdown" }` or `{ "insert" }`) and `shutdown`.

The mod sends these notifications:

| Notification | What it does |
| --- | --- |
| `ui/pane/render` | Draw a pane |
| `ui/pane/open`, `ui/pane/close` | Show or hide a declared pane |
| `ui/band/render` | Draw the band; `tree: null` removes it |
| `ui/status/set` | Set the status line entry |
| `ui/toast` | Show a toast |
| `composer/insert` | Put text in the composer; it is never sent by itself |
| `log` | Write a line to the mod's log |

A pane, band or status entry the manifest does not declare is dropped.

The `event` types are:
- `session_start` and `session_end`
- `prompt_submitted`
- `turn_started`, `turn_completed` and `turn_failed`
- `tool_started` and `tool_completed`
- `file_changed`
- `todos_updated`
- `usage`: running session totals, not the current context size
- `model_changed`
- `approval_requested`
- `pane_visibility`

A tree is made of `box` (rows or columns with `gap`, `padding`, `border`, `title`, `grow`, `width` and `height`), `text` (styled `spans`), `markdown`, `list`, `table`, `progress`, `sparkline`, `button`, `divider` and `spacer` nodes.

Colors can be:
- theme colors: `accent`, `muted`, `success`, `warning`, `error`, `info`
- standard names such as `red`
- `#rrggbb` hex values

Limits:

| Limit | Maximum |
| --- | --- |
| Panes per mod | 8 |
| Commands per mod | 16 |
| Tree depth | 16 levels |
| Nodes per tree | 2,000 |
| Text per tree | 64 KiB |
| Message size | 1 MiB |

## Infinia Marketplace

The [Infinia Marketplace](https://xailon-marketplace.infinialabs.ai/) is a curated
catalog of plugins, skills, and MCP servers. Each entry is pinned to a reviewed
commit. Add it once, then install plugins by name. Every install shows the source,
the pinned commit, and any code the plugin can run, and code-running plugins need
your approval.

- **Terminal UI:** type `/plugins`. While the marketplace is missing, the first
  entry adds it. Type to filter, then press Enter on a plugin to review it, and
  choose **Install** or **Cancel**. Installed plugins are labeled. You can also use
  `/plugins add` and `/plugins install github@infinia`.
- **Desktop:** open **Extensions → Plugins & hooks**. Under **Marketplaces**, select
  **Add Infinia Marketplace**, or **Browse catalog** to open the website. Search the
  plugins and select one to review it. **Add another marketplace** accepts any
  marketplace repository URL.
- **CLI:**

```bash
xailon plugin marketplace add          # the Infinia Marketplace; same as `add infinia`
xailon plugin install frontend-design@infinia
```

Installed plugins load in new sessions. Some MCP plugins need credentials or tools,
such as a GitHub token or Docker, as listed on their catalog page.

## Call skills, recipes, and plugins

Every skill, recipe, and command, including those from installed plugins, can be
called by name:

- Start a message with `/name` to run it, with the rest of the line as its input:
  `/youtube-production a video about ocean tides`.
- Write `@name` anywhere in a message to call it with the rest of the message as its
  input: `@frontend-design build a pricing page`. A path such as `@src/main.rs` is
  still a file mention.

A recipe plugin's main recipe runs as `/<plugin name>`. As you type `/` or `@`, the
terminal UI and the desktop app suggest matching skills, recipes, and commands, each
labeled by kind; the line-based CLI completes them with Tab. A plugin you install from
`/plugins` can be called in the same session.

## Answer clarifying questions

When XailonCode needs a detail before it starts, it asks a few questions with
suggested answers instead of guessing.

- **Terminal UI:** the questions appear one at a time. Use ↑/↓ to choose, or start
  typing for your own answer. Enter moves to the next question, ← goes back, and Esc
  lets you answer in the chat instead.
- **Desktop:** pick an option or type an answer for each question in the card under
  the message, then select **Send answers**.
- **CLI:** answer each question in a picker; choose **Other** to type, or **Skip** to
  leave it to XailonCode.
- **Slack, Teams, and Telegram:** the questions arrive as a numbered list with lettered
  options. Reply with your picks, such as `1a, 2b`, or in your own words.

Your answers are sent as your next message, and unanswered questions are left to
XailonCode's judgment.

## Chat apps: Slack, Teams, and Telegram

A gateway connects a chat app to the agent running on your computer. Nothing is
hosted for you, and the platform credentials stay on your machine.

```bash
export XAILON_SLACK_BOT_TOKEN=xoxb-...   # bot token
export XAILON_SLACK_APP_TOKEN=xapp-...   # app-level token for Socket Mode
xailon gateway start slack               # runs until Ctrl+C
xailon gateway pair slack                # one-time code; send it to the bot in a DM
```

Telegram uses `xailon gateway start telegram --bot-token ...`; Teams uses
`--app-id` and `--app-password` and needs an HTTPS tunnel to its local endpoint.
Pass tokens through environment variables rather than flags, so they do not appear
in your process list or shell history.

In Slack, direct messages and @mentions reach the agent. Replies use Slack
formatting, and tool approvals arrive as **Approve** and **Deny** buttons that only
the person who asked can press.

## Search past sessions and set reminders

XailonCode keeps a full-text index of your saved sessions. Search it yourself:

```bash
xailon session search "migration plan"            # sessions from this folder
xailon session search "oauth" --all-dirs -f json  # every folder, as JSON
```

The agent can search and read earlier sessions from the same folder on its own,
for example when you ask "what did we decide about caching last week?".

Reminders let the agent pick a conversation back up later: "check the deploy in 20
minutes" or "every weekday at 9:00, summarize open pull requests". A reminder
resumes the same session with its instruction as a new message. They are off by
default: start a session with `xailon session --with-builtin reminders`, or type
`/builtin reminders` in a line-mode session. Reminders fire only while
`xailond` is running, a missed reminder fires once when it starts again, and
repeating reminders must be at least a minute apart.

```bash
xailon schedule reminders                 # list reminders
xailon schedule cancel-reminder <id>      # cancel one
```

## Code navigation

When a language server is configured for your project, the agent can jump to a
symbol's definition, find its references and implementations, and read its hover
documentation, instead of guessing from text search. Results list file paths and
line numbers and are capped for very common symbols. This uses the same language
servers and trust rules as diagnostics.

## Reuse Claude Code and Codex hooks

Command hooks you already wrote for Claude Code or Codex run in XailonCode without
changes. It reads `~/.claude/settings.json` and `~/.codex/hooks.json` (or the hooks
tables in `~/.codex/config.toml`), plus the same files in a project's `.claude` and
`.codex` folders once you trust that folder. Hooks can block a tool call or prompt,
add context, or ask the agent to continue, as they do there.

Set `XAILON_CLAUDE_CODE_HOOKS=false` or `XAILON_CODEX_HOOKS=false` to stop loading
either source. Hook types other than commands are skipped with a warning.

## Verification evidence

Xailon records command outcomes and the observed Git workspace for turns run through
its shared engine (desktop, TUI, and `xailon exec`). This is the first part of
verified delivery: inspect what ran and whether its recorded file contents still
match. A report is not a certificate that the user's task is complete.

### Inspect a report

- **Desktop:** each finished turn has a Verification evidence card. Expand
  Commands and revision to inspect exit codes, output excerpts, commit and workspace
  fingerprint. Recheck workspace compares files without rerunning commands. Copy
  report JSON exports the displayed report. A resumed conversation can load its
  latest saved evidence.
- **TUI:** `/evidence` loads the latest report and compares the workspace again.
- **CLI:** `xailon evidence SESSION_ID` shows the latest report and checks current
  files; add `--json` for the complete report.
- **Automation:** `xailon exec --json` emits `verification_report` before
  `turn_completed` or `turn_failed`. The final answer still goes to stdout in text
  mode; the evidence summary goes to stderr and respects `--quiet`.

### Status meanings

| Status | Meaning |
| --- | --- |
| Passed at capture | Tool-reported exit code was zero, command completed, and the observed workspace files matched before and after the command and at report creation. |
| Failed | Nonzero exit code, failed command, or declined execution. |
| Stale | Workspace contents changed during or after a successful command. Rerun the relevant checks to obtain fresh evidence. |
| Unverified | Missing exit code, unfinished command, or unavailable workspace snapshot. |

Only conservative command patterns count in the check summary: Cargo tests/checks/
Clippy, `cargo fmt --check`, Go tests/vet, pytest/unittest, Node's test runner,
and common npm/pnpm/yarn test, lint, typecheck, build and check scripts. Commands
containing shell control operators are not recognized checks. Other commands are
still listed. Check recognition does not establish test coverage or correctness;
a script named `test` can do anything. Tool output text cannot supply a missing
exit code.

Open plan steps, failed tools, interrupted turns and unavailable workspace
information appear under Needs review. Empty reports explicitly say that no
recognized checks were recorded.

### Storage and scope

Reports are private local JSON files in the `evidence` directory beside the session
store. Unique report IDs preserve earlier reports when a session resumes. The
original report is retained; rechecking changes the displayed/exported copy.
`xailon exec --no-session` emits evidence but does not save report files.

The SHA-256 fingerprint includes tracked and non-ignored Git files, their paths,
contents and executable bits on Unix. Commit IDs are recorded separately: committing
unchanged contents does not invalidate a result. Capture has a two-second / 256 MiB
limit; unsupported paths, submodules, non-Git folders and capture failures remain
unverified. Symlink targets are recorded, but their external contents are not.

Snapshots are observations at event boundaries, not an atomic filesystem snapshot
or signed attestation. Ignored files, dependencies outside the repository, services,
environment variables and remote execution are outside the fingerprint. Check
commands and exit codes are supplied by the tool adapter; third-party tools are
not independently attested. Background commands without a final exit code remain
unverified. Reports currently do not collect screenshots, full test artifacts, or
independent task acceptance results. Manually verify those when relevant.

Reports include command strings, local paths and up to 4,000 characters of each
command's output. Review exports before sharing them. External edits are detected
when you recheck; the desktop does not continuously monitor historical reports.


## Project privacy and spending

XailonCode can pin a project's model requests to a local OpenAI-compatible server,
allow an explicitly approved cloud profile, and enforce estimated spending limits.
Projects without a policy keep their existing provider configuration.

### Desktop

Select a project and open **Settings → Privacy & spending**. Configure the local
endpoint and model you have installed. Choose **Local only** or **Cloud allowed**.
Cloud mode requires a cloud profile and an explicit consent checkbox before saving.
Editing a profile or budget clears that checkbox.

A saved policy applies when a session first acquires its routing policy. Sessions
that already have a policy keep their snapshot, including after a restart. Start a
new thread to change a pinned model, endpoint, or budget. The conversation's routing
summary shows the active model, endpoint, reason, estimated committed spending,
and unresolved requests. Expand it for per-turn and session limits.

### CLI and TUI

Save this as `routing.json`, replacing the model with one available on your local
server. Endpoint values are origins: omit `/v1`, paths, queries, and credentials.
The local server must already be installed and running.

```json
{
  "mode": "local_only",
  "local": {
    "endpoint": "http://127.0.0.1:11434",
    "model": "qwen3",
    "api_key_env": null,
    "input_usd_per_million": 0,
    "output_usd_per_million": 0
  },
  "cloud": null,
  "sensitive_paths": [".env", ".env.*", "**/.env", "**/.env.*", "secrets/**"],
  "task_budget_usd": null,
  "session_budget_usd": null,
  "max_output_tokens": 4096
}
```

```sh
xailon routing --project /path/to/project --policy routing.json
xailon routing --project /path/to/project
```

`--project` defaults to the current directory. To use cloud mode, set `mode` to
`cloud_allowed`, add a `cloud` profile with the same fields as `local`, and pass
`--approve-cloud` when saving. Cloud origins require HTTPS, except loopback fixture
servers. Store only an environment variable name in `api_key_env`; Xailon reads the
secret from its process environment. Desktop apps launched from Finder may not
inherit your shell's variables.

In the TUI, `/routing` shows the latest route and usage summary. Plain-text execution
prints summaries to stderr; JSON execution emits additive `routing_status` events.
`/model` and protocol model switching refuse changes to pinned project routes.

### Privacy behavior

- Local origins must use a literal loopback address or `localhost`. Xailon disables
  HTTP proxies for local requests and refuses HTTP redirects for both profiles.
- There is **no automatic cloud fallback** after local errors. Cloud approval is a
  project-setting action followed by a new session, never an agent tool decision.
- Any matching sensitive path locks the **whole session** to the local profile,
  including future requests after the path is removed. Hidden and ignored paths
  are included. Paths are not redacted and then sent to cloud.
- Scans that fail, exceed 100,000 entries or two seconds, or encounter a symlink
  choose local. Empty pattern lists disable sensitive-path scanning. Globs are
  relative to the project/workspace; use `secrets/**` for a directory's contents.
- Policies are private user configuration, outside the repository, indexed by
  canonical project path. Subdirectories and Xailon's managed worktrees inherit
  the nearest project policy. Both the original project and active workspaces are
  scanned. Moving a project requires saving its policy at the new location.
- Delegated agents inherit the guarded provider and share its spending ledger.
  Their workspaces join the sensitive-path scan. An agent cannot overwrite a
  session that already owns a different routing ledger.

This controls model requests through the session provider. It is **not operating
system network isolation**: tools, MCP servers, hooks, extensions, telemetry, and
independently configured services can still use the network. A loopback server can
itself proxy to cloud; use a server/model you trust to perform local inference.
Model names containing `cloud` are rejected for local profiles, but that check
cannot attest where inference actually runs. Files outside scanned workspaces and
sensitive text pasted into prompts are not classified. Use Local only when unsure.

### Estimated budgets

`task_budget_usd` limits a user turn, including provider calls for naming,
compaction, and delegated agents charged during that turn. `session_budget_usd`
accumulates across turns and resumes. Delegates cannot reset the parent's turn
budget. Output is bounded by `max_output_tokens` for each model request.

Before transmitting, Xailon durably reserves estimated input and maximum output
cost under a file lock. A clean response with usage settles that reservation using
the configured input/output rates. Cancellation, failure, or missing usage keeps
the reservation because the request may have been billed. A later turn resets only
its turn counter. Session spending and unresolved reservations remain. Provider
retries are disabled; another attempt requires another reservation.

These are **estimated spending limits, not invoice caps**. Prices are user-supplied
USD per million tokens and must be present for every configured profile if a budget
is set. Input reservations use serialized request bytes plus an overhead allowance;
provider tokenization, images, caching, reasoning charges, and other billing rules
can differ. A reported cost can exceed a reservation; subsequent requests are then
blocked. Unpriced routes cannot enforce budgets and their displayed totals are
incomplete. Zero prices explicitly treat that profile as free.

The private ledger lives in `routing` beside session storage and stores policies,
workspace paths, counters, and reservation IDs, not prompt bodies or API secrets.
Routing bookkeeping is retained even for ephemeral execution so repeated requests
cannot silently discard a budget within that session. It is not tamper-proof against
someone who controls the local user account. To change a budget or discard uncertain
reservations, start a new session; there is no automatic refund or silent reset.

## Approvals and workspace access

Keep the default **Write in the workspace** sandbox for normal development, or
choose **Read only** for exploration. **Full access** grants broader access and
should be selected only when the task requires it.

Approval prompts describe the requested action. In the TUI, use arrows and Enter,
`y` to allow once, `s` for the session, `a` to always allow that tool, or `n`/Esc
to deny. In the GUI, use the labeled action buttons. Prefer allowing once when
trying an unfamiliar tool. Plan mode is read-only until you approve a plan.

Trust only project folders you intend the agent to use. Put project-specific
build, test, and style instructions in an `AGENTS.md` file at the project root.

### Yolo mode

`xailon --yolo` (also `xailon tui --yolo` or `xailon exec --yolo "..."`) runs with no
sandbox and no approval prompts, so the agent works through a task without stopping.
`XAILON_YOLO=1`, or `XAILON_YOLO: true` in your own `config.yaml`, does the same.

- **Still enforced:** deny rules, tools you set to never allow, plan mode you turned
  on, and an agent's tool list.
- **Never runs:** deleting the filesystem root, a top-level folder, your home folder,
  or the project folder or one of its parents, including paths built on a variable
  that could be empty, such as `"$DIR"/*`.
- **Cannot be switched on by a project:** a repository's configuration is ignored for
  this setting.
- **Refused as root** outside a container; `XAILON_DISABLE_YOLO=1` turns it off on a
  machine.

The CLI prints a warning and the terminal UI shows **⚠ YOLO** in its status line while
it is on. Use it only in a disposable environment, such as a container, a virtual
machine, or a throwaway checkout: anything the agent decides to run, runs.

Outside yolo mode, the same deletions always ask first, even when a rule would allow
them.

## Configuration and saved sessions

On macOS/Linux, configuration normally lives under `~/.config/xailon`; data and
state use their XDG directories. On Windows, the configuration directory is
`%APPDATA%\NET Group\xailon\config`. Use `xailon info -v` to see the actual paths
on your machine. Do not post its full output publicly without checking for
credentials and private paths.

`xailon --config-dir /path/to/isolated-config tui` creates an isolated configuration,
data, and state root. In that mode, secrets are stored in its config directory
rather than the system keyring. Keep the directory private.

Sessions are saved locally. Use `/resume`, `xailon tui --resume`, or the desktop
thread list to continue previous work. Closing the app does not uninstall it or
remove its saved configuration.

Telemetry is off by default. Set `XAILON_TELEMETRY_OFF=1` to force it off.

## Network proxy

Behind a corporate proxy, set the usual variables before starting XailonCode:

```bash
export HTTPS_PROXY=http://proxy.example.com:8080
export NO_PROXY=localhost,127.0.0.1,.internal.example.com
export XAILON_CA_CERT_PATH=/path/to/corporate-ca.pem   # if the proxy inspects TLS
```

Model requests, web fetching, and HTTP hooks all follow them. Web fetching still
refuses private and local addresses when a proxy is used; a host that cannot be
resolved locally is refused unless `XAILON_PROXY_ALLOW_UNRESOLVED=true`. Proxy
credentials in these variables are never written to logs.

## Updates and removal

Run the installer with `update` (PowerShell: `-Action update`), or download a newer
release, verify its checksum, and replace/install the binaries or desktop package.
Keep the CLI and its sandbox helper from the same release together.

For this preview, **use the installer updater or manual downloads rather than `xailon update`**: that command
still points at the source repository. Package-manager listings are not required
or promised by this release repository.

To uninstall the desktop on macOS, move the app from Applications to Trash. For a
CLI `.pkg` install, run `sudo /usr/local/xailon/uninstall.sh`. For a manual archive
install, remove only the XailonCode executables you installed. Use your package manager
on Linux, or Installed Apps on Windows, for native package installations.
Configuration, credentials, and sessions are separate from the application files;
remove them only if you intentionally want to discard that data.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `xailon: command not found` | Check your installation directory is on PATH; reopen the terminal after an installer changes PATH |
| Wrong version runs | Use `which -a xailon` on macOS/Linux or `Get-Command xailon -All` in PowerShell to find older installations |
| Authentication or model error | Run `xailon info --check`; verify the endpoint, key, and model id |
| GUI cannot find your provider | Save settings with `xailon configure`; shell-only exports may not reach a GUI launch |
| TUI says it needs a terminal | Run interactively, or use `xailon session` / `xailon exec` for redirected input |
| Newline shortcut sends a message | Try Ctrl+J or Alt+Enter; some terminals do not distinguish Shift+Enter |
| Sandboxed command fails immediately | Ensure the matching sandbox helper is installed beside the CLI; use native Linux packages for AppArmor integration |
| macOS blocks the app | Check the release's signing status and follow the linked Apple instructions for that app |
| Download hash does not match | Do not install it; download the asset and checksum again from the same release |

For support, [open an issue](https://github.com/InfiniaTechLabs/xailon-releases/issues)
with the XailonCode version, OS/architecture, steps to reproduce, and a sanitized error.
Do not include API keys, confidential prompts, or private project files.
