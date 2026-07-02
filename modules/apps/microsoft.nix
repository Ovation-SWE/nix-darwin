{ ... }: {
  flake.modules.darwin.microsoft = { ... }: {
    homebrew.enable = true;
    homebrew.casks = [
      "microsoft-excel"
      "microsoft-onenote"
      "microsoft-auto-update"
    ];
  };
}
