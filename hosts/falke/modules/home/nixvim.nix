{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    colorschemes.gruvbox.enable = true;
    plugins.lualine.enable = true;
  };
}
