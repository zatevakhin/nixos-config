{...}: {
  programs.helix = {
    enable = true;
    settings = {
      editor = {
        mouse = true;
        line-number = "relative";
        lsp.display-messages = true;
        file-picker.hidden = false;
      };
    };
  };
}
