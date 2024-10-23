{...}: {
  imports = [
    ./starship-mini.nix
  ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    ohMyZsh = {
      enable = true;
    };
  };
}
