{
  disko.devices = {
    disk = {
      usb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "128M";
              content = {
                type = "filesystem";
                format = "vfat";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = null;
                additionalKeyFiles = ["/tmp/key1" "/tmp/key2"]; # Paths to additional key files for multiple slots
                settings = {
                  allowDiscards = true;
                  keyFile = null;
                  fallbackToPassword = true; # Optional: Fallback to passphrase prompt if key file unavailable
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
