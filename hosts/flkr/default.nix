{self, ...}: let
  hostname = "flkr";
in {
  flake.nixosConfigurations.${hostname} = self.lib.mkHost {
    inherit hostname;
    username = "ivan";
    system = "x86_64-linux";
    modules = [
      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      self.nixosModules."${hostname}-home"
      self.nixosModules."${hostname}-liquidctl"
    ];
  };
}
