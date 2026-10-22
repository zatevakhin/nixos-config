{
  inputs,
  hostDir,
}:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  imports = [
    (inputs.import-tree.filterNot (path: path == "/flake.nix") [
      ../modules
      hostDir
    ])
    inputs.home-manager.flakeModules.home-manager
  ];
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
}
