{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.stcr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "zatevakhin";
      hostname = "stcr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.stcr-configuration
      self.nixosModules.stcr-hardware
      self.nixosModules.stcr-modules

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
    ];
  };
}
