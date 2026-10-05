{self, ...}: let
  hostname = "eulr";
in {
  flake.darwinConfigurations.${hostname} = self.lib.mkDarwinHost {
    inherit hostname;
    username = "ivan";
    system = "aarch64-darwin";
    modules = [
      self.darwinModules."${hostname}-configuration"
      self.darwinModules."${hostname}-home"
    ];
  };
}
