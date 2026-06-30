{ ... }: {
  flake.modules.darwin.ai = { pkgs, ... }: {
    # Keeps the unfree scope limited/explicitly declared next to the tool itself
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = [
      pkgs.claude-code
    ];
  };
}
