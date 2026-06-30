{ ... }: {
  flake.modules.darwin.browsers = { pkgs, ... }: {
    
    # 1. Enable nix-darwin's Homebrew management integration
    homebrew = {
      enable = true;
      
      # Optional: Leaves existing apps alone, but removes casks 
      # from your Mac if you delete them from this list later.
      onActivation.cleanup = "zap"; 

      # 2. Define your macOS Casks here
      casks = [
        "zen"
      ];
    };

  };
}
