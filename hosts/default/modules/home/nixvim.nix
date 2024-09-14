{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    opts = {
      list = true;
      listchars = "trail:•";
      signcolumn = "yes";
      number = true;
      relativenumber = true;
      termguicolors = true;
      shiftwidth = 4;
      tabstop = 4;
      softtabstop = 0;
      expandtab = true;
      smarttab = true;
      cursorline = true;
      splitbelow = true;
      splitright = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;
      updatetime = 300;
      swapfile = false;
      undofile = true;
      clipboard = {
        register = "unnamedplus";
        providers.xclip.enable = true;
      };
    };

    keymaps = [
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<C-b>";
        mode = "n";
        options = {
          desc = "Toggle Tree View.";
        };
      }
      {
        action = "<cmd>Neotree focus<CR>";
        key = "<leader>ft";
        mode = "n";
        options = {
          desc = "Focus on Neotree.";
        };
      }
    ];

    plugins.lualine.enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
      };
    };

    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = true;
    };

    plugins.toggleterm = {
      enable = true;

      settings = {
        size = 15;
        open_mapping = "[[<leader>tt]]";
      };
    };

    plugins.neo-tree = {
      enable = true;
      enableGitStatus = true;
      enableModifiedMarkers = true;
      enableRefreshOnWrite = true;

      filesystem.filteredItems.hideDotfiles = false;

      window = {
        width = 35;

        popup = {
          position = "50%";
        };
      };
    };

    # <cmp>
    plugins.cmp.enable = true;
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-path.enable = true;
    plugins.cmp-buffer.enable = true;
    plugins.cmp-treesitter.enable = true;

    plugins.cmp_luasnip.enable = true;
    plugins.cmp.settings.mapping = {
      "<CR>" = "cmp.mapping.confirm({ select = true })";
      "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
      "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
    };

    plugins.cmp.settings.sources = [
      {name = "nvim_lsp";}
      {name = "luasnip";}
      {name = "path";}
      {name = "buffer";}
    ];

    plugins.cmp.settings.snippet = {
      expand = "function(args) require('luasnip').lsp_expand(args.body) end";
    };
    # </cmp>

    # <lsp>
    plugins.lsp-status.enable = true;
    plugins.lsp.enable = true;
    plugins.lsp.keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };
    plugins.lsp.servers.typos-lsp.enable = true;
    plugins.lsp.servers.bashls.enable = true;
    plugins.lsp.servers.jsonls.enable = true;
    plugins.lsp.servers.yamlls.enable = true;
    plugins.lsp.servers.pyright.enable = true;
    plugins.lsp.servers.ruff-lsp.enable = true;
    plugins.lsp.servers.nixd.enable = true;
    plugins.lsp.servers.dockerls.enable = true;
    plugins.lsp.servers.rust-analyzer.enable = true;
    plugins.lsp.servers.rust-analyzer.installCargo = true;
    plugins.lsp.servers.rust-analyzer.installRustc = true;
    # </lsp>

    # <treesitter>
    plugins.treesitter = {
      enable = true;
      ensureInstalled = ["c" "python" "rust"];
    };

    plugins.treesitter.incrementalSelection.enable = true;
    plugins.treesitter-context.enable = true;
    plugins.treesitter-refactor.enable = true;
    plugins.treesitter-refactor.navigation.enable = true;
    plugins.treesitter-refactor.smartRename.enable = true;
    plugins.treesitter-refactor.highlightDefinitions.enable = true;
    # </treesitter>
  };
}
