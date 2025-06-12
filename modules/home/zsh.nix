{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true;

    initContent = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      cat = "${pkgs.bat}/bin/bat";
      gcs = "${pkgs.git}/bin/git commit -S";
      gcu = "${pkgs.git}/bin/git commit";
      gp = "${pkgs.git}/bin/git push";
      gl = "${pkgs.git}/bin/git pull";
      gs = "${pkgs.git}/bin/git status --short";
      gsl = "${pkgs.git}/bin/git status";
      glg = "${pkgs.git}/bin/git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    };

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
    };

    zplug = {
      enable = true;
      plugins = [
        {name = "tcnksm/docker-alias";}
        {name = "wfxr/forgit";}
        {name = "jeffreytse/zsh-vi-mode";}
      ];
    };
  };

  programs.starship.enableZshIntegration = true;
  programs.zoxide.enableZshIntegration = true;
  programs.fzf.enableZshIntegration = true;

  home.packages = with pkgs; [bat eza];
}
