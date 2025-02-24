{
  self,
  inputs,
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}: let
  ssh = import ./secrets/ssh.nix;
in {
  imports = [
    ./modules/nixos/nixvim.nix
  ];

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = ./secrets/default.yaml;
    secrets.ssh-private-key = {
      key = "user/keys/ssh/private";
      owner = username;
    };
    secrets.ssh-public-key = {
      key = "user/keys/ssh/public";
      owner = username;
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    ssh.authorized.baseship
  ];

  networking.hostName = hostname;
  networking.computerName = "${hostname}";
  networking.localHostName = "${hostname}";
  security.pam.enableSudoTouchIdAuth = true;

  environment.systemPackages = with pkgs; [
    mc
    htop
    kitty
    tmux
    mkalias
    obsidian
    jq
    curl
    tealdeer
    git-agecrypt
  ];

  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap"
    ];
    casks = [
      "xquartz"
      "zen-browser"
    ];
    masApps = {};
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
      minimize-to-application = true;
      persistent-apps = [
        "/Applications/Zen Browser.app"
        "${pkgs.kitty}/Applications/kitty.app"
        "${pkgs.obsidian}/Applications/Obsidian.app"
        "/Applications/Slack.app"
      ];
    };
    finder = {
      ShowPathbar = true;
      CreateDesktop = false;
    };
    loginwindow.GuestEnabled = false;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleTemperatureUnit = "Celsius";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      NSWindowShouldDragOnGesture = true;
    };
    WindowManager = {
      StandardHideWidgets = true;
      StageManagerHideWidgets = true;
      StandardHideDesktopIcons = true;
    };
    menuExtraClock.Show24Hour = true;
  };

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs username;};
    users.${username} = import ./home.nix;
    sharedModules = [
      inputs.sops-nix-unstable.homeManagerModules.sops
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable shell support in nix-darwin.
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  #environment.sessionVariables = {};

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Allow Unfree packages
  nixpkgs.config.allowUnfree = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
