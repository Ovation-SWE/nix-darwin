{ ... }: {
  flake.modules.homeManager.git = { ... }: {
    programs.git = {
      enable = true;
      userName = "Ovation";
      userEmail = "reach-gaurav-joshi@protonmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "nvim";
      };
    };
  };
}
