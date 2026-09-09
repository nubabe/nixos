{ den, ... }:
let
  asp = den.aspects;
in
{

  den.hosts.x86_64-linux.rev3-5 = {
    disk = {
      device = "/dev/nvme0n1";
      swap = "16G";
      rootSize = "64G";
      home = true;
    };
    users.nubabe.aspect.includes = [
      asp.nubabe-graphical
      den.batteries.primary-user
    ];
  };

  den.aspects.rev3-5 = {

    includes = [
      asp.core
      asp.locale
      asp.nubabe-env
      asp.boot
      asp.tailscale
      asp.vm
      asp.network
      asp.stylix
      asp.disko
      asp.sshd
    ];

    nixos = {
      nubabe.services.tailscale.ipv4 = "100.99.0.1";
    };
  };

}
