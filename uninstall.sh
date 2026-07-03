#!/usr/bin/env bash
# uninstall.sh — remove Determinate Nix and nix-darwin state for a clean reinstall
set -euo pipefail

info()    { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
success() { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn()    { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
die()     { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || die "This script is for macOS only."
[[ "$EUID" -eq 0 ]] || die "Run with sudo: sudo bash uninstall.sh"

# ── 1. Restore nix-darwin /etc backups FIRST ─────────────────────────────────
# Must happen before removing /nix so Determinate can cleanly edit the restored
# files. nix-darwin replaces /etc/zshrc etc. with symlinks into the nix store;
# after /nix is gone those become broken symlinks that -e can't detect.
restore_etc() {
  info "Restoring /etc files from nix-darwin backups..."

  restore_file() {
    local original="$1"
    local backup="${original}.before-nix-darwin"
    if [[ -f "$backup" ]]; then
      rm -f "$original"          # removes symlink (broken or not) or regular file
      mv "$backup" "$original"
      success "Restored $original"
    elif [[ -e "$original" ]] || [[ -L "$original" ]]; then
      # No backup → nix-darwin created this from scratch; -L catches broken symlinks
      rm -f "$original"
      info "Removed $original (no pre-nix-darwin backup)"
    fi
  }

  restore_file /etc/zshrc
  restore_file /etc/zshenv
  restore_file /etc/zprofile
  restore_file /etc/bashrc
  restore_file /etc/shells

  # Leave /etc/nix itself for Determinate to revert — only remove nix-darwin's
  # backup files inside it so they don't interfere.
  rm -f /etc/nix/nix.conf.before-nix-darwin
  rm -f /etc/nix/nix.custom.conf.before-nix-darwin

  # /etc/static is a nix-darwin symlink into the nix store
  if [[ -L /etc/static ]] || [[ -e /etc/static ]]; then
    rm -rf /etc/static
    success "Removed /etc/static"
  fi
}

# ── 2. Uninstall Determinate Nix ─────────────────────────────────────────────
remove_determinate() {
  if [[ -x /nix/nix-installer ]]; then
    info "Running Determinate uninstaller..."
    /nix/nix-installer uninstall --no-confirm
    success "Determinate Nix uninstalled"
  else
    warn "Determinate uninstaller not found — skipping"
  fi

  # Belt-and-suspenders: remove /nix if still present
  if [[ -d /nix ]]; then
    warn "/nix still present after uninstall — removing manually"
    rm -rf /nix
    success "/nix removed"
  fi
}

# ── 3. Remove nix-darwin runtime state ───────────────────────────────────────
remove_darwin_state() {
  info "Removing nix-darwin runtime state..."

  # /run/current-system is a symlink managed by nix-darwin
  if [[ -L /run/current-system ]] || [[ -d /run/current-system ]]; then
    rm -rf /run/current-system
    success "Removed /run/current-system"
  fi

  # Belt-and-suspenders: remove /etc/nix if Determinate left it behind
  [[ -d /etc/nix ]] && rm -rf /etc/nix && success "Removed /etc/nix"

  # Remove nix-darwin launchd plists (Determinate handles its own)
  for plist in /Library/LaunchDaemons/org.nixos.*.plist; do
    [[ -f "$plist" ]] || continue
    launchctl unload "$plist" 2>/dev/null || true
    rm -f "$plist"
    info "Removed $plist"
  done
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  info "=== Cleaning up Determinate Nix + nix-darwin state ==="
  echo

  restore_etc         # must come first — restores symlinks before /nix is gone
  remove_determinate  # uninstalls Nix cleanly against real /etc files
  remove_darwin_state # cleans up remaining runtime state

  echo
  success "=== Cleanup complete! ==="
  info "You can now run: bash setup.sh"
}

main "$@"
