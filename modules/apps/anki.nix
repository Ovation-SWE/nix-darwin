{ ... }: {
  flake.modules.darwin.anki= { ... }: {
    homebrew = {
      casks = [ "anki" ];
    };
  };
}
