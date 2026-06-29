{ den, ... }:
let
  asp = den.aspects;
in
{

  den.hosts.x86_64-linux.rev3-5.users.nubabe.aspect.includes = [
    den.aspects.nubabeGraphical
    den.batteries.primary-user
    { homeManager.home.stateVersion = "26.05"; }
  ];

  den.aspects.rev3-5 = {

    includes = [
      asp.core
      asp."env/nubabe"
      asp.boot
      asp.tailscale
      asp.vm
      asp.network
      asp.stylix
    ];

    nixos = {

      system.stateVersion = "26.05";

      nubabe.services.tailscale.ipv4 = "100.99.0.1";

      disko.devices.disk.systemDisk = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "64G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            home = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };
      };

    };
  };

}
