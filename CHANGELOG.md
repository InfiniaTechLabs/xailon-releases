# XailonCode releases

## v0.2.17 — Call it by name

- **Skills, recipes, and plugins by name:** `/name` runs any skill, recipe, or command, and `@name` anywhere in a message calls it with the rest of the message as input. Installed plugins' recipes and commands are now callable, including the 100 recipe plugins in the Infinia Marketplace.
- **Suggestions as you type:** the terminal UI and the desktop app suggest skills, recipes, and commands after `/` and `@`, labeled by kind; the line-based CLI completes them with Tab.
- **Answer clarifying questions properly:** questions XailonCode asks before starting appear as a form in the terminal UI, a card in the desktop app, and pickers in the CLI, instead of raw JSON.
- **Website:** the logo, colors, and type now match the Infinia Labs marketplace.

### Packages and limits

Apple Silicon macOS CLI/TUI/server archive and desktop DMG. Builds are ad-hoc signed, not Apple-notarized. Other platforms remain pending and are not advertised as downloadable. Use the public install/update scripts; the CLI's built-in `xailon update` still targets the source repository.

## v0.2.16 — Infinia Marketplace

- **Infinia Marketplace everywhere:** add the curated catalog in one step with `xailon plugin marketplace add` (or `add infinia`), the new TUI `/plugins` command, or **Add Infinia Marketplace** in the desktop app.
- **Browse and install from the TUI:** `/plugins` lists every marketplace plugin with search, shows the source, pinned commit and runnable code, and installs only after you choose Install.
- **Desktop marketplace section:** one-click add, **Browse catalog**, plugin search, installed labels, and click-to-review.
- **Fix:** a terminal UI test no longer depends on the number of slash commands.

### Packages and limits

Apple Silicon macOS CLI/TUI/server archive and desktop DMG. Builds are ad-hoc signed, not Apple-notarized. Other platforms remain pending and are not advertised as downloadable. Use the public install/update scripts; the CLI's built-in `xailon update` still targets the source repository.

## v0.2.15 — Your endpoint, your models

- **Custom endpoints with model discovery:** first-run setup offers an OpenAI-compatible endpoint option. Adding any OpenAI-, Anthropic-, or Ollama-compatible endpoint loads the models it serves, with search for long lists. Manual entry is needed only when the endpoint does not list models.
- **Model lists stay current:** custom providers reload models from the endpoint at the start of every new desktop or client session and in `xailon configure`. All served models are shown, not only models XailonCode recognizes. Providers created by earlier versions refresh too.
- **Desktop activity and planning:** an Activity & Tasks panel with a tool and reasoning timeline, task plans shown as cards with completion counts, and an Output tab. Keyboard navigation and Esc dismissal included.

### Packages and limits

Apple Silicon macOS CLI/TUI/server archive and desktop DMG. Builds are ad-hoc signed, not Apple-notarized. Other platforms remain pending and are not advertised as downloadable. Use the public install/update scripts; the CLI's built-in `xailon update` still targets the source repository.

## v0.2.14 — Clarity and control

- **Rich desktop responses:** Markdown tables, task lists, syntax-highlighted code with copying, and math. Choose streamed or completed responses and expanded, collapsed, or hidden tool calls and reasoning summaries. Approvals and errors remain visible.
- **MCP and shared Mods:** manage and test local-process or Streamable HTTP MCP servers, inspect tool schemas, review pinned plugin installs and updates, and use shared Markdown panels across desktop, CLI, and TUI. Mods v1 uses Xailon's lifecycle hooks; Claude Code function modules require porting.
- **Verification evidence:** inspect command outcomes with their observed workspace revision. Recheck freshness after edits, export report JSON, and inspect reports with `xailon evidence` or TUI `/evidence`. Evidence records observed checks; it does not certify task completion.
- **Project privacy and spending:** pin local/cloud model profiles, require explicit cloud approval, keep sessions local when sensitive paths are found, and apply estimated per-turn/session budgets shared with delegates. Policies and spending persist across resumed sessions. Routing covers model requests, not networking by tools or MCP servers; estimates are not invoice caps.
- **Public distribution:** refreshed website and searchable user guide, plus install/update availability based on published release assets.

### Packages and limits

Apple Silicon macOS CLI/TUI/server archive and desktop DMG. Builds are ad-hoc signed, not Apple-notarized. Other platforms remain pending and are not advertised as downloadable. Use the public install/update scripts; the CLI's built-in `xailon update` still targets the source repository.

## v0.2.13 — Initial public preview

Saqr falcon branding, terminal and desktop UX improvements, public installers and documentation. The Apple Silicon CLI/TUI archive is publicly accessible; this version predates the features above.
