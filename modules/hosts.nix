{ inputs, config, ... }: {
  flake.darwinConfigurations."Ovations-MacBook-Pro" = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      # Base System Core Options
      ({ pkgs, ... }: {
        _module.args.self = inputs.self;

        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
        system.stateVersion = 6;
        nixpkgs.hostPlatform = "aarch64-darwin";
        
        # Tells nix-darwin who owns Homebrew / user settings
        system.primaryUser = "ovation"; 

        environment.systemPackages = [ pkgs.vim ];
      })

      # --- FULLY DENDRITIC AUTOMATION ---
      # Automatically unpacks and activates every module found under config.flake.modules.darwin
    ] ++ (builtins.attrValues config.flake.modules.darwin);
  };
}
