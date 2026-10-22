{...}: {
  flake.nixosModules.flkr-wireguard = {
    hostname,
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) concatStringsSep escapeShellArg;

    work = lib.importTOML "${inputs.notsecrets}/work/wg.toml";
    sopsFile = ../../../secrets/${hostname}/wg.yaml;

    workName = endpoint: "work-${endpoint.name}";
    unitName = endpoint: "wg-quick-${workName endpoint}";

    # Keep encrypted fields out of the Nix store; dnsmasq handles split DNS.
    renderConfig = name: endpoint: ''
      set -eu
      umask 077
      source=${escapeShellArg config.sops.secrets."wg/work/config".path}
      address="$(${pkgs.yq-go}/bin/yq -e -r '.work.address' "$source")"
      private_key="$(${pkgs.yq-go}/bin/yq -e -r '.work.private_key' "$source")"
      test -n "$address" && test -n "$private_key"

      conf=/run/wg-quick-${name}/${name}.conf
      tmp="$(${pkgs.coreutils}/bin/mktemp /run/wg-quick-${name}/.conf.XXXXXX)"
      trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
      ${pkgs.coreutils}/bin/printf '[Interface]\nAddress = %s\nPrivateKey = %s\nListenPort = 51820\n\n[Peer]\nPublicKey = %s\nAllowedIPs = %s\nEndpoint = %s\nPersistentKeepalive = 25\n' \
        "$address" "$private_key" \
        ${escapeShellArg work.peer.public_key} \
        ${escapeShellArg (concatStringsSep ", " work.peer.allowed_ips)} \
        ${escapeShellArg endpoint} > "$tmp"
      ${pkgs.coreutils}/bin/mv -f "$tmp" "$conf"
    '';
  in {
    sops.secrets."wg/work/config" = {
      inherit sopsFile;
      key = "";
    };

    networking.wg-quick.interfaces = builtins.listToAttrs (map (endpoint: let
        name = workName endpoint;
      in {
        inherit name;
        value = {
          autostart = false;
          configFile = "/run/wg-quick-${name}/${name}.conf";
        };
      })
      work.endpoints);

    systemd.services = builtins.listToAttrs (map (endpoint: let
        name = workName endpoint;
      in {
        name = unitName endpoint;
        value = {
          serviceConfig = {
            RuntimeDirectory = "wg-quick-${name}";
            RuntimeDirectoryMode = "0700";
          };
          preStart = renderConfig name endpoint.value;
        };
      })
      work.endpoints);
  };
}
