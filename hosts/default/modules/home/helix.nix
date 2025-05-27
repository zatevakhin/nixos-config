{pkgs, ...}: {
  programs.helix = {
    enable = true;

    package = pkgs.evil-helix;

    settings = {
      theme = "kanagawa";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        mouse = true;
        line-number = "relative";
        lsp.display-messages = true;
        file-picker.hidden = false;
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          language-servers = ["nixd"];
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
        {
          name = "python";
          language-servers = ["pyright" "ruff"];
          auto-format = true;

          formatter = {
            command = "${pkgs.ruff}/bin/ruff";
            args = ["format" "-"];
          };
        }
      ];
      language-server = {
        nixd.command = "${pkgs.nixd}/bin/nixd";
        ruff = {
          command = "${pkgs.ruff}/bin/ruff";
          args = ["server"];
        };
        pyright = {
          command = "${pkgs.pyright}/bin/pyright-langserver";
          args = ["--stdio"];
        };
      };

      grammar = [
        {
          name = "python";
        }
        {
          name = "nix";
        }
      ];
    };
  };
}
