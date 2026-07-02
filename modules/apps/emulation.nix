{ ... }: {
  flake.modules.darwin.emulation = { pkgs, ... }: {
    homebrew.enable = true;
    homebrew.casks = [
      # PSP — nixpkgs ppsspp-sdl is Linux only; use Homebrew standalone app
      "ppsspp-emulator"

      # GBA / GBC / GB — nixpkgs mgba is Linux only; use Homebrew standalone app
      "mgba-app"

      # PlayStation 2 — nixpkgs pcsx2 is Linux only; use Homebrew cask
      "pcsx2"

      # RetroArch — Metal renderer build, preferred on Apple Silicon.
      # retroarch-bare (nixpkgs) is marked broken on aarch64-darwin, so we use
      # the Homebrew cask instead. Install cores from the RetroArch Online
      # Updater (Main Menu → Online Updater → Core Downloader).
      "retroarch-metal"
    ];

    environment.systemPackages = with pkgs; [
      # Standalone emulators — offer more configuration options than libretro cores
      dolphin-emu  # GameCube / Wii (standalone; more dev-active than the core)
      melonDS      # Nintendo DS (standalone)
      snes9x       # Super Nintendo (standalone)

      # PlayStation 1 (standalone) — needs nixpkgs.config.allowUnfree = true
      # because DuckStation switched to a non-commercial license in 2024.
      # To enable: add `nixpkgs.config.allowUnfree = true;` in macbook.nix,
      # then uncomment:
      # duckstation
    ];

    # ---------------------------------------------------------------------------
    # Manual installs (no package manager support)
    # ---------------------------------------------------------------------------
    #
    # RPCS3 (PlayStation 3)
    #   Native ARM64 macOS build available at https://rpcs3.net/download
    #   Not yet in nixpkgs or Homebrew. Download the .dmg directly.
    #
    # ---------------------------------------------------------------------------
  };
}
