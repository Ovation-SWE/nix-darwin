#!/usr/bin/env bash
# setup.sh — bootstrap nix-darwin with Homebrew support on a fresh macOS system
#
# Run once on a new machine. After this, use `switch` (the zsh alias) for rebuilds.
set -euo pipefail

FLAKE="/Users/ovation/dotfiles/nix/darwin"
HOSTNAME="Ovations-MacBook-Pro"

# ── Logging ───────────────────────────────────────────────────────────────────
info()    { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
success() { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn()    { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
die()     { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ── macOS guard ───────────────────────────────────────────────────────────────
[[ "$(uname)" == "Darwin" ]] || die "This script is for macOS only."

# ── 1. Nix ───────────────────────────────────────────────────────────────────
install_nix() {
  if command_exists nix; then
    info "Nix already installed ($(nix --version))"
    return
  fi

  info "Installing Nix via Lix installer (recommended by nix-darwin)..."
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install

  # Source Nix daemon for the rest of this script
  if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi

  command_exists nix || die "Nix install succeeded but 'nix' not on PATH — open a new terminal and re-run."
  success "Nix installed"
}

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
install_homebrew() {
  if command_exists brew; then
    info "Homebrew already installed"
    return
  fi

  info "Installing Homebrew (required by nix-darwin homebrew module)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  command_exists brew || die "Homebrew install finished but 'brew' not on PATH."
  success "Homebrew installed"
}

# ── 3. Initial nix-darwin activation ─────────────────────────────────────────
bootstrap_darwin() {
  if command_exists darwin-rebuild; then
    info "darwin-rebuild already available — running switch..."
    sudo darwin-rebuild switch --flake "${FLAKE}#${HOSTNAME}"
  else
    info "First-time nix-darwin bootstrap via 'nix run'..."
    # nix-darwin's darwin-rebuild isn't on PATH yet; use nix run to activate it.
    sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "${FLAKE}#${HOSTNAME}"
  fi
  success "nix-darwin activated"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  info "=== nix-darwin setup for ${HOSTNAME} ==="
  info "Flake: ${FLAKE}"
  echo

  install_nix
  install_homebrew
  bootstrap_darwin

  echo
  success "=== Setup complete! Open a new terminal or run: exec zsh ==="
  info "Future rebuilds: switch (alias) or sudo darwin-rebuild switch --flake ${FLAKE}#${HOSTNAME}"
}

main "$@"
