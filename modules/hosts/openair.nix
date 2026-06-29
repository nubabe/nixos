{ inputs, den, ... }:

let
  asp = den.aspects;
in

{

  den.aspects."openAir/nubabe" = {
    includes = [
      asp.nubabe
      den.batteries.primary-user
    ];
    homeManager = {
      programs.firefox.enable = true;
    };
    user.initialPassword = "test";
  };

  den.aspects.openAir = {

    includes = [
      asp.core
      asp."env/pgTechEvent"
      asp.boot
      asp.vm
      asp.network
      asp.ssh
    ];

    nixos = {
      system.stateVersion = "26.05";
      services.xserver.desktopManager.lxqt.enable = true;
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.enable = true;

      swapDevices = [
        {
          device = "/swapfile";
          size = 8 * 1024;
        }
      ];

      disko.devices.disk.systemDisk = {
        device = "/dev/sda";
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
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

    };

    provides.to-users.homeManager.home.stateVersion = "26.05";

  };

  den.hosts.x86_64-linux.openAirBackstage = {
    aspect.includes = [ asp.openAir ];
    users.nubabe.aspect = asp."openAir/nubabe";
  };

  den.hosts.x86_64-linux.openAirStage = {
    aspect.includes = [ asp.openAir ];
    users.nubabe.aspect = asp."openAir/nubabe";
  };

  den.hosts.x86_64-linux.openAirServer = {
    aspect = {
      includes = [
        asp.openAir
        asp.companion
        asp.ontime
      ];
    };
    users.nubabe.aspect = {
      includes = [ asp."openAir/nubabe" ];
    };
  };

}
