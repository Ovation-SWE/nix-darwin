# nix-darwin Config

Declarative macOS setup using nix-darwin + flake-parts + home-manager (dendritic pattern).

## Commands
- Apply: `darwin-rebuild switch --flake .`
- Update inputs: `nix flake update`
- Check syntax: `nix flake check`

## Structure
```
modules/
  hosts/    # darwinConfigurations — one file per machine
  system/   # darwin system-level config → flake.modules.darwin.*
  apps/     # GUI apps via Homebrew casks → flake.modules.darwin.*
  dev/      # CLI developer tools → flake.modules.darwin.*
  home/     # Home Manager user config → flake.modules.homeManager.*
```

## Module Pattern
Each file exports one or both of:
```nix
flake.modules.darwin.<name> = { pkgs, ... }: { ... };       # system
flake.modules.homeManager.<name> = { pkgs, ... }: { ... };  # user
```
Modules are auto-discovered recursively — no manual imports needed.

## Adding a Feature
1. Create `modules/<category>/<feature>.nix`
2. Export `flake.modules.darwin.*` and/or `flake.modules.homeManager.*`
3. Run `darwin-rebuild switch --flake .`

## Host: Ovations-MacBook-Pro
- aarch64-darwin, user: ovation, stateVersion: 6 / HM stateVersion: 26.05
