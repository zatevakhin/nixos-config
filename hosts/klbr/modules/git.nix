{...}: {
  flake.homeModules.git = {
    hostname,
    inputs,
    lib,
    ...
  }: let
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
    };

    programs.ssh = {
      enable = true;
    };
  };
}
