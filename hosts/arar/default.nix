{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.arar = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "zatevakhin";
      hostname = "arar";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.arar-configuration
      self.nixosModules.arar-hardware
      # self.nixosModules.arar-modules
      # self.nixosModules.arar-containers

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
    ];
  };
}
