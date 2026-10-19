{self, ...}: {
  flake.nixosModules.sys3-configuration = {
    hostname,
    username,
    config,
    pkgs,
    lib,
    inputs,
    ...
  }: let
    omnigraph = pkgs.callPackage ../../flakes/omnigraph/package.nix {};
  in {
    imports = [
      self.nixosModules.homeworld-certificate
      self.nixosModules.firewall-defaults
      self.nixosModules.openssh-defaults
      self.nixosModules.docker
      self.nixosModules.wireshark
      self.nixosModules.tmux
      self.nixosModules.oo7
      self.nixosModules.system3-secrets
      self.nixosModules.system3-omnigraph-worker
      self.nixosModules.search-mcp
      self.nixosModules.rustfs
      inputs.system3-latest.nixosModules.default
      self.nixosModules.omnigraph
      self.nixosModules.llama-cpp
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

    services.system3.sopsSecrets = {
      enable = true;
      sopsFile = ../../secrets/${hostname}/system3.yaml;
      secrets = {
        "llm/zai" = "llm/zai";
        "im/telegram/token" = "im/telegram/token";
        "xmpp/account-password" = "im/xmpp/account-password";
      };
    };

    sops.secrets.rustfs-environment = {
      sopsFile = ../../secrets/${hostname}/rustfs.yaml;
      key = "environment";
      mode = "0400";
      restartUnits = ["rustfs.service" "rustfs-init.service" "omnigraph.service"];
    };
    services.rustfs = {
      enable = true;
      environmentFile = config.sops.secrets.rustfs-environment.path;
      settings = {
        RUSTFS_ADDRESS = "127.0.0.1:9000";
        RUSTFS_CONSOLE_ADDRESS = "127.0.0.1:19001";
        RUSTFS_VOLUMES = "/var/lib/rustfs/data";
      };
      provisioning = {
        endpoint = "http://127.0.0.1:9000";
        buckets = ["omnigraph"];
      };
    };

    services.omnigraph = {
      enable = true;
      cluster = "s3://omnigraph/clusters/default";
      bindAddress = "0.0.0.0";
      port = 18080;
      openFirewall = true;
      environmentFiles = [config.sops.secrets.rustfs-environment.path];
      environmentAliases = {
        AWS_ACCESS_KEY_ID = "RUSTFS_ACCESS_KEY";
        AWS_SECRET_ACCESS_KEY = "RUSTFS_SECRET_KEY";
      };
      environment = {
        AWS_REGION = "us-east-1";
        AWS_ENDPOINT_URL_S3 = "http://127.0.0.1:9000";
        AWS_ALLOW_HTTP = "true";
        AWS_S3_FORCE_PATH_STYLE = "true";
        AWS_EC2_METADATA_DISABLED = "true";
      };
      bootstrap = {
        enable = true;
        configDirectory = ./omnigraph;
        actor = "sys3";
      };
      # The API is intentionally available on the LAN without authentication.
      extraArgs = ["--require-all-graphs" "--unauthenticated"];
    };
    systemd.services.omnigraph = {
      requires = ["rustfs-init.service"];
      after = ["rustfs-init.service"];
    };
    services.system3-omnigraph-worker = {
      enable = true;
      hostName = "${hostname}-omnigraph";
      listen = "/ip4/0.0.0.0/tcp/39120";
    };
    systemd.services.system3-omnigraph-worker = {
      requires = ["omnigraph.service"];
      after = ["omnigraph.service"];
    };
    environment.etc."omnigraph/client.yaml".source = ./omnigraph/client.yaml;
    systemd.tmpfiles.rules = let
      user = config.users.users.${username};
    in [
      "d ${user.home}/.omnigraph 0700 ${username} ${user.group} -"
      "L+ ${user.home}/.omnigraph/config.yaml - ${username} ${user.group} - /etc/omnigraph/client.yaml"
    ];

    # The optional browser backend ships an x86-only V8 archive; sys3 is ARM64.
    services.searxng-mcp.packageFeatures = [];

    # User service so it can reach aya's Secret Service. Providers are OCI
    # images only; API keys stay in the keyring, not in this store path.
    services.system3.userService = {
      enable = true;
      package = inputs.system3-latest.packages.${pkgs.stdenv.hostPlatform.system}.system3.overrideAttrs (old: {
        cargoBuildFeatures = (old.cargoBuildFeatures or []) ++ ["builtin-xmpp"];
      });
      user = username;
      linger = true;
      checkSecretStore = true;
      openGraphUiFirewall = true;
      openRemoteStagesFirewall = true;
      settings = {
        logging.stderr = true;
        querymt = {
          update_models_registry = true;
          providers = [
            {
              name = "openai";
              path = "oci://ghcr.io/querymt/openai:latest";
            }
            {
              name = "anthropic";
              path = "oci://ghcr.io/querymt/anthropic:latest";
            }
            {
              name = "xai";
              path = "oci://ghcr.io/querymt/xai:latest";
            }
            {
              name = "zai";
              path = "oci://ghcr.io/querymt/zai:latest";
            }
            {
              name = "codex";
              path = "oci://ghcr.io/querymt/codex:latest";
            }
          ];
        };
        graph_ui = {
          enabled = true;
          host = "0.0.0.0";
          port = 8088;
        };
        remote_stages = {
          enabled = true;
          host_name = hostname;
          listen = "/ip4/0.0.0.0/tcp/39100";
          identity_file = "data://remote-stage-identity.key";
        };
        pipelines = [
          {
            id = "orchestrator";
            path = "data://pipelines/orchestrator.toml";
            autorun = true;
          }
          {
            id = "memory";
            path = "data://pipelines/memory.toml";
            autorun = true;
          }
        ];
      };
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
      host = "0.0.0.0";
      port = 3333;
      openFirewall = true;
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
        "embeddinggemma-2-BF16.gguf" = {
          hf-repo = "ggml-org/embeddinggemma-2-GGUF";
          hf-file = "embeddinggemma-2-BF16.gguf";
          alias = "ggml-org/embeddinggemma-2-bf16";
          mmproj-auto = "off";
          pooling = "mean";
          ctx-size = 8192;
          batch-size = 8192;
          ubatch-size = 8192;
          parallel = 1;
          gpu-layers = "all";
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

    # mkHost disables security.sudo. This is the sudo-rs form of the existing rule.
    security.sudo-rs.extraRules = [
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
