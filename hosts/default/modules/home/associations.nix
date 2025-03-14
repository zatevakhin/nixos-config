{...}: {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = {
    "x-scheme-handler/http" = ["io.github.zen_browser.zen.desktop"];
    "x-scheme-handler/https" = ["io.github.zen_browser.zen.desktop"];
    "application/pdf" = ["org.gnome.Evince.desktop"];

    "image/jpeg" = ["org.gnome.Loupe.desktop"];
    "image/png" = ["org.gnome.Loupe.desktop"];
    "image/gif" = ["org.gnome.Loupe.desktop"];
    "image/webp" = ["org.gnome.Loupe.desktop"];
    "image/tiff" = ["org.gnome.Loupe.desktop"];
    "image/avif" = ["org.gnome.Loupe.desktop"];
    "image/bmp" = ["org.gnome.Loupe.desktop"];
    "image/svg+xml" = ["org.gnome.Loupe.desktop"];
    "image/svg+xml-compressed" = ["org.gnome.Loupe.desktop"];

    "video/x-matroska" = ["mpv.desktop"];
    "video/mp4" = ["mpv.desktop"];
    "video/webm" = ["mpv.desktop"];
    "video/quicktime" = ["mpv.desktop"];
    "audio/ogg" = ["mpv.desktop"];
    "audio/flac" = ["mpv.desktop"];
  };
}
