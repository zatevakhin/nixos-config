{
  self,
  inputs,
  lib,
  ...
}: {
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
  };

  config.flake.lib = {
    mkHost = {
      hostname,
      username,
      system,
      modules ? [],
      extraSpecialArgs ? {},
      pkgsUnstableConfig ? {},
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs =
          {
            inherit inputs username hostname system;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config = {allowUnfree = true;} // pkgsUnstableConfig;
            };
          }
          // extraSpecialArgs;
        modules =
          [
            {nixpkgs.hostPlatform = system;}
            self.nixosModules.base-cli
            self.nixosModules.zsh
            self.nixosModules.nix
            self.nixosModules.i18n
            self.nixosModules.sudo
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ]
          ++ modules;
      };

    mkHome = {
      stateVersion,
      extraSharedModules ? [],
      extraUserConfig ? {},
    }: {
      pkgs-unstable,
      hostname,
      username,
      lib,
      ...
    }: let
      apply = value: arg:
        if builtins.isFunction value
        then value arg
        else value;
    in {
      imports = [inputs.home-manager.nixosModules.default];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {inherit inputs username hostname pkgs-unstable;};
        sharedModules =
          (apply extraSharedModules hostname)
          ++ [
            inputs.sops-nix.homeManagerModules.sops
          ];

        users."${username}" = lib.mkMerge [
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            home.stateVersion = stateVersion;
            programs.home-manager.enable = true;
          }
          (apply extraUserConfig {inherit username hostname;})
        ];
      };
    };

    mkDarwinHost = {
      hostname,
      username,
      system,
      modules ? [],
      extraSpecialArgs ? {},
      pkgsUnstableConfig ? {},
    }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs =
          {
            inherit self inputs username hostname system;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config = {allowUnfree = true;} // pkgsUnstableConfig;
            };
          }
          // extraSpecialArgs;
        modules =
          [
            {nixpkgs.hostPlatform = system;}
            inputs.sops-nix.darwinModules.sops
            inputs.nix-homebrew.darwinModules.nix-homebrew
          ]
          ++ modules;
      };

    mkDarwinHome = {
      stateVersion,
      extraSharedModules ? [],
      extraUserModules ? [],
    }: {
      pkgs-unstable,
      hostname,
      username,
      lib,
      ...
    }: let
      apply = value: arg:
        if builtins.isFunction value
        then value arg
        else value;
    in {
      imports = [inputs.home-manager.darwinModules.home-manager];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {inherit inputs username hostname pkgs-unstable;};
        sharedModules =
          (apply extraSharedModules hostname)
          ++ [
            inputs.sops-nix.homeManagerModules.sops
          ];

        users.${username} = {
          imports = extraUserModules;
          home.username = username;
          home.homeDirectory = lib.mkForce "/Users/${username}";
          home.stateVersion = stateVersion;
          programs.home-manager.enable = true;
        };
      };
    };
  };
}
