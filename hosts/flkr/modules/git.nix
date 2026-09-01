{...}: {
  flake.homeModules.git = {
    hostname,
    lib,
    ...
  }: let
    me = import ../../../secrets/${hostname}/user.nix;
    isWorkDir = "pwd | grep -q '^/projects/work\\(/\\|$\\)'";
  in {
    programs.git = {
      settings = {
        commit.gpgsign = true;
        gpg.format = "ssh";

        user.name = "Ivan Zatevakhin";
        user.email = me.personal.email;
        user.signingkey = "~/.ssh/zatevakhin-personal.github.pub";
      };
      includes = [
        {
          condition = "gitdir:/projects/work/";

          contents.user.name = me.work.name;
          contents.user.email = me.work.email;
          contents.user.signingkey = "~/.ssh/${me.work.key}";
        }
      ];
    };

    programs.ssh = {
      enable = true;

      matchBlocks = {
        # === WORK KEY ===
        "github-work" = lib.hm.dag.entryBefore ["github-personal"] {
          match = ''host github.com exec "${isWorkDir}"'';
          identityFile = "~/.ssh/${me.work.key}";
          identitiesOnly = true;
          user = "git";
        };

        # === PERSONAL KEY ===
        "github-personal" = {
          match = ''host github.com !exec "${isWorkDir}"'';
          identityFile = "~/.ssh/zatevakhin-personal.github";
          identitiesOnly = true;
          user = "git";
        };
      };
    };
  };
}
