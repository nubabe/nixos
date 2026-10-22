{ den, ... }:
let
  asp = den.aspects;
in
{

  den.hosts.x86_64-linux.prv3-9 = {
    stateVersion = "26.05";
    disk = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_S3YJNW0K908184R";
    };
    users.nubabe = {
      aspect.includes = [
        asp.nubabe-graphical
        den.batteries.primary-user
        asp.stami-buchhaltung
      ];
      aspect.excludes = [ asp.doom-emacs ];
      stateVersion = "26.05";
    };
  };

  den.aspects.prv3-9 = {

    includes = [
      asp.core
      asp.locale
      asp.nubabe-env
      asp.boot
      asp.tailscale
      asp.network
      asp.network._.wireless
      asp.network._.networkmanager
      asp.bluetooth
      asp.disko
      (asp.swapfile { sizeInGiB = 8; })
      asp.sshd
      asp.facter
    ];

    nixos = {
      nubabe.services.tailscale.ipv4 = "100.99.0.2";
    };
  };

}
