{...}: {
  flake.darwinModules.eulr-configuration = {
    self,
    inputs,
    config,
    lib,
    pkgs,
    username,
    hostname,
    ...
  }: {
    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      defaultSopsFile = ../../secrets/${hostname}/default.yaml;
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOofyljh8apzd0uqhV/TKpPAyxWaiH52wQwKvKXn1WDn"
    ];

    system.primaryUser = username;
    system.startup.chime = false;
    networking.hostName = hostname;
    networking.computerName = "${hostname}";
    networking.localHostName = "${hostname}";

    # Sleep after 5 minutes idle. Stay awake only while an SSH session exists
    # (including notty: scp/git/vscode). Display is still allowed to sleep.
    system.activationScripts.sshKeepAwakeSleep.text = ''
      /usr/bin/pmset -a sleep 5
      /usr/bin/pmset -a ttyskeepawake 1
    '';

    launchd.daemons.ssh-keepawake = {
      command = lib.getExe (pkgs.writeShellScriptBin "ssh-keepawake" ''
        pid=""
        has_ssh() {
          /usr/bin/pgrep -f 'sshd-session:' >/dev/null 2>&1
        }
        stop() {
          if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
          fi
          pid=""
        }
        trap stop EXIT INT TERM
        while true; do
          if has_ssh; then
            if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
              /usr/bin/caffeinate -s &
              pid=$!
            fi
          else
            stop
          fi
          sleep 5
        done
      '');
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Background";
        Nice = 19;
      };
    };

    #security.pam.enableSudoTouchIdAuth = true;
    security.pam.services.sudo_local.touchIdAuth = true;
    security.pam.services.sudo_local.reattach = true;

    environment.systemPackages = with pkgs; [
      mc
      htop
      tmux
      mkalias
      jq
      curl
      git
      cocoapods
      xcodegen
      tealdeer
      git-agecrypt
    ];

    environment.variables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };

    nix-homebrew = {
      enable = true;
      user = username;
      autoMigrate = true;
      enableRosetta = false;
    };

    homebrew = {
      enable = true;
      taps = [
        "nikitabobko/tap"
      ];
      casks = [
        "xquartz"
        # zen is already installed. Homebrew 5.1.14 rejects the current
        # API cask (undefined method 'command_wrapper') and aborts bundle.
        "ghostty"
      ];
      masApps = {
        Xcode = 497799835;
      };
      onActivation.cleanup = "none"; # zap
      onActivation.autoUpdate = false;
      onActivation.upgrade = false;
    };

    system.activationScripts.postActivation.text = ''
      if [ -d /Applications/Xcode.app/Contents/Developer ]; then
        echo "initializing Xcode and iOS Simulator support..." >&2
        /usr/bin/xcode-select --switch /Applications/Xcode.app/Contents/Developer
        /usr/bin/xcodebuild -license accept
        /usr/bin/xcodebuild -runFirstLaunch

        if ! /usr/bin/xcrun simctl list runtimes 2>/dev/null | /usr/bin/grep -q '^iOS '; then
          echo "installing the current iOS Simulator runtime..." >&2
          /usr/bin/caffeinate -is /usr/bin/xcodebuild -downloadPlatform iOS
        fi
      else
        echo "warning: Xcode.app is not installed; skipping Xcode initialization" >&2
      fi
    '';

    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
        launchanim = false;
        mineffect = "scale";
        showhidden = true;
        static-only = false;
        tilesize = 36;
        minimize-to-application = true;
        persistent-apps = [
          "/Applications/Zen.app"
          "/Applications/Ghostty.app"
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;

        FXPreferredViewStyle = "Nlsv"; # list view
        FXRemoveOldTrashItems = true;

        NewWindowTarget = "Home";

        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;

        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        _FXEnableColumnAutoSizing = true;
      };
      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;

        # Kill some “magic gesture” nonsense.
        TrackpadThreeFingerTapGesture = 0;
        TrackpadTwoFingerDoubleTapGesture = false;
      };
      screencapture = {
        location = "~/Pictures/Screenshots";
        target = "file";
        type = "png";
        disable-shadow = true;
      };
      LaunchServices = {
        # I would leave this true unless you really know you want Linux-like YOLO app launching.
        # false disables quarantine prompts for downloaded apps.
        LSQuarantine = false;
      };
      loginwindow.GuestEnabled = false;
      NSGlobalDomain = {
        # Keyboard: make it behave less like a phone.
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        # Disable natural scrolling. Linux muscle memory usually wants this false.
        "com.apple.swipescrolldirection" = false;
        # Standard F1/F2/etc behavior.
        "com.apple.keyboard.fnState" = true;

        # Finder / files: show reality.
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;

        # Less magic text mutation.
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Less animation / less “helpful” behavior.
        NSAutomaticWindowAnimationsEnabled = false;
        NSScrollAnimationEnabled = false;
        NSUseAnimatedFocusRing = false;
        NSWindowResizeTime = 0.001;

        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";

        # Linux-like window dragging: hold ctrl+cmd and drag anywhere in window.
        NSWindowShouldDragOnGesture = true;
        # Save/open dialogs should show the actual filesystem.
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        # Do not default new documents to iCloud.
        NSDocumentSaveNewDocumentsToCloud = false;

        # Do not jump Spaces when activating an app with an open window elsewhere.
        AppleSpacesSwitchOnActivate = false;

        # Do not auto-tab documents.
        AppleWindowTabbingMode = "manual";

        # Celsius, because sane units.
        AppleTemperatureUnit = "Celsius";
      };
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
        StageManagerHideWidgets = true;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowSeconds = true;
        ShowDate = 1;
        ShowDayOfWeek = true;
      };
      universalaccess = {
        reduceMotion = true;
        reduceTransparency = true;
      };
    };

    # system.activationScripts.applications.text = let
    #   env = pkgs.buildEnv {
    #     name = "system-applications";
    #     paths = config.environment.systemPackages;
    #     pathsToLink = "/Applications";
    #   };
    # in
    #   pkgs.lib.mkForce ''
    #     # Set up applications.
    #     echo "setting up /Applications..." >&2
    #     rm -rf /Applications/Nix\ Apps
    #     mkdir -p /Applications/Nix\ Apps
    #     find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
    #     while read -r src; do
    #       app_name=$(basename "$src")
    #       echo "copying $src" >&2
    #       ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    #     done
    #   '';

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    # Determinate uses its own daemon to manage the Nix installation that
    # conflicts with nix-darwin’s native Nix management.
    nix.enable = false;
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
  };
}
