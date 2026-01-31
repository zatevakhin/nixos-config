{
  config,
  lib,
  ...
}: {
  services.searxng-mcp = {
    enable = lib.mkForce config.services.searx.enable;
    openFirewall = true;
    listenAddress = "127.0.0.1";
    port = 3344;

    environment = {
      SEARXNG_BASE_URL = "http://localhost:${toString config.services.searx.settings.server.port}";
    };

    # Optional: enable extra tools
    tools = ["search" "browse"];
  };
}
