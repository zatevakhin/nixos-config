{self, ...}: {
  flake.darwinModules.eulr-home = self.lib.mkDarwinHome {
    stateVersion = "26.05";
    extraUserModules = [
      ({
        config,
        lib,
        ...
      }: {
        home.file.".ssh/id_ed25519" = {
          enable = true;
          force = true;
          source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/ssh-private-key";
        };

        home.file.".ssh/id_ed25519.pub" = {
          enable = true;
          force = true;
          source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/ssh-public-key";
        };

        programs.zsh = {
          enable = true;
          initContent = ''
            # SSH/tmux often send xterm sequences that stock macOS zsh does not bind.
            # Unbound Delete/Home/End insert a literal "~".
            bindkey "^[[3~" delete-char
            bindkey "^[[1~" beginning-of-line
            bindkey "^[[4~" end-of-line
            bindkey "^[[7~" beginning-of-line
            bindkey "^[[8~" end-of-line
            bindkey "^[[H" beginning-of-line
            bindkey "^[[F" end-of-line
          '';
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
      })
    ];
  };
}
