# Keyfile (once):
#   sudo dd if=/dev/urandom of=/root/nvme.keyfile bs=256 count=1
#   sudo chmod 600 /root/nvme.keyfile
#
# Format (wipes all six):
#   sudo systemctl stop docker
#   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
#     --mode destroy,format,mount ./hosts/mnhr/nvmes.nix
#
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
#   --mode destroy,format,mount ./hosts/mnhr/nvmes.nix
{lib, ...}: let
  nvmeDisks = ["nvme0" "nvme1" "nvme2" "nvme3" "nvme4" "nvme5"];

  mkNvme = name: {
    type = "disk";
    device = "/dev/${name}n1";
    content = {
      type = "gpt";
      partitions = {
        zfs = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypt${name}";
            settings = {
              allowDiscards = true;
              keyFile = "/root/nvme.keyfile";
            };
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
    };
  };

  zfsDataset = mountpoint: {
    type = "zfs_fs";
    inherit mountpoint;
    options = {
      compression = "lz4";
      atime = "off";
      xattr = "sa";
    };
  };
in {
  disko.devices = {
    disk = lib.genAttrs nvmeDisks mkNvme;
    zpool = {
      storage = {
        type = "zpool";
        mode = "raidz2";
        mountpoint = "/storage";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "lz4";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          dnodesize = "auto";
        };
        datasets = {
          media = zfsDataset "/storage/media";
          downloads = zfsDataset "/storage/downloads";
          backups = zfsDataset "/storage/backups";
          syncthing = zfsDataset "/storage/syncthing";
          docker = zfsDataset "/var/lib/docker";
          services = zfsDataset "/storage/.services";
        };
      };
    };
  };
}
