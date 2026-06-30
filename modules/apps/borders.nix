{ ... }: {
  # borders can't be managed via brew bundle because nix-darwin runs it in a
  # different user context where `brew trust` data isn't visible. Install via
  # home-manager activation instead, which runs as the actual user.
  flake.modules.homeManager.borders = { lib, ... }: {
    home.activation.installBorders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! /opt/homebrew/bin/brew list --formula borders &>/dev/null 2>&1; then
        $DRY_RUN_CMD /opt/homebrew/bin/brew install FelixKratz/formulae/borders
      fi
    '';
  };
}
