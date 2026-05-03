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

        commit.gpgsign = true;
        gpg.format = "ssh";
      };
    };
  };
}
