{...}: {
  flake.nixosModules.base = {
    pkgs,
    lib,
    ...
  }: {
    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [zsh];

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
      };
    };

    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        format = lib.concatStrings [
          "$all$username$hostname$directory"
          "\n"
          "$character"
        ];
        scan_timeout = 10;
        character = {
          success_symbol = "[\\$](bold green)";
          error_symbol = "[\\$](bold red)";
        };

        directory = {
          truncate_to_repo = false;
          style = "bold yellow";
        };
        username = {
          show_always = true;
          style_user = "cyan";
        };
        hostname = {
          ssh_only = false;
        };
      };
    };
  };
}
