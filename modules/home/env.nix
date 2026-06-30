{ ... }: {
  flake.modules.homeManager.env = { ... }: {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".hushlogin".text = "";
  };
}
