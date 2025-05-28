{pkgs, ...}: {
  programs.fish = {
    enable = true;

    generateCompletions = true;

    shellInit = ''
      ${pkgs.direnv}/bin/direnv hook fish | source

      fish_vi_key_bindings
    '';

    shellAliases = {
      "..." = "cd ../..";
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

    plugins = [
    ];
  };

  programs.zoxide.enableFishIntegration = true;
  programs.fzf.enableFishIntegration = true;
}
