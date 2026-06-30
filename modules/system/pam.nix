{ ... }: {
  flake.modules.darwin.pam = { pkgs, ... }: {
    # sudo_local is sourced by /etc/pam.d/sudo on macOS 13+.
    # pam_reattach is required for third-party terminals (Kitty, iTerm2, etc.)
    # that aren't in the user's bootstrap security session.
    environment.etc."pam.d/sudo_local" = {
      enable = true;
      text = ''
        auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
        auth       sufficient     pam_tid.so
      '';
    };
  };
}
