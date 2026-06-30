{ config, lib, pkgs, ... }:

{
  # We expose a macOS system-level configuration aspect
  flake.modules.darwin.proton-suite = { ... }: {
    
    # Enable homebrew support inside nix-darwin if not already active
    homebrew.enable = true;

    # Instruct Homebrew to install the official macOS GUI applications
    homebrew.casks = [
      "proton-mail"      # Includes Proton Calendar integration natively
      "proton-drive"     # Mounts Proton Drive securely into Finder
      "proton-pass"      # Password manager desktop app
      "protonvpn"        # Secure VPN application
    ];

    # Optional: Safe configuration to ensure apps auto-update cleanly via Homebrew management
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.upgrade = true;
  };
}
