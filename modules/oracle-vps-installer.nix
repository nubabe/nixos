{ inputs, ... }:
{

  # Throwaway aarch64 QCOW2 disk image for bootstrapping oracle-vps (not a den
  # host) — Oracle's custom-image import only accepts disk-image formats
  # (QCOW2/VMDK/OCI), not raw ISOs, and kexec is broken there (arm64
  # kexec_file_load placement bug), so this image boots directly as the live
  # install environment instead. Same `make-disk-image.nix` helper
  # `nixos-rebuild build-image`/the old nixos-generators qcow-efi format used
  # — plain nixpkgs, no extra flake input. SSH host keys come from the stock
  # profile: generated fresh in tmpfs at each boot, never persisted into the
  # image. Run `nixos-anywhere` against the booted instance once it's up.
  flake.nixosConfigurations.oracle-vps-installer = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      (
        {
          lib,
          pkgs,
          config,
          modulesPath,
          ...
        }:
        {
          imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            autoResize = true;
            fsType = "ext4";
          };
          fileSystems."/boot" = {
            device = "/dev/disk/by-label/ESP";
            fsType = "vfat";
          };

          boot.growPartition = true;
          boot.loader.grub.device = "nodev";
          boot.loader.grub.efiSupport = true;
          boot.loader.grub.efiInstallAsRemovable = true;
          boot.loader.timeout = 0;
          boot.kernelParams = [ "console=ttyAMA0,115200" ];

          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "prohibit-password";
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
          };
          networking.firewall.allowedTCPPorts = [ 22 ];
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbT2ErzGeM4IKpSpCPTOh4xizMswYLFeIulTS94pI23 nubabe@t490-arch"
          ];

          system.build.qcow2 = import "${modulesPath}/../lib/make-disk-image.nix" {
            inherit lib config pkgs;
            inherit (config.virtualisation) diskSize;
            format = "qcow2";
            partitionTableType = "efi";
          };

          system.stateVersion = "26.05";
        }
      )
    ];
  };

}
