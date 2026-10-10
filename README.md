# XailonCode releases

```text
 ▄███▄    Xailon
███ ▀██▄  Saqr
████▄▀▀
 ▀██▌
```

Official binary downloads and user documentation from **Infinia Technologies**.
Xailon is a local-first AI agent with a command-line interface, a terminal UI,
and a desktop app. Connect your own model provider or local model server.

**[Website](https://xailoncode.infinialabs.ai/)** ·
**[Release downloads](https://github.com/InfiniaTechLabs/xailon-releases/releases)** ·
**[User guide](USER_GUIDE.md)** ·
**[Report an issue](https://github.com/InfiniaTechLabs/xailon-releases/issues)**

This is the public distribution repository. It contains documentation, installation
helpers, checksums, and release metadata. Application binaries are attached to
GitHub Releases rather than stored in Git history.

## Latest: v0.2.21

Live mods add their own panes, a band above the prompt, status entries, toasts, and
slash commands to the terminal UI and the desktop app. See
[what changed](CHANGELOG.md) and the [user guide](USER_GUIDE.md#live-mods).

**Available:** Apple Silicon macOS CLI, TUI, server, and desktop. Windows, Linux,
and Intel Mac packages are pending. macOS packages are ad-hoc signed and not
Apple-notarized. Only attached release assets are available for download.

## Choose your download

| Platform | CLI / TUI | Desktop |
| --- | --- | --- |
| macOS, Apple Silicon | `xailon-aarch64-apple-darwin.tar.bz2` or `.pkg` | `xailon-desktop-aarch64-apple-darwin.dmg` |
| macOS, Intel | `xailon-x86_64-apple-darwin.tar.bz2` or `.pkg` | `xailon-desktop-x86_64-apple-darwin.dmg` |
| Linux, x86-64 | `xailon-x86_64-unknown-linux-gnu.tar.bz2`, `.deb`, or `.rpm` | `xailon-desktop-x86_64-unknown-linux-gnu.deb` or `.AppImage` |
| Linux, ARM64 | `xailon-aarch64-unknown-linux-gnu.tar.bz2`, `.deb`, or `.rpm` | Not included |
| Windows, x86-64 | `xailon-x86_64-pc-windows-msvc.zip` or `.msi` | `xailon-desktop-x86_64-pc-windows-msvc.msi` |

The asset list on each release is authoritative. Only download a package actually
attached to that release. The CLI archive also contains `xailond` and, on Linux
and Windows, the required sandbox helper. The desktop app contains its own engine.

## One-command install

macOS / Linux:

```bash
curl -fsSL https://xailoncode.infinialabs.ai/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://xailoncode.infinialabs.ai/install.ps1 | iex
```

The default installs the CLI and TUI. The [installer guide](USER_GUIDE.md#one-command-install-and-update)
explains desktop installation, updates, pinned versions, and dry runs. Inspect
[install.sh](install.sh) or [install.ps1](install.ps1) before running if preferred.

## Start here

1. Download the package for your operating system and processor.
2. Verify its SHA-256 checksum against the release's `SHA256SUMS` or matching
   `.sha256` file. See the [installation guide](USER_GUIDE.md#installation).
3. Install the CLI and run `xailon configure` to save your provider settings.
4. Open **Xailon Desktop**, or run `xailon tui` in your project directory.

```bash
cd your-project
xailon tui
```

For a terminal-only session use `xailon session`. For scripts use
`xailon exec "Explain this repository"`.

## Release status

The initial public release is a **preview**. Packages without a distribution
signature or Apple notarization are identified in the release notes. Checksums
verify that a download matches the published file; they are not code-signing
certificates or a notarization claim.

Use the install/update scripts or downloads from this repository for updates. This build's `xailon update`
command still targets the source repository and is not a supported public update
path. No Homebrew tap, winget listing, or app-store installation is required.

## License and attribution

Xailon is licensed under [Apache-2.0](LICENSE). It derives from
[Goose](https://github.com/block/goose) and includes code adapted from
[aionrs](https://github.com/iOfficeAI/aionrs). See [NOTICE](NOTICE).

## Website maintenance

The static website and searchable guide are built from `site/` and `USER_GUIDE.md`.
Run `npm ci`, `npm run build`, and `npm test`. `npm run dev` serves a local preview.
The Manrope website font is distributed under the [SIL Open Font License](site/FONT_LICENSE.txt).

Deployment uses Cloudflare Pages project `xailoncode`. Supply
`CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` in the deployment environment,
then run `npm run deploy`. Credentials are not stored in this repository.
The custom domain is `xailoncode.infinialabs.ai`.

Before advancing `release.json`, publish all advertised assets with their
`.sha256` files, verify them, and update the platform availability in the guide.
The website emits `latest-version.txt` from that manifest; the installers use it
as their install/update version. Keep versioned assets immutable.
