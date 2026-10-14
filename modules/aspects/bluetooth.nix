{ den, ... }:
{

  den.aspects.bluetooth = {
    nixos.hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    provides.to-users.includes = [ den.aspects.bluetui ];
  };

  den.aspects.bluetui.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.unstable.bluetui ];
  };

}
