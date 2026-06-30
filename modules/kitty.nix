# modules/kitty.nix
{ ... }: {
  flake.modules.darwin.kitty = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      kitty
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
    ];

    # Kitty configuration is NOT managed by Nix.
    # It lives entirely in:
    #
    #   ~/.config/kitty/
    #
    # No Home Manager.
    # No programs.kitty.
    # No generated kitty.conf.
  };
}
