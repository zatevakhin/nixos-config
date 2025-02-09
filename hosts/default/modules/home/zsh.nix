{pkgs, ...}: {
  programs.zsh = {
    # https://mynixos.com/search?q=programs.zsh

    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true;

    initExtra = ''
      eval "$(${pkgs.micromamba}/bin/micromamba shell hook --shell zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      cat = "${pkgs.bat}/bin/bat";
      # TODO: Move to `kitty.nix`.
      icat = "${pkgs.kitty}/bin/kitty icat";

      gcs = "${pkgs.git}/bin/git commit -S";
      gcu = "${pkgs.git}/bin/git commit";
      gp = "${pkgs.git}/bin/git push";
      gl = "${pkgs.git}/bin/git pull";
      gs = "${pkgs.git}/bin/git status --short";
      gsl = "${pkgs.git}/bin/git status";
      glg = "${pkgs.git}/bin/git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";

      mamba = "${pkgs.micromamba}/bin/micromamba";
      conda = "${pkgs.micromamba}/bin/micromamba";
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
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf.enable = true;

  programs.fastfetch.enable = true;
}
