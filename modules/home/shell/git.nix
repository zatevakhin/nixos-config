{...}: {
  flake.homeModules.git = {...}: {
    programs.git = {
      enable = true;
      lfs.enable = true;

      extraConfig = {
        init.defaultBranch = "main";

        pull = {
          rebase = true;
        };
      };
    };
  };
}
