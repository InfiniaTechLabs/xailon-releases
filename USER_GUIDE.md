# XailonCode user guide

For XailonCode **0.2.16** · CLI, terminal UI, and desktop app

- [Installation](#installation)
- [Connect a model](#connect-a-model)
- [Use the terminal UI](#use-the-terminal-ui)
- [Use the command line](#use-the-command-line)
- [Use the desktop app](#use-the-desktop-app)
- [Rich responses and display controls](#rich-responses-and-display-controls)
- [MCP servers and shared Mods](#mcp-servers-and-shared-mods)
- [Infinia Marketplace](#infinia-marketplace)
- [Verification evidence](#verification-evidence)
- [Project privacy and spending](#project-privacy-and-spending)
- [Approvals and workspace access](#approvals-and-workspace-access)
- [Configuration and saved sessions](#configuration-and-saved-sessions)
- [Updates and removal](#updates-and-removal)
- [Troubleshooting](#troubleshooting)

XailonCode runs its agent and stores sessions on your computer. Prompts and relevant
project content are sent to the model endpoint you configure. Using a remote
provider can incur that provider's charges; a locally hosted endpoint keeps model
requests local. You do not need a XailonCode account.

## Installation

**v0.2.14 availability:** Apple Silicon macOS CLI, TUI, local server, and desktop app.
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
Use `--version v0.2.14` to pin a version and `--dry-run` to see the plan without
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

Windows accepts `-Component cli|desktop|all`, `-Version v0.2.14`, and `-DryRun`.
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
| Enter | Send; queue a follow-up while the agent is working |
| Alt+Enter, Shift+Enter, or Ctrl+J | Insert a newline; terminal support varies |
| `/` | Browse commands |
| `@` | Find and attach a project file |
| Up / Down in a popup | Select a suggestion; the list scrolls with selection |
| Tab in a popup | Complete the selected command or file |
| Enter in a popup | Run the command or insert the file |
| Esc | Close a popup, or interrupt a running turn |
| Ctrl+T | Open the transcript pager; `q` closes it |
| Ctrl+O | Expand or collapse tool output |
| PgUp / PgDn | Scroll the transcript |
| Ctrl+V or Alt+V | Paste an image when supported |
| Ctrl+D | Quit with empty input while idle |

Useful commands:

| Command | Purpose |
| --- | --- |
| `/help` | Commands and keyboard shortcuts |
| `/model` | Select a model |
| `/plugins` | Add the Infinia Marketplace, then browse and install plugins |
| `/mods` | Open shared plugin Markdown panels |
| `/evidence` | Inspect the latest verification report and check freshness |
| `/routing` | Show the active model route and estimated spending |
| `/status` | Session, model, context, and usage details |
| `/diff` | Review the workspace's Git diff |
| `/compact` | Summarize the conversation to free context |
| `/resume` | Choose a previous session |
| `/clear` | Clear the conversation |
| `/exit` | Quit |

Use `xailon tui --inline` to keep completed output in terminal scrollback.
Use `xailon tui --resume` to resume the most recent session. Set
`XAILON_DEFAULT_UI=tui` to make a bare `xailon` open the TUI in an interactive terminal.

## Use the command line

```bash
xailon session                         # interactive line-mode interface
xailon exec "Explain the test setup"  # one task for scripts
xailon exec "Review this project" --sandbox read-only
xailon session list                    # saved sessions
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
Mods v1 supports typed lifecycle hooks and static Markdown panels. It does not
run arbitrary UI components or directly load Claude Code TypeScript function
modules; those modules need porting to Xailon's hook protocol.

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
