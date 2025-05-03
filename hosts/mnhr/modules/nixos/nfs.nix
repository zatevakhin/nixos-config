{...}: {
  networking.firewall.allowedTCPPorts = [2049];
  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /storage/media/library        192.168.1.0/24(ro,fsid=0,no_subtree_check,all_squash,anonuid=1000,anongid=100)
        /storage/media/library/anime  192.168.1.0/24(ro,no_subtree_check,all_squash,anonuid=1000,anongid=100,insecure)
        /storage/media/library/tv     192.168.1.0/24(ro,no_subtree_check,all_squash,anonuid=1000,anongid=100,insecure)
        /storage/media/library/movies 192.168.1.0/24(ro,no_subtree_check,all_squash,anonuid=1000,anongid=100,insecure)
        /storage/media/library/music  192.168.1.0/24(ro,no_subtree_check,all_squash,anonuid=1000,anongid=100,insecure)
      '';
    };
  };
}
