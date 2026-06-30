{ ... }: {
  flake.modules.darwin.macos-defaults = { ... }: {
    system.defaults = {
      dock = {
        autohide               = true;
        autohide-delay         = 0.0;
        autohide-time-modifier = 0.0;
        show-recents           = false;
        static-only            = true;
        mru-spaces             = false;
        tilesize               = 48;
        orientation            = "bottom";
        minimize-to-application = true;
        launchanim             = false;
      };

      spaces.spans-displays = false;

      NSGlobalDomain = {
        NSWindowResizeTime                   = 0.001;
        InitialKeyRepeat                     = 15;
        KeyRepeat                            = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled     = false;
        NSAutomaticDashSubstitutionEnabled   = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled  = false;
        AppleKeyboardUIMode                  = 3;
      };

      finder = {
        AppleShowAllExtensions  = true;
        ShowStatusBar           = true;
        ShowPathbar             = true;
        FXPreferredViewStyle    = "Nlsv";
        FXDefaultSearchScope    = "SCcf";
        _FXShowPosixPathInTitle = true;
      };

      screensaver = {
        askForPassword      = true;
        askForPasswordDelay = 0;
      };
    };
  };
}
