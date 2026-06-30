{ ... }: {
  flake.modules.darwin.ai = { pkgs, ... }: {
    # Keeps the unfree scope limited/explicitly declared next to the tool itself
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = [
      pkgs.claude-code
    ];

    # Enable homebrew support inside nix-darwin
    homebrew.enable = true;

    # Instruct Homebrew to install the official Claude Desktop GUI application
    homebrew.casks = [
      "claude"
    ];
  };
}
