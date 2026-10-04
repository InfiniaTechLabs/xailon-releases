# XailonCode user guide

For XailonCode **0.2.13** · CLI, terminal UI, and desktop app

- [Installation](#installation)
- [Connect a model](#connect-a-model)
- [Use the terminal UI](#use-the-terminal-ui)
- [Use the command line](#use-the-command-line)
- [Use the desktop app](#use-the-desktop-app)
- [Approvals and workspace access](#approvals-and-workspace-access)
- [Configuration and saved sessions](#configuration-and-saved-sessions)
- [Updates and removal](#updates-and-removal)
- [Troubleshooting](#troubleshooting)

XailonCode runs its agent and stores sessions on your computer. Prompts and relevant
project content are sent to the model endpoint you configure. Using a remote
provider can incur that provider's charges; a locally hosted endpoint keeps model
requests local. You do not need a XailonCode account.

## Installation

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
Use `--version v0.2.13` to pin a version and `--dry-run` to see the plan without
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

Windows accepts `-Component cli|desktop|all`, `-Version v0.2.13`, and `-DryRun`.
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
