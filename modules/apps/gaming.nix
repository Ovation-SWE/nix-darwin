{ ... }: {
  flake.modules.darwin.gaming = { ... }: {
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
  };
}
