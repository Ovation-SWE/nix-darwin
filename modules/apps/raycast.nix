{ ... }: {
  flake.modules.darwin.raycast = { ... }: {
    homebrew.casks = [ "raycast" ];
  };
}
