{...}: {
  flake.homeModules.git = {
    hostname,
    lib,
    ...
  }: let
    me = import ../../../secrets/${hostname}/user.nix;
  in {
    programs.git = {
      settings = {
        commit.gpgsign = true;
        gpg.format = "ssh";

        user.name = "Ivan Zatevakhin";
        user.email = me.personal.email;
        user.signingkey = "~/.ssh/zatevakhin-personal.github.pub";
      };
    };

    programs.ssh = {
      enable = true;
    };
  };
}
