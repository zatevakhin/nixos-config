{...}: {
  # NOTE: Required for NFS
  services.rpcbind.enable = true;
  # NOTE: Required for NFS kernel module to be loaded
  boot.supportedFilesystems = ["nfs"];

  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "mnhr.lan:/storage/media/library/tv";
      where = "/mnt/nfs/media/tv";
    }
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "mnhr.lan:/storage/media/library/movies";
      where = "/mnt/nfs/media/movies";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt/nfs/media/tv";
    }
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt/nfs/media/movies";
    }
  ];
}
