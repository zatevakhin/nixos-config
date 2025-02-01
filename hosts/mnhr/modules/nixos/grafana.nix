{...}:{

services.grafana = {
  enable = true;
  settings = {
    server = {
      http_addr = "127.0.0.1";
      http_port = 3000;
      enforce_domain = true;
      enable_gzip = true;
      domain = "grafana.homeworld.lan";

      # Alternatively, if you want to server Grafana from a subpath:
      # domain = "your.domain";
      # root_url = "https://your.domain/grafana/";
      # serve_from_sub_path = true;
    };

    # Prevents Grafana from phoning home
    analytics.reporting_enabled = false;
  };
};


}
