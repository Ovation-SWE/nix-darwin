{ ... }: {
  flake.modules.darwin.aerospace = { ... }: {
    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
    };
  };
}
