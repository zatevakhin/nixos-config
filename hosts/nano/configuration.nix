{self, ...}: {
  flake.nixosModules.nano-configuration = {
    hostname,
    username,
    config,
    pkgs,
    lib,
    inputs,
    ...
  }: {
    imports = [
      inputs.system3.nixosModules.default
      inputs.system3-omnigraph.nixosModules.system3-omnigraph-worker
      self.nixosModules.oo7
      self.nixosModules.docker
      self.nixosModules.search-mcp
      self.nixosModules.nano-swap
    ];

    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = ../../secrets/${hostname}/default.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.secrets."user/password/hashed".neededForUsers = true;
    sops.secrets."root/password/hashed".neededForUsers = true;
    sops.secrets.oo7-keyring-password = {
      sopsFile = ../../secrets/${hostname}/oo7.yaml;
      key = "oo7_keyring_password";
      mode = "0400";
      owner = username;
    };

    services.oo7Secrets = {
      enable = true;
      passwordFile = config.sops.secrets.oo7-keyring-password.path;
    };

    # User service so it can reach aya's Secret Service. Sandbox exceptions
    # below are intentional: the runtime sudo's nixos-rebuild.
    services.system3.userService = {
      enable = true;
      user = username;
      linger = true;
      checkSecretStore = true;
      privateTmp = false;
      openRemoteStagesFirewall = true;
      openGraphUiFirewall = true;
      settings = {
        logging.stderr = true;
        querymt = {
          update_models_registry = true;
          providers = [
            {
              name = "openai";
              path = "data://wasm/qmt_openai.wasm";
            }
            {
              name = "anthropic";
              path = "data://wasm/qmt_anthropic.wasm";
            }
            {
              name = "xai";
              path = "data://wasm/qmt_xai.wasm";
            }
            {
              name = "kimi-code";
              path = "oci://ghcr.io/querymt/kimi-code:latest";
            }
            {
              name = "codex";
              path = "data://wasm/qmt_codex.wasm";
            }
          ];
        };
        graph_ui = {
          enabled = true;
          host = "0.0.0.0";
          port = 8188;
        };
        remote_stages = {
          enabled = true;
          host_name = "nano";
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

    systemd.user.services.system3.serviceConfig = {
      WorkingDirectory = lib.mkForce "/home/${username}/workspace";
      NoNewPrivileges = lib.mkForce false;
    };

    systemd.tmpfiles.rules = [
      "d /home/${username}/workspace 0700 ${username} users - -"
    ];

    # Omnigraph itself stays on docker-compose (:18080). This is only the mesh worker.
    services.system3-omnigraph-worker = {
      enable = true;
      hostName = "${hostname}-omnigraph";
      listen = "/ip4/0.0.0.0/tcp/39120";
      package = inputs.system3-omnigraph.packages.${pkgs.system}.system3-stage-omnigraph;
    };

    virtualisation.docker.enableOnBoot = true;
    hardware.nvidia-container-toolkit.enable = true;

    nix.gc = {
      dates = lib.mkForce "weekly";
      options = lib.mkForce "--delete-older-than 14d";
    };

    nixpkgs.config = {
      allowUnfree = true;
      cudaSupport = true;
      cudaCapabilities = ["8.7"];
    };

    users.mutableUsers = false;
    users.users.${username} = {
      uid = 1000;
      isNormalUser = true;
      description = "Aya System3";
      hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
      extraGroups = ["wheel" "video" "docker"];
    };
    users.users.root.hashedPasswordFile = config.sops.secrets."root/password/hashed".path;

    # mkHost disables security.sudo. This is the sudo-rs equivalent of nano's NOPASSWD rule.
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

    time.timeZone = "Europe/Lisbon";
    networking.hostName = hostname;
    networking.firewall.enable = lib.mkForce false;

    # Password SSH stays until an authorized key is installed. openssh-defaults would lock this host out.
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        X11Forwarding = true;
      };
    };

    # /nix/store is nobody:nogroup here, so the systemd ssh-proxy include breaks git-over-ssh.
    programs.ssh.systemd-ssh-proxy.enable = false;
    programs.ssh.extraConfig = ''
      Host github.com-system3-omngraph
          Hostname github.com
          IdentityFile /home/${username}/.ssh/system3-omngraph_deploy_key
          IdentitiesOnly yes

      Host github.com-japanese
          Hostname github.com
          IdentityFile /home/${username}/.ssh/japanese_deploy_key
          IdentitiesOnly yes
    '';

    environment.systemPackages = [
      inputs.system3-omnigraph.packages.${pkgs.system}.omnigraph-cli
      pkgs.direnv
      pkgs.ffmpeg
      pkgs.gh
      pkgs.whisper-cpp
    ];

    # Installed as 25.05. Do not bump this on the existing machine.
    system.stateVersion = "25.05";
  };
}
