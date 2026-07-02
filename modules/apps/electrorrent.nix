{ ... }: {
  flake.modules.darwin.electrorrent = { ... }: {
    homebrew = {
      enable = true;
      casks = [
        "electorrent"
      ];
    };
  };
}
