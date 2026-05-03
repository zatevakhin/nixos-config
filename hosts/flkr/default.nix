{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.flkr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "ivan";
      hostname = "flkr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.flkr-configuration
      self.nixosModules.flkr-hardware
      self.nixosModules.flkr-home
      self.nixosModules.flkr-liquidctl

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];
  };
}
