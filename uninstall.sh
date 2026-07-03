#!/usr/bin/env bash
# uninstall.sh — remove Determinate Nix and nix-darwin state for a clean reinstall
set -euo pipefail

info()    { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
success() { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn()    { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
die()     { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || die "This script is for macOS only."
[[ "$EUID" -eq 0 ]] || die "Run with sudo: sudo bash uninstall.sh"

# ── 1. Uninstall Determinate Nix ─────────────────────────────────────────────
remove_determinate() {
  if [[ -x /nix/nix-installer ]]; then
    info "Running Determinate uninstaller..."
    /nix/nix-installer uninstall --no-confirm || true
    success "Determinate Nix uninstalled"
  else
    warn "Determinate uninstaller not found at /nix/nix-installer — skipping"
  fi

  # Belt-and-suspenders: remove /nix if still present
  if [[ -d /nix ]]; then
    warn "/nix still present after uninstall — removing manually"
    rm -rf /nix
    success "/nix removed"
  fi
}

# ── 2. Restore nix-darwin /etc backups ───────────────────────────────────────
restore_etc() {
  info "Restoring /etc files from nix-darwin backups..."

  restore_file() {
    local original="$1"
    local backup="${original}.before-nix-darwin"
    if [[ -f "$backup" ]]; then
      mv "$backup" "$original"
      success "Restored $original"
    elif [[ -e "$original" ]]; then
      # No backup means nix-darwin created it from scratch — remove it
      rm -f "$original"
      info "Removed $original (no pre-nix-darwin backup existed)"
    fi
  }

  restore_file /etc/zshrc
  restore_file /etc/zshenv
  restore_file /etc/zprofile
  restore_file /etc/bashrc
  restore_file /etc/shells

  # Restore nix.conf if there's a backup, otherwise remove the whole /etc/nix
  if [[ -f /etc/nix/nix.conf.before-nix-darwin ]]; then
    mv /etc/nix/nix.conf.before-nix-darwin /etc/nix/nix.conf
    success "Restored /etc/nix/nix.conf"
  fi

  # Remove remaining nix-darwin-managed /etc entries
  rm -f /etc/nix/nix.conf.before-nix-darwin
  rm -f /etc/nix/nix.custom.conf.before-nix-darwin
  [[ -d /etc/nix ]] && rm -rf /etc/nix && info "Removed /etc/nix"

  # Remove /etc/static symlink
  if [[ -L /etc/static ]]; then
    rm /etc/static
    success "Removed /etc/static symlink"
  fi
}

# ── 3. Remove nix-darwin runtime state ───────────────────────────────────────
remove_darwin_state() {
  info "Removing nix-darwin runtime state..."

  [[ -L /run/current-system ]] && rm /run/current-system && success "Removed /run/current-system"
  [[ -d /run/current-system ]] && rm -rf /run/current-system

  # Remove launchd daemon plists that nix-darwin may have written
  for plist in /Library/LaunchDaemons/org.nixos.*.plist \
               /Library/LaunchDaemons/systems.determinate.*.plist; do
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

  remove_determinate
  restore_etc
  remove_darwin_state

  echo
  success "=== Cleanup complete! ==="
  info "You can now run setup.sh for a fresh install using the Lix-based installer."
}

main "$@"
