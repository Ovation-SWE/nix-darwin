{ ... }: {
  flake.modules.darwin.homebrew-settings = { ... }: {
    homebrew.enable = true;
    homebrew.onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
