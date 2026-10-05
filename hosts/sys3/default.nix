{
  self,
  inputs,
  ...
}: let
  hostname = "sys3";
in {
  flake.nixosConfigurations.${hostname} = self.lib.mkHost {
    inherit hostname;
    username = "aya";
    system = "aarch64-linux";
    pkgsUnstableConfig = {
      cudaSupport = true;
      cudaCapabilities = ["8.7"];
    };
    modules = [
      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      inputs.jetpack.nixosModules.default
    ];
  };
}
