{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.sys3 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "aya";
      hostname = "sys3";

      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
        config.cudaSupport = true;
        config.cudaCapabilities = ["8.7"];
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.sys3-configuration
      self.nixosModules.sys3-hardware

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      inputs.jetpack.nixosModules.default
    ];
  };
}
