{ ... }: {
  flake.modules.homeManager.secrets = { ... }: {
    # pass (password-store) managed by home-manager
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "$HOME/.password-store";
      };
    };

    # secretspec user config: sets pass as the default provider
    # Path format: secretspec/{project}/{profile}/{key}
    home.file.".config/secretspec/config.toml".text = ''
      [defaults]
      provider = "pass"

      [providers]
      pass = "pass://secretspec/{project}/{profile}/{key}"
    '';
  };
}
