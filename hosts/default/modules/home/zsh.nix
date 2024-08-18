{pkgs, ...}: {
  programs.zsh = {
    # https://mynixos.com/search?q=programs.zsh

    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true;

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      cat = "${pkgs.bat}/bin/bat";
      gcs = "${pkgs.git}/bin/git commit -S";
      gcu = "${pkgs.git}/bin/git commit";
      gp = "${pkgs.git}/bin/git push";
      gl = "${pkgs.git}/bin/git pull";
      gs = "${pkgs.git}/bin/git status --short";
      gsl = "${pkgs.git}/bin/git status";
    };

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      theme = "ys";
    };

    zplug = {
      enable = true;
      plugins = [
        {name = "tcnksm/docker-alias";}
        {name = "wfxr/forgit";}
      ];
    };
  };
}
