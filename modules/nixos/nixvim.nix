{
  lib,
  pkgs-unstable,
  inputs,
  system,
  ...
}: let
  mcphub-nvim = inputs.mcphub-nvim.packages."${system}".default;
  mcp-hub = inputs.mcp-hub.packages."${system}".default;
in {
  # NOTE: Disable default neovim because it is enabled in `base.nix`
  programs.neovim.enable = lib.mkForce false;

  environment.systemPackages = [
    mcp-hub
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    # NOTE: https://github.com/nix-community/nixvim/issues/1784#issuecomment-2597937850
    nixpkgs.useGlobalPackages = false;

    extraPlugins = with pkgs-unstable.vimPlugins; [
      iron-nvim
      blink-cmp-avante
      blink-cmp-conventional-commits
      mcphub-nvim
    ];
    extraConfigLua =
      /*
      lua
      */
      ''
        require("mcphub").setup({
            port = 3000,
            config = vim.fn.expand("~/.config/mcp-hub/mcp-servers.json"),
            cmd = "${mcp-hub}/bin/mcp-hub",
        })

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
        action = "<cmd>Telescope buffers<CR>";
        key = "<C-b>";
        mode = [
          "n"
          "v"
          "i"
        ];
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
      {
        action = "<cmd>MCPHub<CR>";
        key = "<leader>mh";
        mode = "n";
        options = {
          desc = "Undo history";
        };
      }
      {
        action = "<cmd>Gitsigns stage_hunk<CR>";
        key = "<space>gsh";
        mode = "n";
        options = {
          desc = "Gitsigns stage hunk";
        };
      }
    ];

    plugins.avante = {
      enable = true;
      package = pkgs-unstable.vimPlugins.avante-nvim;

      settings = {
        mode = "agentic";
        behaviour = {
          # auto_suggestions = true;
          enable_cursor_planning_mode = true;
          jump_result_buffer_on_finish = false;
        };

        disabled_tools = [
          "python"
          "web_search"
          "list_files"
          "search_files"
          "read_file"
          "create_file"
          "rename_file"
          "delete_file"
          "create_dir"
          "rename_dir"
          "delete_dir"
          "bash"
        ];

        system_prompt.__raw = ''
          function()
            local hub = require("mcphub").get_hub_instance()
            return hub and hub:get_active_servers_prompt() or ""
          end
        '';

        custom_tools.__raw = ''
          function()
                 return {
                   require("mcphub.extensions.avante").mcp_tool(),
               }
          end
        '';

        windows = {
          sidebar_header.enabled = false;
          ask.start_insert = false;
        };

        hints.enabled = false;

        provider = "gemini";

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

          "grok-3" = {
            __inherited_from = "openai";
            endpoint = "https://api.x.ai/v1";
            api_key_name = "XAI_API_KEY";
            model = "grok-3";
          };

          "grok-3-mini" = {
            __inherited_from = "openai";
            endpoint = "https://api.x.ai/v1";
            api_key_name = "XAI_API_KEY";
            model = "grok-3-mini";
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

          "gemini-2.5-flash" = {
            __inherited_from = "gemini";
            model = "gemini-2.5-flash";
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
        };
      };
    };

    plugins.which-key.enable = true;
    plugins.lualine = {
      enable = true;
      settings = {
        sections.lualine_x = [
          {
            __unkeyed-1 = {
              __raw = ''
                function()
                    -- Check if MCPHub is loaded
                    if not vim.g.loaded_mcphub then
                        return "󰐻 -"
                    end

                    local count = vim.g.mcphub_servers_count or 0
                    local status = vim.g.mcphub_status or "stopped"
                    local executing = vim.g.mcphub_executing

                    -- Show "-" when stopped
                    if status == "stopped" then
                        return "󰐻 -"
                    end

                    -- Show spinner when executing, starting, or restarting
                    if executing or status == "starting" or status == "restarting" then
                        local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                        local frame = math.floor(vim.loop.now() / 100) % #frames + 1
                        return "󰐻 " .. frames[frame]
                    end

                    return "󰐻 " .. count
                end,
                color = function()
                    if not vim.g.loaded_mcphub then
                        return { fg = "#6c7086" } -- Gray for not loaded
                    end

                    local status = vim.g.mcphub_status or "stopped"
                    if status == "ready" or status == "restarted" then
                        return { fg = "#50fa7b" } -- Green for connected
                    elseif status == "starting" or status == "restarting" then
                        return { fg = "#ffb86c" } -- Orange for connecting
                    else
                        return { fg = "#ff5555" } -- Red for error/stopped
                    end
                end
              '';
            };
          }
          "encoding"
          "fileformat"
          "filetype"
        ];
      };
    };
    plugins.bufferline.enable = true;
    plugins.direnv.enable = true;
    plugins.barbecue.enable = true;
    plugins.git-worktree.enable = true;
    plugins.git-worktree.enableTelescope = true;
    plugins.todo-comments.enable = true;
    # https://github.com/tris203/precognition.nvim
    plugins.precognition.enable = false;

    plugins.telescope = {
      enable = true;

      keymaps = {
        "<space>ff" = "find_files";
        "<space>fb" = "buffers";
        "<space>fd" = "diagnostics";
        "<space>fg" = "live_grep";
        "<space>fr" = "registers";
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
        file_types = [
          "markdown"
          "Avante"
        ];
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
    plugins.blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        appearance = {
          nerd_font_variant = "mono";
        };
        keymap = {
          preset = "enter";
        };
        fuzzy = {
          implementation = "prefer_rust_with_warning";
        };
        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
            };
          };
          documentation = {
            auto_show = true;
          };
          ghost_text = {
            enabled = true;
          };
        };
        signature = {
          enabled = true;
        };
        cmdline = {
          sources = ["cmdline" "buffer"];
        };
        sources = {
          default = ["lsp" "path" "buffer" "avante" "conventional_commits"];
          lsp = {
            fallbacks = [];
          };
          buffer = {};
          path = {};
          providers = {
            avante = {
              enabled = true;
              module = "blink-cmp-avante";
              name = "Avante";
              opts = {};
            };
            conventional_commits = {
              name = "Conventional Commits";
              module = "blink-cmp-conventional-commits";
              enabled.__raw = ''
                function()
                  return vim.bo.filetype == 'gitcommit'
                end
              '';
              opts = {};
            };
          };
        };
      };
    };
    # </cmp>

    # <format>
    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        formatters_by_ft = {
          nix = [
            "alejandra"
          ];
        };
        format_on_save = {
          lsp_format = "fallback";
        };
      };
    };
    # </format>

    # <lsp>
    plugins.lsp = {
      enable = true;
      keymaps.lspBuf = {
        K = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
      };

      servers = {
        typos_lsp.enable = true;
        clangd.enable = true;
        jsonls.enable = true;
        helm_ls.enable = true;
        yamlls.enable = true;
        pyright.enable = true;
        ruff.enable = true;
        # https://github.com/oxalica/nil
        nil_ls.enable = true;
        dockerls.enable = true;
        docker_compose_language_service.enable = true;
        rust_analyzer.enable = true;
        rust_analyzer.installRustc = false;
        rust_analyzer.installCargo = false;
      };
    };

    plugins.lsp-lines.enable = true;
    plugins.lsp-status = {
      enable = true;
      settings = {
        spinner_frames = [
          "⣾"
          "⣽"
          "⣻"
          "⢿"
          "⡿"
          "⣟"
          "⣯"
          "⣷"
        ];
      };
    };

    # </lsp>

    plugins.vim-dadbod.enable = true;
    plugins.vim-dadbod-ui.enable = true;
    plugins.vim-dadbod-completion.enable = true;

    # <treesitter>
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        ensure_installed = [
          "c"
          "cpp"
          "python"
          "rust"
          "vim"
          "regex"
          "lua"
          "bash"
          "markdown"
          "markdown_inline"
          "gdscript"
          "godot_resource"
          "requirements"
          "gitattributes"
          "gitcommit"
          "gitignore"
          "ini"
        ];
        incremental_selection.enable = true;
      };
    };

    # https://github.com/nvim-treesitter/nvim-treesitter-context
    plugins.treesitter-context = {
      enable = true;
      settings = {
        multiline_threshold = 3;
      };
    };
    plugins.treesitter-refactor = {
      enable = true;
      navigation.enable = true;
      smartRename.enable = true;
      # BUG: Neovim hangs sometimes on line deletion and other cases when this option is enabled.
      highlightDefinitions.enable = true;
    };
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
