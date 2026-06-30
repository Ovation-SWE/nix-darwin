{ ... }: {
  flake.modules.homeManager.secrets = { ... }: {
    # secretspec user config: use Proton Pass (via pass-cli) as provider
    # Vault named "secretspec" in Proton Pass, items titled {project}/{profile}/{key}
    home.file.".config/secretspec/config.toml".text = ''
      [defaults]
      provider = "protonpass"

      [providers]
      protonpass = "protonpass://secretspec"
    '';
  };
}
