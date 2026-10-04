#!/bin/sh
set -eu

# Usage: sh install.sh [install|update] [--component cli|desktop|all] [--version vX.Y.Z]
main() {
  action=install component=cli version= prefix="${XAILON_INSTALL_PREFIX:-$HOME/.local}" dry_run=false
  while [ "$#" -gt 0 ]; do
    case "$1" in
      install|update) action=$1; shift ;;
      --component|--version|--prefix)
        [ "$#" -ge 2 ] || fail "$1 needs a value"
        case "$1" in --component) component=$2 ;; --version) version=$2 ;; --prefix) prefix=$2 ;; esac
        shift 2 ;;
      --dry-run) dry_run=true; shift ;;
      -h|--help)
        printf '%s\n' 'Xailon installer / updater' \
          'Usage: sh install.sh [install|update] [--component cli|desktop|all]' \
          '                     [--version vX.Y.Z] [--prefix DIR] [--dry-run]' \
          'Default: CLI + TUI. Linux desktop packages also require the matching CLI.' \
          'Native Linux packages use the system package manager; --prefix is for portable installs.'
        return ;;
      *) fail "Unknown option: $1" ;;
    esac
  done
  case "$component" in cli|desktop|all) ;; *) fail 'Component must be cli, desktop, or all' ;; esac
  case "$prefix" in /*) ;; *) fail '--prefix must be an absolute path' ;; esac
  os=$(uname -s); arch=$(uname -m)
  case "$os:$arch" in
    Darwin:arm64|Darwin:aarch64) target=aarch64-apple-darwin ;;
    Darwin:x86_64)
      if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || true)" = 1 ]; then target=aarch64-apple-darwin
      else target=x86_64-apple-darwin; fi ;;
    Linux:x86_64|Linux:amd64) target=x86_64-unknown-linux-gnu ;;
    Linux:aarch64|Linux:arm64) target=aarch64-unknown-linux-gnu ;;
    MINGW*:*|MSYS*:*|CYGWIN*:*) fail 'On Windows use https://xailoncode.infinialabs.ai/install.ps1 in PowerShell' ;;
    *) fail "Unsupported platform: $os / $arch" ;;
  esac
  if [ "$target" = aarch64-unknown-linux-gnu ] && [ "$component" != cli ]; then
    fail 'Linux ARM64 desktop is not available in this release. Use --component cli.'
  fi
  if [ -z "$version" ]; then version=$(fetch_stdout 'https://xailoncode.infinialabs.ai/latest-version.txt' | tr -d '\r\n'); fi
  printf '%s\n' "$version" | LC_ALL=C grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9][A-Za-z0-9.-]*)?$' || fail 'Invalid release version'
  base="https://github.com/InfiniaTechLabs/xailon-releases/releases/download/$version"
  mode=portable
  if [ "$os" = Linux ]; then
    if command -v apt-get >/dev/null 2>&1 && command -v dpkg >/dev/null 2>&1; then mode=deb
    elif command -v dnf >/dev/null 2>&1; then mode=rpm; fi
  fi
  printf 'Xailon %s: %s · %s · %s\n' "$action" "$version" "$target" "$component"
  printf 'Download source: %s\n' "$base"
  if [ "$dry_run" = true ]; then printf 'Plan: %s installation. No downloads or changes.\n' "$mode"; return; fi
  for tool in mktemp install; do command -v "$tool" >/dev/null 2>&1 || fail "Required system tool missing: $tool"; done
  if [ "$os" = Linux ]; then
    libc=$(getconf GNU_LIBC_VERSION 2>/dev/null || true)
    [ -n "$libc" ] || fail 'This release requires glibc Linux; musl/Alpine is not supported.'
    libc_version=${libc#* }; major=${libc_version%%.*}; minor=${libc_version#*.}; minor=${minor%%.*}
    [ "$major" -gt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -ge 35 ]; } || fail 'glibc 2.35 or newer is required.'
  fi
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/xailon-install.XXXXXXXX")
  mounted=false
  trap 'cleanup' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM HUP
  if [ "$mode" = deb ]; then
    download "xailon-$target.deb"
    if [ "$component" != cli ]; then
      download "xailon-desktop-$target.deb"
      chmod 755 "$tmp"
      as_root apt-get install -y "$tmp/xailon-$target.deb" "$tmp/xailon-desktop-$target.deb"
    else
      chmod 755 "$tmp"
      as_root apt-get install -y "$tmp/xailon-$target.deb"
    fi
  else
    # The CLI supplies provider configuration for desktop installs as well.
    if [ "$mode" = rpm ]; then
      download "xailon-$target.rpm"
      as_root dnf install -y "$tmp/xailon-$target.rpm"
    else
      install_cli
    fi
    if [ "$component" != cli ]; then
      if [ "$os" = Darwin ]; then install_macos_desktop
      else install_linux_desktop; fi
    fi
  fi
  printf '\nXailon %s complete (%s).\n' "$action" "$version"
  printf 'For portable installs, add %s/bin to PATH.\n' "$prefix"
  printf '%s\n' 'Next: xailon configure, then xailon tui or open Xailon Desktop.'
  printf '%s\n' 'Update later by running this script with update and the same --component option.'
}
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
fetch_stdout() {
  if command -v curl >/dev/null 2>&1; then curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "$1"
  elif command -v wget >/dev/null 2>&1; then wget --https-only -qO- "$1"
  else fail 'curl or wget is required. Install either with your OS package manager.'; fi
}
download() {
  asset=$1
  printf 'Downloading %s…\n' "$asset"
  fetch_stdout "$base/$asset" > "$tmp/$asset" || fail "Download failed: $asset. Check that this release contains your platform."
  fetch_stdout "$base/$asset.sha256" > "$tmp/checksum" || fail "Checksum missing: $asset"
  expected=$(awk 'NR == 1 {print $1}' "$tmp/checksum")
  printf '%s\n' "$expected" | LC_ALL=C grep -Eq '^[a-fA-F0-9]{64}$' || fail 'Invalid checksum file'
  if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$tmp/$asset" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')
  else fail 'A SHA-256 tool (sha256sum or shasum) is required.'; fi
  [ "$(printf %s "$expected" | tr A-F a-f)" = "$actual" ] || fail "Checksum mismatch: $asset. Nothing from this download was installed."
}
as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"
  elif command -v sudo >/dev/null 2>&1; then sudo "$@"
  else fail 'This native package requires administrator privileges. Run with sudo or use a portable archive.'; fi
}
install_cli() {
  command -v tar >/dev/null 2>&1 || fail 'tar is required'
  command -v bzip2 >/dev/null 2>&1 || fail 'bzip2 is required; install it with your OS package manager'
  download "xailon-$target.tar.bz2"
  state="$prefix/lib/xailon"
  release="$state/$version-$(printf %s "$actual" | cut -c1-12)"
  bins='xailon xailond'
  [ "$os" != Linux ] || bins="$bins xailon-linux-sandbox"
  mkdir -p "$tmp/unpacked" "$state" "$prefix/bin"
  # Only fixed, top-level filenames are extracted from the verified archive.
  tar -xjf "$tmp/xailon-$target.tar.bz2" -C "$tmp/unpacked" $bins LICENSE NOTICE
  for bin in $bins; do
    [ -f "$tmp/unpacked/$bin" ] && [ ! -L "$tmp/unpacked/$bin" ] || fail "Archive is missing a regular $bin executable"
  done
  [ ! -e "$release" ] || release="$release-$$"
  mkdir -p "$release"
  for bin in $bins; do install -m 755 "$tmp/unpacked/$bin" "$release/$bin"; done
  install -m 644 "$tmp/unpacked/LICENSE" "$tmp/unpacked/NOTICE" "$release/"
  "$release/xailon" --version
  ln -s "$release" "$state/.current-$$"
  mv -fh "$state/.current-$$" "$state/current" 2>/dev/null || {
    # GNU mv uses -T for a symlink destination; BSD mv uses -h.
    mv -fT "$state/.current-$$" "$state/current"
  }
  for bin in $bins; do
    ln -s "$state/current/$bin" "$prefix/bin/.$bin-$$"
    mv -f "$prefix/bin/.$bin-$$" "$prefix/bin/$bin"
  done
}
install_macos_desktop() {
  for tool in hdiutil ditto codesign; do command -v "$tool" >/dev/null 2>&1 || fail "$tool is required"; done
  download "xailon-desktop-$target.dmg"
  app_parent="$HOME/Applications"
  if [ ! -d "$app_parent/Xailon Desktop.app" ] && [ -d "/Applications/Xailon Desktop.app" ]; then app_parent=/Applications; fi
  mkdir -p "$tmp/mount"
  app_run mkdir -p "$app_parent"
  hdiutil attach -quiet -readonly -nobrowse -mountpoint "$tmp/mount" "$tmp/xailon-desktop-$target.dmg"
  mounted=true
  app="$tmp/mount/Xailon Desktop.app"
  [ -d "$app" ] || fail 'The disk image does not contain Xailon Desktop.app'
  codesign --verify --deep --strict "$app"
  destination="$app_parent/Xailon Desktop.app"
  stage="$app_parent/.Xailon-new-$$.app"
  backup="$app_parent/.Xailon-previous-$$.app"
  app_run ditto "$app" "$stage"
  [ ! -e "$destination" ] || app_run mv "$destination" "$backup"
  if ! app_run mv "$stage" "$destination"; then
    [ ! -e "$backup" ] || app_run mv "$backup" "$destination"
    fail 'Could not replace the desktop app'
  fi
  [ ! -e "$backup" ] || app_run rm -r "$backup"
  printf 'Desktop installed: %s\n' "$destination"
}
app_run() {
  if [ -d "$app_parent" ] && [ ! -w "$app_parent" ]; then as_root "$@"; else "$@"; fi
}
install_linux_desktop() {
  download "xailon-desktop-$target.AppImage"
  chmod 755 "$tmp/xailon-desktop-$target.AppImage"
  (cd "$tmp" && "./xailon-desktop-$target.AppImage" --appimage-extract > /dev/null)
  [ -x "$tmp/squashfs-root/AppRun" ] || fail 'AppImage extraction failed'
  release="$prefix/lib/xailon-desktop/$version-$(printf %s "$actual" | cut -c1-12)"
  [ ! -e "$release" ] || release="$release-$$"
  mkdir -p "$release" "$prefix/bin" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp -R "$tmp/squashfs-root/." "$release/"
  ln -s "$release/AppRun" "$prefix/bin/.xailon-desktop-$$"
  mv -f "$prefix/bin/.xailon-desktop-$$" "$prefix/bin/xailon-desktop"
  printf '%s\n' '[Desktop Entry]' 'Type=Application' 'Name=Xailon Desktop' \
    "Exec=\"$prefix/bin/xailon-desktop\"" 'Terminal=false' 'Categories=Development;' \
    > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/xailon-desktop.desktop"
  printf '%s\n' 'Desktop installed using AppImage extraction; FUSE is not required.'
}
cleanup() {
  if [ "$mounted" = true ]; then hdiutil detach -quiet "$tmp/mount" || true; fi
  [ ! -d "$tmp" ] || rm -r "$tmp"
}
main "$@"
