{ ... }: {
  flake.modules.darwin.proton-suite = { ... }: {
    homebrew.enable = true;
    homebrew.casks = [
      "proton-mail"
      "proton-drive"
      "proton-pass"
      "protonvpn"
    ];
  };
}
