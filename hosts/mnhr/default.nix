{self, ...}: let
  hostname = "mnhr";
in {
  # Temporarily disabled as unused. Host config stays in this directory.
  # flake.nixosConfigurations.${hostname} = self.lib.mkHost {
  #   inherit hostname;
  #   username = "zatevakhin";
  #   system = "aarch64-linux";
  #   modules = [
  #     self.nixosModules."${hostname}-configuration"
  #     self.nixosModules."${hostname}-hardware"
  #     self.nixosModules."${hostname}-modules"
  #     self.nixosModules."${hostname}-containers"
  #   ];
  # };
}
