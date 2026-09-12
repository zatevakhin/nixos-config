{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.mnhr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "zatevakhin";
      hostname = "mnhr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.mnhr-configuration
      self.nixosModules.mnhr-hardware
      self.nixosModules.mnhr-modules
      self.nixosModules.mnhr-containers

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
    ];
  };
}
