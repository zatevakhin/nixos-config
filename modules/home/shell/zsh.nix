{...}: {
  flake.homeModules.zsh = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      autocd = true;

      initContent = ''
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';

      shellAliases = {
        ls = "${pkgs.eza}/bin/eza";
        cat = "${pkgs.bat}/bin/bat";
      };

      history.size = 10000;

      oh-my-zsh = {
        enable = true;
      };

      zplug = {
        enable = true;
        plugins = [];
      };
    };

    programs.starship = {
      enable = true;
      enableTransience = true;
      enableZshIntegration = true;

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

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [bat eza];
  };
}
