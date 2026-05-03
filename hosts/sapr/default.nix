{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.sapr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "ivan";
      hostname = "sapr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.sapr-configuration
      self.nixosModules.sapr-hardware
      self.nixosModules.sapr-modules
      self.nixosModules.sapr-containers

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
    ];
  };
}
