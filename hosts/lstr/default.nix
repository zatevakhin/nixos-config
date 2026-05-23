{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lstr = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      username = "ivan";
      hostname = "lstr";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    modules = [
      self.nixosModules.base
      self.nixosModules.nixos-base
      self.nixosModules.lstr-configuration
      self.nixosModules.lstr-hardware
      self.nixosModules.lstr-modules
      self.nixosModules.lstr-home

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      inputs.nixvim.nixosModules.nixvim
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.searxng-mcp.nixosModules.searxng-mcp
    ];
  };
}
