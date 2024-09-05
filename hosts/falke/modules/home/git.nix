{...}: let
  me = import ../../secrets/user.nix;
in {
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
      # user.signingkey = "~/.ssh/zatevakhin-personal.github.pub";
    };

    userName = "Ivan Zatevakhin";
    userEmail = me.personal.email;
    includes = [
      {
        condition = "gitdir:/projects/work/";

        contents.user.name = me.work.name;
        contents.user.email = me.work.email;
        # contents.user.signingkey = "~/.ssh/${me.work.key}";
      }
    ];
  };
}
