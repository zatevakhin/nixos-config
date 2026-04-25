{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.klbr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "ivan";
      hostname = "klbr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.klbr-configuration
      self.nixosModules.klbr-hardware
      self.nixosModules.klbr-home

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];
  };
}
