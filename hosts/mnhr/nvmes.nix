#
# sudo mkdir -p /root/nvme.keyfile
# sudo dd if=/dev/urandom of=/root/nvme.keyfile bs=256 count=1
# sudo chmod 600 /root/nvme.keyfile
#
{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme0";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme0";
                };
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme1";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme1";
                };
              };
            };
          };
        };
      };
      nvme2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme2";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme2";
                };
              };
            };
          };
        };
      };
    };
  };
}
