{
  config,
  pkgs,
  inputs,
  lib,
  username,
  hostname,
  ...
}: let
  me = import ./secrets/user.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/nixos/syncthing.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/docker.nix
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets."user/password/hashed" = {};
  # </sops>

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }

      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    settings = {
      title = "HOMEPAGE";
      theme = "dark";
      color = "gray";
      headerStyle = "boxed";

      background = {
        image = "https://w.wallhaven.cc/full/ex/wallhaven-ex136k.jpg";
        blur = "md";
        saturate = 10;
        brightness = 10;
        opacity = 10;
      };
    };

    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.png";
              href = "http://jellyfin.homeworld.lan/";
              siteMonitor = "http://jellyfin.homeworld.lan/";
              description = "Collect, manage, and stream your media.";
            };
          }
          {
            "File Browser" = {
              icon = "filebrowser.png";
              href = "http://media-jellyfin.homeworld.lan/";
              siteMonitor = "http://media-jellyfin.homeworld.lan";
              description = "File browser provides a file managing interface.";
            };
          }
          {
            "qBittorrent" = {
              icon = "qbittorrent.svg";
              href = "http://qb.homeworld.lan/";
              siteMonitor = "http://qb.homeworld.lan/";
              description = "BitTorrent client.";
            };
          }
          {
            "Calibre Web" = {
              icon = "calibre-web.svg";
              href = "http://books.homeworld.lan/";
              siteMonitor = "http://books.homeworld.lan/";
              description = "Powerful and easy to use e-book manager.";
            };
          }
          {
            "Audiobookshelf" = {
              icon = "audiobookshelf.svg";
              href = "http://abs.homeworld.lan/";
              siteMonitor = "http://abs.homeworld.lan/";
              description = "Self-hosted audiobook and podcast server.";
            };
          }
        ];
      }
      {
        "Other stuff" = [
          {
            "Home Assistant" = {
              icon = "home-assistant-alt.svg";
              href = "https://pixelpond-3114538102.duckdns.org:8124";
              siteMonitor = "https://pixelpond-3114538102.duckdns.org:8124";
              description = "Home Assistant is a platform that lets you automate and control your home.";
            };
          }
          {
            "Forgejo" = {
              icon = "forgejo.svg";
              href = "http://forgejo.homeworld.lan/";
              siteMonitor = "http://forgejo.homeworld.lan/";
              description = "Forgejo is a self-hosted lightweight software forge (local GitHub).";
            };
          }
          {
            "WireGuard UI" = {
              icon = "wireguard.svg";
              href = "http://wg.homeworld.lan/";
              siteMonitor = "http://wg.homeworld.lan/";
              description = "A web user interface to manage your WireGuard setup.";
            };
          }
          {
            "Pi Hole" = {
              icon = "pi-hole.svg";
              href = "http://pihole.homeworld.lan/admin";
              siteMonitor = "http://pihole.homeworld.lan/admin";
              description = "Network-wide Ad Blocking.";
            };
          }
          {
            "Vodafone Router" = {
              icon = "router.svg";
              href = "http://192.168.1.1";
              siteMonitor = "http://192.168.1.1";
              description = "Vodafone Router web interface.";
            };
          }
          {
            "Ghostfolio" = {
              icon = "ghostfolio.png";
              href = "http://nuke.lan:3333/";
              siteMonitor = "http://nuke.lan:3333/";
              description = "Open-Source wealth management software built with web technology.";
            };
          }
        ];
      }
      {
        "Backup & Sync" = [
          {
            "Syncthing" = {
              icon = "syncthing.svg";
              href = "http://syncthing.homeworld.lan/";
              siteMonitor = "http://syncthing.homeworld.lan/";
              description = "Syncthing is a continuous file synchronization program.";
            };
          }
          {
            "Paperless NGX" = {
              icon = "paperless-ngx.svg";
              href = "http://paperless.homeworld.lan/";
              siteMonitor = "http://paperless.homeworld.lan/";
              description = "Transform physical documents into a searchable online archive.";
            };
          }
          {
            "Linkding" = {
              icon = "linkding.svg";
              href = "http://linkding.homeworld.lan";
              siteMonitor = "http://linkding.homeworld.lan";
              description = "Self-hosted bookmark manager that is designed be to be minimal, fast, and easy to set up.";
            };
          }
        ];
      }
    ];

    bookmarks = [
      {
        Developer = [
          {
            Perplexity = [
              {
                abbr = "PP";
                icon = "si-perplexity";
                href = "https://www.perplexity.ai/";
              }
            ];
          }
          {
            ChatGPT = [
              {
                abbr = "CH";
                icon = "chatgpt.svg";
                href = "https://chatgpt.com";
              }
            ];
          }
          {
            Claude = [
              {
                abbr = "CL";
                icon = "si-anthropic";
                href = "https://claude.ai/chats";
              }
            ];
          }
          {
            "Google Gemini" = [
              {
                abbr = "GG";
                icon = "si-googlegemini";
                href = "https://gemini.google.com/app";
              }
            ];
          }
          {
            "Google Translate" = [
              {
                abbr = "GT";
                icon = "google-translate.svg";
                href = "https://translate.google.com/?sl=auto&tl=ru";
              }
            ];
          }
          {
            Github = [
              {
                abbr = "GH";
                icon = "github.svg";
                href = "https://github.com/";
              }
            ];
          }
          {
            "Nix Wiki" = [
              {
                abbr = "NW";
                icon = "mdi-nix";
                href = "https://nixos.wiki/";
              }
            ];
          }
          {
            "Nix Search" = [
              {
                abbr = "NS";
                icon = "mdi-nix";
                href = "https://search.nixos.org/";
              }
            ];
          }
          {
            "Nix Dev" = [
              {
                abbr = "ND";
                icon = "mdi-nix";
                href = "https://nix.dev/";
              }
            ];
          }
          {
            "My NixOS" = [
              {
                abbr = "MN";
                icon = "mdi-nix";
                href = "https://mynixos.com/";
              }
            ];
          }
        ];
      }
      {
        Social = [
          {
            "Proton Mail" = [
              {
                abbr = "PM";
                icon = "proton-mail.svg";
                href = "https://mail.proton.me";
              }
            ];
          }
          {
            "Google Mail" = [
              {
                abbr = "GM";
                icon = "gmail.svg";
                href = "https://mail.google.com";
              }
            ];
          }
          {
            "X (Twitter)" = [
              {
                abbr = "TW";
                icon = "twitter.svg";
                href = "https://x.com/home";
              }
            ];
          }
          {
            "Twitch" = [
              {
                abbr = "TV";
                icon = "twitch.svg";
                href = "https://www.twitch.tv/";
              }
            ];
          }
          {
            Reddit = [
              {
                abbr = "RE";
                icon = "reddit.svg";
                href = "https://reddit.com/";
              }
            ];
          }
        ];
      }
      {
        Entertainment = [
          {
            YouTube = [
              {
                abbr = "YT";
                icon = "youtube.svg";
                href = "https://youtube.com/";
              }
            ];
          }
          {
            Suno = [
              {
                abbr = "SN";
                icon = "si-suno";
                href = "https://suno.com";
              }
            ];
          }
        ];
      }
    ];
  };

  networking.hostName = hostname;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
    openssh.authorizedKeys.keys = [
      me.ssh.authorized.baseship
    ];
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = ["wheel" "docker"];
    packages = with pkgs; [];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    me.ssh.authorized.baseship
  ];

  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    btrfs-progs
    curl
    htop
    mc
    neovim
  ];

  # <docker>
  virtualisation.docker.enableNvidia = lib.mkForce false;
  virtualisation.docker.storageDriver = lib.mkForce null;
  virtualisation.docker.daemon.settings = lib.mkForce {};
  hardware.nvidia-container-toolkit.enable = lib.mkForce false;
  # </docker>

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
