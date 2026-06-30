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
        
        # FIX: Explicitly tell nix-darwin where the home folder lives
        users.users.ovation.home = "/Users/ovation";
 
        environment.systemPackages = [ pkgs.vim ]; 
      }) 

      # Inject Home Manager to load the homeManager modules automatically
      inputs.home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      home-manager.users.ovation = {
  home.username = "ovation";
  home.homeDirectory = "/Users/ovation";
  home.stateVersion = "26.05";

  imports = builtins.attrValues (config.flake.modules.homeManager or {});
};}
 
      # --- FULLY DENDRITIC AUTOMATION --- 
      # Automatically unpacks and activates every module found under config.flake.modules.darwin 
    ] ++ (builtins.attrValues (config.flake.modules.darwin or {})); 
  }; 
}
