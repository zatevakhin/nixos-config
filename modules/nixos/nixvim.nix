{
  lib,
  pkgs-unstable,
  ...
}: {
  # NOTE: Disable default neovim because it is enabled in `base.nix`
  programs.neovim.enable = lib.mkForce false;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    # NOTE: https://github.com/nix-community/nixvim/issues/1784#issuecomment-2597937850
    nixpkgs.useGlobalPackages = false;

    extraPlugins = [pkgs-unstable.vimPlugins.iron-nvim];
    extraConfigLua = ''
      -- require("mcphub").setup({
      --     port = 3000,
      --     config = vim.fn.expand("~/.config/mcp-hub/mcp-servers.json"),
      --     cmd = "{mcp-hub}/bin/mcp-hub"
      -- })

      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = {"zsh"}
            },
            python = {
              command = { "ipython", "--no-autoindent", "--colors=Linux" },
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
            }
          },
          repl_open_cmd = view.split.rightbelow("%25"),
          repl_filetype = function(bufnr, ft)
            return ft
          end,
        },
        keymaps = {
          toggle_repl = "<space>rr",
          restart_repl = "<space>rR",
          send_motion = "<space>sc",
          visual_send = "<space>sc",
          send_code_block = "<space>sb",
          send_code_block_and_move = "<space>sn",
          exit = "<space>sq",
          clear = "<space>cl",
          cr = "<space>s<cr>",
          interrupt = "<space>s<space>",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      }
    '';

    opts = {
      list = true;
      listchars = "trail:•";
      signcolumn = "yes";
      fileformat = "unix";
      number = true;
      relativenumber = true;
      termguicolors = true;
      scrolloff = 5; # From: hx defaults
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

    diagnostic.settings = {
      virtual_lines = {
        only_current_line = true;
      };
      virtual_text = false;
    };

    keymaps = [
      {
        action = "<Esc>";
        key = "jj";
        mode = "i";
        options = {
          desc = "Exit Insert mode with jj (alternative to <Esc>)";
          noremap = false;
        };
      }
      {
        action = "<Esc>";
        key = "jk";
        mode = "i";
        options = {
          desc = "Exit Insert mode with jk (alternative to <Esc>)";
          noremap = false;
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
        action = "<cmd>Telescope buffers<CR>";
        key = "<C-b>";
        mode = ["n" "v" "i"];
        options = {
          desc = "Show buffers select list.";
        };
      }

      {
        action = "<cmd>Neotree focus<CR>";
        key = "<space>fm";
        mode = ["n"];
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
      {
        action = "<cmd>Telescope undo<CR>";
        key = "<leader>u";
        mode = "n";
        options = {
          desc = "Undo history";
        };
      }
      {
        action = "<cmd>Telescope undo<CR>";
        key = "<leader>u";
        mode = "n";
        options = {
          desc = "Undo history";
        };
      }
    ];

    plugins.avante = {
      enable = true;
      package = pkgs-unstable.vimPlugins.avante-nvim.overrideAttrs (old: let
        # Define your new source and version
        new-src = pkgs-unstable.fetchFromGitHub {
          owner = "yetone";
          repo = "avante.nvim";
          rev = "d3c93c0dabb4311d0af30940726fb0bff30a9676";
          hash = "sha256-gZ4mrtoWN+ELEF5n5l/xE1MeXm7dfDCmXwbqIScjKaQ=";
        };
        new-version = "main";

        rebuilt-avante-nvim-lib = old.passthru.avante-nvim-lib.overrideAttrs (libOldAttrs: {
          version = new-version;
          src = new-src;
          cargoHash = "";
        });

        new-post-install = let
          ext = pkgs-unstable.stdenv.hostPlatform.extensions.sharedLibrary;
        in ''
          mkdir -p $out/build
          ln -s ${rebuilt-avante-nvim-lib}/lib/libavante_repo_map${ext} $out/build/avante_repo_map${ext}
          ln -s ${rebuilt-avante-nvim-lib}/lib/libavante_templates${ext} $out/build/avante_templates${ext}
          ln -s ${rebuilt-avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
          ln -s ${rebuilt-avante-nvim-lib}/lib/libavante_html2md${ext} $out/build/avante_html2md${ext}
        '';
      in {
        version = new-version;
        src = new-src;

        nvimSkipModule = [
          "avante.providers.ollama"
          "avante.providers.vertex_claude"
          "avante.providers.azure"
          "avante.providers.copilot"
          "avante.providers.gemini"
          "avante.providers.vertex"
        ];

        postInstall = new-post-install;
        passthru =
          (old.passthru or {})
          // {
            avante-nvim-lib = rebuilt-avante-nvim-lib;
          };
      });

      settings = {
        mode = "agentic";
        behaviour = {
          # auto_suggestions = true;
          enable_cursor_planning_mode = true;
          jump_result_buffer_on_finish = false;
        };

        windows = {
          sidebar_header.enabled = false;
          ask.start_insert = false;
        };

        hints.enabled = false;

        provider = "ollama";

        providers = {
          ollama = {
            endpoint = "http://ollama.homeworld.lan";
            model = "devstral:24b";
            extra_request_body = {
              num_ctx = 16384;
            };
          };
          "openai-4o-mini" = {
            __inherited_from = "openai";
            model = "4o-mini";
          };

          "openai-gpt-4o" = {
            __inherited_from = "openai";
            model = "gpt-4o";
          };

          "gpt-4.1-nano" = {
            __inherited_from = "openai";
            model = "gpt-4.1-nano";
          };

          "gpt-4.1-mini" = {
            __inherited_from = "openai";
            model = "gpt-4.1-mini";
          };

          "claude-opus-4-0" = {
            __inherited_from = "claude";
            model = "claude-opus-4-0";
          };

          "claude-sonnet-4-0" = {
            __inherited_from = "claude";
            model = "claude-sonnet-4-0";
          };

          "claude-3-7-sonnet-latest" = {
            __inherited_from = "claude";
            model = "claude-3-7-sonnet-latest";
          };

          "claude-3-5-sonnet-latest" = {
            __inherited_from = "claude";
            model = "claude-3-5-sonnet-latest";
          };

          "claude-3-5-haiku-latest" = {
            __inherited_from = "claude";
            model = "claude-3-5-haiku-latest";
          };

          "gemini-2.5-flash-preview-05-20" = {
            __inherited_from = "gemini";
            model = "gemini-2.5-flash-preview-05-20";
          };

          "gemini-2.5-pro-preview-05-06" = {
            __inherited_from = "gemini";
            model = "gemini-2.5-pro-preview-05-06";
          };

          "gemini-2.5-pro-preview-06-05" = {
            __inherited_from = "gemini";
            model = "gemini-2.5-pro-preview-06-05";
          };

          "qwen3:8b" = {
            __inherited_from = "ollama";
            model = "qwen3:8b";
          };
          "qwen3:14b" = {
            __inherited_from = "ollama";
            model = "qwen3:14b";
          };
          "qwen3:30b-a3b" = {
            __inherited_from = "ollama";
            model = "qwen3:30b-a3b";
          };
          "qwen3:32b" = {
            __inherited_from = "ollama";
            model = "qwen3:32b";
          };
          "devstral:24b" = {
            __inherited_from = "ollama";
            model = "devstral:24b";
          };
          "llama3.2:3b" = {
            __inherited_from = "ollama";
            model = "llama3.2:3b";
          };
          "llama3.1:8b" = {
            __inherited_from = "ollama";
            model = "llama3.1:8b";
          };
          "deepseek-r1:14b" = {
            __inherited_from = "ollama";
            model = "deepseek-r1:14b";
          };
          "deepseek-r1:32b" = {
            __inherited_from = "ollama";
            model = "deepseek-r1:32b";
          };
          "phi4:14b" = {
            __inherited_from = "ollama";
            model = "phi4:14b";
          };
          "gemma3:12b" = {
            __inherited_from = "ollama";
            model = "gemma3:12b";
            extra_request_body.num_ctx = 8192;
          };
          "gemma3:27b" = {
            __inherited_from = "ollama";
            model = "gemma3:27b";
            extra_request_body.num_ctx = 8192;
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
        "<space>ff" = "find_files";
        "<space>fb" = "buffers";
        "<space>fg" = "live_grep";
      };

      extensions = {
        undo = {
          enable = true;
          settings = {
            use_delta = true;
            mapping = {
              i = {
                "<c-cr>" = "require('telescope-undo.actions').restore";
                "<cr>" = "require('telescope-undo.actions').yank_additions";
                "<s-cr>" = "require('telescope-undo.actions').yank_deletions";
              };
              n = {
                Y = "require('telescope-undo.actions').yank_deletions";
                u = "require('telescope-undo.actions').restore";
                y = "require('telescope-undo.actions').yank_additions";
              };
            };
          };
        };
      };
    };

    plugins.snacks = {
      enable = true;
      settings = {
        notifier.enabled = true;
      };
    };

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
        file_types = ["markdown" "Avante"];
      };
    };

    plugins.image = {
      # BUG: Disabled due to markdown rendered incorrectly with images.
      enable = false;
      settings = {
        markdown = {
          clear_in_insert_mode = true;
        };

        tmux_show_only_in_active_window = true;
        window_overlap_clear_enabled = true;
      };
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

      sources = ["filesystem"];

      window = {
        # width = 35;
        position = "float";

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
    plugins.lspkind = {
      enable = true;
      cmp.enable = true;
    };

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
    plugins.lsp-status = {
      enable = true;
      settings = {
        spinner_frames = ["⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"];
      };
    };

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
    plugins.lsp.servers.clangd.enable = true;
    plugins.lsp.servers.jsonls.enable = true;
    plugins.lsp.servers.helm_ls.enable = true;
    # plugins.lsp.servers.yamlls.enable = true;
    plugins.lsp.servers.pyright.enable = true;
    plugins.lsp.servers.ruff.enable = true;
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
        highlight.enable = true;
        ensure_installed = ["c" "cpp" "python" "rust" "vim" "regex" "lua" "bash" "markdown" "markdown_inline"];
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
    plugins.hardtime = {
      enable = false;
    };

    plugins.tmux-navigator = {
      enable = true;
    };
  };
}
