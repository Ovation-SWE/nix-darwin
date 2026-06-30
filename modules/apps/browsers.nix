{ ... }: {
  flake.modules.darwin.browsers = { ... }: {
    homebrew = {
      enable = true;
      casks = [
        "zen"
      ];
    };
  };
}
