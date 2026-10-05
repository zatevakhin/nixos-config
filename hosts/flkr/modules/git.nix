{...}: {
  flake.homeModules.flkr-git = {
    hostname,
    inputs,
    lib,
    ...
  }: let
    isWorkDir = "pwd | grep -q '^/projects/work\\(/\\|$\\)'";
    notsecrets = lib.importTOML "${inputs.notsecrets}/default.toml";
  in {
    programs.git = {
      settings = {
        commit.gpgsign = true;
        gpg.format = "ssh";

        user.name = "${notsecrets.names.pseudo.name} ${notsecrets.names.pseudo.lastname}";
        user.email = notsecrets.emails.personal;
        user.signingkey = "~/.ssh/zatevakhin-personal.github.pub";
      };
      includes = [
        {
          condition = "gitdir:/projects/work/";

          contents.user.name = "${notsecrets.names.real.name} ${notsecrets.names.real.lastname}";
          contents.user.email = notsecrets.emails.work;
          contents.user.signingkey = "~/.ssh/nc.gitlab_ed25519.pub";
        }
      ];
    };

    programs.ssh = {
      enable = true;

      matchBlocks = {
        # === WORK KEY ===
        "github-work" = lib.hm.dag.entryBefore ["github-personal"] {
          match = ''host github.com exec "${isWorkDir}"'';
          identityFile = "~/.ssh/nc.gitlab_ed25519.pub";
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
