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
      fixeol = true;
      endofline = true;
      clipboard = {
        register = "unnamedplus";
        providers.xclip.enable = true;
      };
    };

    keymaps = [
      {
        action = "<cmd>vsplit<CR>";
        key = "<leader>vv";
        mode = "n";
        options = {
          desc = "Split vertically";
        };
      }
      {
        action = "<cmd>split<CR>";
        key = "<leader>ss";
        mode = "n";
        options = {
          desc = "Split horizontally";
        };
      }
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<C-b>";
        mode = "n";
        options = {
          desc = "Toggle Tree View.";
        };
      }
      {
        action = "<cmd>Neogit<CR>";
        key = "<C-g>";
        mode = "n";
        options = {
          desc = "Toggle Neogit View.";
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
      {
        action = "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>";
        key = "<leader>wl";
        mode = "n";
        options = {
          desc = "List Git Worktrees";
        };
      }
      {
        action = "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>";
        key = "<leader>wc";
        mode = "n";
        options = {
          desc = "Create Git Worktree";
        };
      }
    ];

    plugins.which-key.enable = true;
    plugins.lualine.enable = true;
    plugins.bufferline.enable = true;
    plugins.direnv.enable = true;
    plugins.barbecue.enable = true;
    plugins.git-worktree.enable = true;
    plugins.git-worktree.enableTelescope = true;
    plugins.todo-comments.enable = true;
    plugins.precognition.enable = true;
    plugins.project-nvim.enable = true;
    plugins.project-nvim.enableTelescope = true;

    plugins.telescope = {
      enable = true;

      keymaps = {
        "<C-f>" = "find_files";
        "<leader>ff" = "find_files";
        "<leader>fb" = "buffers";
        "<leader>fg" = "live_grep";
      };
    };

    plugins.noice.enable = true;
    plugins.noice.notify.enabled = true;
    plugins.noice.popupmenu.enabled = true;

    plugins.helm.enable = true;
    plugins.trouble.enable = true;
    plugins.comment.enable = true;

    colorschemes.kanagawa.enable = true;

    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = true;
    };

    plugins.neogit.enable = true;

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
      closeIfLastWindow = true;
      gitStatusAsync = true;
      extraOptions = {
        use_libuv_file_watcher = true;
      };

      gitStatusAsyncOptions = {
        batchDelay = 10;
      };
      sourceSelector = {
        statusline = true;
        winbar = true;
      };

      filesystem.filteredItems.hideDotfiles = false;

      window = {
        width = 35;

        popup = {
          position = "50%";
        };
      };
    };

    plugins.netman.enable = true;
    plugins.netman.neoTreeIntegration = true;

    plugins.trim = {
      enable = true;
      settings = {
        highlight = false;
        trim_trailing = true;
        trim_on_write = true;
        trim_first_line = true;
        trim_last_line = false;
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
    plugins.lsp-lines.enable = true;
    plugins.lsp-status.enable = true;

    plugins.lsp-format.enable = true;
    plugins.none-ls.enable = true;
    plugins.none-ls.sources.formatting.alejandra.enable = true;

    plugins.lsp.enable = true;
    plugins.lsp.keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };
    plugins.lsp.servers.typos-lsp.enable = true;
    plugins.lsp.servers.jsonls.enable = true;
    plugins.lsp.servers.helm-ls.enable = true;
    plugins.lsp.servers.yamlls.enable = true;
    plugins.lsp.servers.pyright.enable = true;
    plugins.lsp.servers.ruff-lsp.enable = true;
    plugins.lsp.servers.nil-ls.enable = true;
    plugins.lsp.servers.dockerls.enable = true;
    plugins.lsp.servers.docker-compose-language-service.enable = true;
    plugins.lsp.servers.rust-analyzer.enable = true;
    # </lsp>

    # <treesitter>
    plugins.treesitter = {
      enable = true;
      ensureInstalled = ["c" "python" "rust" "vim" "regex" "lua" "bash" "markdown" "markdown_inline"];
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
