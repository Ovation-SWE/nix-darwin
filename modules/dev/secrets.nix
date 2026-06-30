{ ... }: {
  flake.modules.darwin.secrets = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnupg
      pass
      secretspec
      devenv
    ];

    # devenv needs to be a trusted nix user to set build overrides
    nix.settings.trusted-users = [ "root" "ovation" ];

    # devenv binary cache — avoids building devenv from source
    nix.settings.substituters = [
      "https://cache.nixos.org"
      "https://devenv.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };
}
