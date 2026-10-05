{self, ...}: let
  hostname = "klbr";
in {
  flake.nixosConfigurations.${hostname} = self.lib.mkHost {
    inherit hostname;
    username = "ivan";
    system = "x86_64-linux";
    modules = [
      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      self.nixosModules."${hostname}-modules"
      self.nixosModules."${hostname}-home"
    ];
  };
}
