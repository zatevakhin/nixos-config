{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true;

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      cat = "${pkgs.bat}/bin/bat";
    };

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      theme = "ys";
    };

    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
        {name = "zsh-users/zsh-syntax-highlighting";}
        {name = "zsh-users/zsh-completions";}
        {name = "tcnksm/docker-alias";}
        {name = "wfxr/forgit";}
      ];
    };
  };
}
