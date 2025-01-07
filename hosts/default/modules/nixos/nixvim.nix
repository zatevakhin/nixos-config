{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    opts = {
      list = true;
      listchars = "trail:•";
      signcolumn = "yes";
      fileformat = "unix";
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
        providers.wl-copy.enable = true;
        # TODO: Add flag for x11 based systems.
        # providers.xclip.enable = true;
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
        action = "<cmd>Telescope projects<CR>";
        key = "<C-p>";
        mode = ["n" "v" "i"];
        options = {
          desc = "Show project select list.";
        };
      }
      {
        action = "<cmd>Neotree focus<CR>";
        key = "<C-f>";
        mode = ["n" "v" "i"];
        options = {
          desc = "Focus Neotree";
        };
      }
      {
        action = "<cmd>tabnew<CR>";
        key = "<leader>tw";
        mode = ["n"];
        options = {
          desc = "New tab";
        };
      }
      {
        action = "<cmd>tabnext<CR>";
        key = "<leader>tn";
        mode = ["n"];
        options = {
          desc = "Next tab";
        };
      }
      {
        action = "<cmd>tabprevious<CR>";
        key = "<leader>tp";
        mode = ["n"];
        options = {
          desc = "Next tab";
        };
      }
      {
        action = "<cmd>tabclose<CR>";
        key = "<leader>tc";
        mode = ["n"];
        options = {
          desc = "Close tab";
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

    extraPlugins = [
    ];

    plugins.avante = {
      enable = true;
      settings = {
        hints.enabled = false;
        windows.sidebar_header.enabled = false;
        provider = "ollama";

        behaviour = {
          auto_suggestions = false;
        };
        vendors = {
          ollama = {
            __inherited_from = "openai";
            api_key_name = "";
            endpoint = "http://falke.lan:11434/v1";
            model = "qwen2.5-coder:7b";
          };
        };
      };
    };

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

    plugins.notify.enable = true;
    plugins.noice = {
      enable = true;
      settings = {
        notify.enabled = true;
        popupmenu.enabled = true;
        lsp.override = {
          "cmp.entry.get_documentation" = true;
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
        };
      };
    };

    plugins.helm.enable = true;
    plugins.trouble.enable = true;
    plugins.comment.enable = true;
    plugins.render-markdown = {
      enable = true;
      settings = {
        code.language_name = false;
      };
    };

    plugins.image = {
      # BUG: Disabled due to markdown rendered incorrectly with images.
      enable = false;
      extraOptions = {
        markdown = {
          clear_in_insert_mode = true;
        };
      };
      tmuxShowOnlyInActiveWindow = true;
      windowOverlapClearEnabled = true;
    };

    colorschemes.kanagawa.enable = true;
    plugins.web-devicons.enable = true;
    plugins.mini = {
      enable = true;
      modules = {
        icons.style = "glyph";
      };
    };

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
      {name = "vim-dadbod-completion";}
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
    plugins.lsp.servers.typos_lsp.enable = true;
    plugins.lsp.servers.jsonls.enable = true;
    plugins.lsp.servers.helm_ls.enable = true;
    # plugins.lsp.servers.yamlls.enable = true;
    plugins.lsp.servers.pyright.enable = true;
    # plugins.lsp.servers.ruff.enable = true;
    plugins.lsp.servers.nil_ls.enable = true;
    plugins.lsp.servers.dockerls.enable = true;
    plugins.lsp.servers.docker_compose_language_service.enable = true;
    plugins.lsp.servers.rust_analyzer.enable = true;
    plugins.lsp.servers.rust_analyzer.installRustc = false;
    plugins.lsp.servers.rust_analyzer.installCargo = false;

    # </lsp>

    plugins.vim-dadbod.enable = true;
    plugins.vim-dadbod-ui.enable = true;
    plugins.vim-dadbod-completion.enable = true;

    # <treesitter>
    plugins.treesitter = {
      enable = true;
      settings = {
        ensure_installed = ["c" "python" "rust" "vim" "regex" "lua" "bash" "markdown" "markdown_inline"];
        incremental_selection.enable = true;
      };
    };

    plugins.treesitter-context.enable = true;
    plugins.treesitter-refactor.enable = true;
    plugins.treesitter-refactor.navigation.enable = true;
    plugins.treesitter-refactor.smartRename.enable = true;
    # BUG: Neovim hangs sometimes on line deletion and other cases when this option is enabled.
    # plugins.treesitter-refactor.highlightDefinitions.enable = true;
    plugins.treesitter-textobjects.enable = true;
    # </treesitter>
  };
}
