{...}: {
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8080;
        bind_address = "0.0.0.0";
        secret_key = "supersecretkey";
      };
      search.formats = ["html" "json"];
    };
  };
}
