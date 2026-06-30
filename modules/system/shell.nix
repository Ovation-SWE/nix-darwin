{ ... }:

{
  flake.modules.darwin.shell = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      zsh

      # Core utilities
      git
      curl
      wget

      # Modern CLI tools
      bat
      fd
      ripgrep
      fzf
      eza
      zoxide
      starship
      atuin
      btop
      zinit
      direnv
    ];

    # Enable nix-darwin's zsh integration
    programs.zsh = {
      enable = true;

      enableCompletion = true;
      enableBashCompletion = true;
      enableFzfCompletion = true;
      enableFzfHistory = true;

      variables = {
        ZDOTDIR = "$HOME/.config/zsh";
      };
    };

    # Register zsh as a valid login shell
    environment.shells = [
      pkgs.zsh
    ];

    # Make it your default shell
    users.users.ovation = {
      shell = pkgs.zsh;
    };
  };
}
