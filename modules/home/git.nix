{ ... }: {
  flake.modules.homeManager.git = { ... }: {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Ovation";
        user.email = "reach-gaurav-joshi@protonmail.com";
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "nvim";
      };
    };
  };
}
