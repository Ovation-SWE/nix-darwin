{ ... }: {
  flake.modules.darwin.aerospace = { ... }: {
    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
    };
  };

  flake.modules.homeManager.aerospace = { pkgs, ... }: {
    home.file.".aerospace.toml".text = ''
      [gaps]
      inner.horizontal = 8
      inner.vertical   = 8
      outer.left       = 8
      outer.bottom     = 8
      outer.top        = 8
      outer.right      = 8

      [mode.main.binding]
      # Open an Emacs frame via the running daemon (started by the emacs-daemon
      # LaunchAgent). Falls back to starting a new daemon if none is running.
      alt-e = 'exec-and-forget ${pkgs.emacs-macport}/bin/emacsclient -c -n --alternate-editor=""'

      # Workspace switching
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'

      # Move focused window to workspace
      alt-shift-1 = 'move-node-to-workspace 1'
      alt-shift-2 = 'move-node-to-workspace 2'
      alt-shift-3 = 'move-node-to-workspace 3'
      alt-shift-4 = 'move-node-to-workspace 4'
      alt-shift-5 = 'move-node-to-workspace 5'

      # Focus movement
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # Window movement
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # Layout toggles
      alt-slash    = 'layout tiles horizontal vertical'
      alt-comma    = 'layout accordion horizontal vertical'
      alt-f        = 'fullscreen'
      alt-shift-f  = 'layout floating tiling'
    '';
  };
}
