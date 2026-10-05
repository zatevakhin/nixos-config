{
  self,
  inputs,
  ...
}: {
  flake.lib = {
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
  };
}
