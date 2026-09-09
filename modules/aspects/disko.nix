{ inputs, ... }:

# Disk layout from a host's `disk` attribute. Single GPT disk: ESP + ext4 root,
# optional swap partition and optional ext4 /home.

{

  den.schema.host.imports = [
    (
      { lib, ... }:
      {
        options.disk = {
          device = lib.mkOption {
            type = lib.types.str;
            example = "/dev/nvme0n1";
            description = "Whole-disk device to partition.";
          };
          swap = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "16G";
            description = "Swap partition size, or null for no swap partition.";
          };
          rootSize = lib.mkOption {
            type = lib.types.str;
            default = "100%";
            example = "64G";
            description = "Root partition size. Use a fixed size when a /home partition follows.";
          };
          home = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Add a /home partition filling the rest of the disk.";
          };
        };
      }
    )
  ];

  den.aspects.disko =
    { host, ... }:
    let
      inherit (host) disk;
      mkExt4 = mountpoint: {
        type = "filesystem";
        format = "ext4";
        inherit mountpoint;
      };
    in
    {
      nixos =
        { lib, ... }:
        {
          imports = [ inputs.disko.nixosModules.default ];

          disko.devices.disk.systemDisk = {
            inherit (disk) device;
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
                  size = disk.rootSize;
                  content = mkExt4 "/";
                };
              }
              // lib.optionalAttrs (disk.swap != null) {
                swap = {
                  size = disk.swap;
                  content = {
                    type = "swap";
                    discardPolicy = "both";
                  };
                };
              }
              // lib.optionalAttrs disk.home {
                home = {
                  size = "100%";
                  content = mkExt4 "/home";
                };
              };
            };
          };
        };
    };

}
