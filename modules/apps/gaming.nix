{ ... }: {
  flake.modules.darwin.gaming = { pkgs, ... }: {
    homebrew.enable = true;
    homebrew.casks = [
      # Native Mac Steam client — runs Mac-native games and some Windows
      # titles via Apple's MoltenVK/Metal translation layer
      "steam"

      # Mythic — free, open-source launcher using Apple's Game Porting
      # Toolkit (GPTK) to run Windows games (Epic, GOG, Amazon) on Apple
      # Silicon. Best free option post-Whisky discontinuation (Apr 2025).
      "mythic"

      # CrossOver — paid ($74/yr) commercial Wine wrapper with DX12 support
      # via Wine 11 + D3DMetal 3.0. Best compatibility for modern AAA titles.
      # Uncomment if you purchase a license: https://www.codeweavers.com
      # "crossover"
    ];

    environment.systemPackages = [
      # r2modman — Thunderstore mod manager GUI.
      # Supports Slay the Spire (search "Slay the Spire" in r2modman after
      # selecting it as your game). Handles mod install, profiles, and updates.
      pkgs.r2modman
    ];

    # ---------------------------------------------------------------------------
    # Modding notes — per game
    # ---------------------------------------------------------------------------
    #
    # SLAY THE SPIRE
    #   Use r2modman (above). Select "Slay the Spire" as the game, browse
    #   Thunderstore mods, and launch via r2modman's built-in launcher.
    #   ModTheSpire (.jar) also works manually but r2modman is easier.
    #
    # BALATRO
    #   Balatro uses lovely-injector + Steamodded — NOT on Thunderstore, so
    #   r2modman won't help. Requires a one-time manual setup:
    #
    #   1. Download lovely-aarch64-apple-darwin.tar.gz from:
    #      https://github.com/ethangreen-dev/lovely-injector/releases
    #   2. Extract and place liblovely.dylib next to Balatro.app in the game
    #      folder (right-click game in Steam → Manage → Browse local files)
    #   3. Place Steamodded (and any other mods) in:
    #      ~/Library/Application Support/Balatro/Mods/
    #   4. DO NOT launch from Steam — use the run_lovely_macos.sh script
    #      included in the lovely-injector archive due to a Steam client bug.
    #
    # BLOONS TD6
    #   BTD6 modding is NOT supported on macOS. The mod framework (MelonLoader)
    #   is Windows/Linux only — there is an open upstream issue with no ETA.
    #   BTD Mod Helper explicitly lists macOS as unsupported.
    # ---------------------------------------------------------------------------
  };
}
