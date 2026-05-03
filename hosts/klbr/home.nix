{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.klbr-home = {
    pkgs-unstable,
    username,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {inherit inputs username pkgs-unstable;};
      sharedModules = [
        self.homeModules.gnome
        self.homeModules.ghostty

        inputs.sops-nix.homeManagerModules.sops
      ];

      users."${username}" = {
        # Home Manager needs a bit of information about you and the paths it should
        # manage.
        home.username = "${username}";
        home.homeDirectory = "/home/${username}";

        home.sessionVariables = {
          XDG_DATA_DIRS = "$XDG_DATA_DIRS/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
        };

        # This value determines the Home Manager release that your configuration is
        # compatible with. This helps avoid breakage when a new Home Manager release
        # introduces backwards incompatible changes.
        #
        # You should not change this value, even if you update Home Manager. If you do
        # want to update the value, then make sure to first check the Home Manager
        # release notes.
        home.stateVersion = "25.11"; # Please read the comment before changing.

        # The home.packages option allows you to install Nix packages into your
        # environment.
        home.packages = [];

        # Home Manager is pretty good at managing dotfiles. The primary way to manage
        # plain files is through 'home.file'.
        home.file = {
          # # Building this configuration will create a copy of 'dotfiles/screenrc' in
          # # the Nix store. Activating the configuration will then make '~/.screenrc' a
          # # symlink to the Nix store copy.
          # ".screenrc".source = dotfiles/screenrc;
        };

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
  };
}
