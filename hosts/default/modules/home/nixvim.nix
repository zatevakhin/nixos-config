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
  };
}
