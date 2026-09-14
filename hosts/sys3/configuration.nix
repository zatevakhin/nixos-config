{self, ...}: {
  flake.nixosModules.sys3-configuration = {
    hostname,
    username,
    config,
    pkgs,
    lib,
    ...
  }: let
    omnigraph = pkgs.callPackage ../../flakes/omnigraph/package.nix {};
  in {
    imports = [
      self.nixosModules.homeworld-certificate
      self.nixosModules.firewall-defaults
      self.nixosModules.openssh-defaults
      self.nixosModules.docker
      self.nixosModules.tmux
      self.nixosModules.oo7
      # omnigraph
      ../../flakes/omnigraph/module.nix
    ];

    environment.systemPackages = with pkgs; [
      omnigraph.omnigraph-cli
      whisper-cpp
      fastfetch
      direnv
      ffmpeg
      gh
    ];

    # <sops>
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = ../../secrets/${hostname}/default.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.secrets."user/password/hashed" = {};
    sops.secrets."user/password/hashed".neededForUsers = true;
    sops.secrets.ssh-authorized-key-lstr.key = "ssh/authorized/lstr";
    sops.secrets.oo7-keyring-password = {
      sopsFile = ../../secrets/${hostname}/oo7.yaml;
      key = "oo7_keyring_password";
      mode = "0400";
      owner = username;
    };
    # </sops>

    # Headless Secret Service (org.freedesktop.secrets) for System3 keyring access.
    services.oo7Secrets = {
      enable = true;
      passwordFile = config.sops.secrets.oo7-keyring-password.path;
    };

    # <docker>
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
    hardware.nvidia-container-toolkit.enable = true;
    # </docker>

    # <llama.cpp>
    services.llama-cpp = {
      enable = true;
      port = 3333;
      extraFlags = [
        "--embeddings"
      ];
      modelsPreset = {
        "Qwen3-Embedding-0.6B-Q8_0.gguf" = {
          hf-repo = "Qwen/Qwen3-Embedding-0.6B-GGUF";
          hf-file = "Qwen3-Embedding-0.6B-Q8_0.gguf";
          alias = "qwen/qwen3-embedding-0.6b-q8";
          fit = "on";
        };
        "embeddinggemma-300M-Q8_0.gguf" = {
          hf-repo = "unsloth/embeddinggemma-300m-GGUF";
          hf-file = "embeddinggemma-300M-Q8_0.gguf";
          alias = "unsloth/embeddinggemma-300m-q8";
          fit = "on";
        };
      };
    };
    # </llama.cpp>

    # <networking>
    networking.firewall.enable = lib.mkForce false;
    networking.hostName = hostname;
    # </networking>

    nixpkgs.config.allowUnfree = true;

    # Set time zone.
    time.timeZone = "Europe/Lisbon";

    # Users are immutable and managed by NixOS
    users.mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
      uid = 1000;
      useDefaultShell = true;
      hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
      isNormalUser = true;
      description = "Aya System3";
      extraGroups = ["wheel" "video" "docker"];
    };

    security.sudo.extraRules = [
      {
        users = [username];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # <openssh>
    # HACK: What and Why? Because I can't do something like this with sops-nix.
    # ```nix
    # users.users.root.openssh.authorizedKeys.keyFiles = [
    #   sops.secrets.ssh-authorized-key-xxx.path
    # ];
    # ```
    # <hack>
    services.openssh.authorizedKeysInHomedir = lib.mkForce false;

    sops.templates."ssh-authorized-keys-for-${username}" = {
      content = ''
        ${config.sops.placeholder.ssh-authorized-key-lstr}
      '';
      owner = username; # NOTE: or ${username} will not be able to enter trough ssh.
    };

    environment.etc."ssh-authorized-keys-for-${username}" = {
      target = "ssh/authorized_keys.d/${username}";
      source = config.sops.templates."ssh-authorized-keys-for-${username}".path;
    };

    sops.templates."ssh-authorized-keys-for-${config.users.users.root.name}".content = ''
      ${config.sops.placeholder.ssh-authorized-key-lstr}
    '';

    environment.etc."ssh-authorized-keys-for-${config.users.users.root.name}" = {
      target = "ssh/authorized_keys.d/${config.users.users.root.name}";
      source = config.sops.templates."ssh-authorized-keys-for-${config.users.users.root.name}".path;
    };
    # </hack>
    # </openssh>

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
