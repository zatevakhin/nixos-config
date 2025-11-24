{
  disko.devices = {
    disk = {
      usb = {
        type = "disk";
        device = "/dev/sdc";
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
                settings = {
                  allowDiscards = true;
                  keyFile = null;
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
