{ den, ... }:
let
  asp = den.aspects;
in
{

  den.hosts.aarch64-linux.oracle-vps = {
    stateVersion = "26.05";
    disk = {
      device = "/dev/sda";
      swap = null;
      rootSize = "100%";
      home = false;
    };
    users.nubabe = {
      aspect.includes = [
        asp.nubabe-graphical
        den.batteries.primary-user
      ];
      stateVersion = "26.05";
    };
  };

  den.aspects.oracle-vps = {

    includes = [
      asp.core
      asp.locale
      asp.nubabe-env
      asp.boot
      asp.facter
      asp.tailscale
      asp.vm
      asp.network
      # asp.network._.networkmanager
      asp.stylix
      asp.disko
      asp.sshd
    ];

    nixos = {
      nubabe.services.tailscale.ipv4 = "100.99.1.1";
    };
  };

}
