{...}: {
  flake.homeModules.associations = {...}: {
    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
        "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
        "text/plain" = ["nvim.desktop"];
        "text/csv" = ["nvim.desktop"];
      };

      associations.added = {
        "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
        "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
        "application/pdf" = ["org.gnome.Papers.desktop"];
        "application/json" = ["nvim.desktop"];
        "text/markdown" = ["nvim.desktop"];
        "text/plain" = ["nvim.desktop"];
        "text/html" = ["nvim.desktop"];
        "text/csv" = ["nvim.desktop"];

        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = ["org.onlyoffice.desktopeditors.desktop"];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["org.onlyoffice.desktopeditors.desktop"];

        "image/jpeg" = ["org.gnome.Loupe.desktop"];
        "image/png" = ["org.gnome.Loupe.desktop"];
        "image/gif" = ["org.gnome.Loupe.desktop"];
        "image/webp" = ["org.gnome.Loupe.desktop"];
        "image/tiff" = ["org.gnome.Loupe.desktop"];
        "image/avif" = ["org.gnome.Loupe.desktop"];
        "image/bmp" = ["org.gnome.Loupe.desktop"];
        "image/svg+xml" = ["org.gnome.Loupe.desktop"];
        "image/svg+xml-compressed" = ["org.gnome.Loupe.desktop"];

        "video/x-matroska" = ["org.gnome.Showtime.desktop"];
        "video/mp4" = ["org.gnome.Showtime.desktop"];
        "video/webm" = ["org.gnome.Showtime.desktop"];
        "video/quicktime" = ["org.gnome.Showtime.desktop"];
        "audio/ogg" = ["org.gnome.Decibels.desktop"];
        "audio/flac" = ["org.gnome.Decibels.desktop"];
        "audio/x-wav" = ["org.gnome.Decibels.desktop"];
      };
    };
  };
}
