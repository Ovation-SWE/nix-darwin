{ ... }: {
  # This automatically registers under config.flake.modules.darwin.cli-tools
  flake.modules.darwin.cli-tools = { pkgs, ... }: {

    environment.systemPackages = [
      pkgs.stow
      pkgs.lazygit
      pkgs.gh
      pkgs.neovim
      pkgs.yazi
    ];

    homebrew = {
      enable = true;

      casks = [
        "github"
      ];
    };

  };
}
