{ den, ... }:

let
  asp = den.aspects;
in

{

  den.aspects.hyprland = {

    includes = [
      asp.uwsm
      asp.greetd
      asp.pipewire
    ];

    nixos = { pkgs, ... }: {

      programs.hyprland = {
        enable = true;
        withUWSM = false;
        package = pkgs.unstable.hyprland;
        portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
      };
      programs.uwsm.package = pkgs.unstable.uwsm;

    };

    homeManager = {

      home.sessionVariables.NIXOS_OZONE_WL = "1";

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd.enable = false;
      };
    };

  };

}
