{ ... }: {
  # This automatically registers under config.flake.modules.darwin.cli-tools
  flake.modules.darwin.cli-tools = { pkgs, ... }: {
    
    environment.systemPackages = [
      pkgs.stow     # GNU Stow for symlink dotfiles management
      pkgs.lazygit  # Terminal UI for git commands
    ];

  };
}
