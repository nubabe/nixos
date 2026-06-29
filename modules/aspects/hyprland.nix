{ den, ... }:

let
  asp = den.aspects;
in

{

  den.aspects.hyprland = {

    includes = [
      asp.uwsm
      asp.pipewire
    ];

    provides.to-hosts = {
      includes = [ asp.greetd ];

      nixos = { pkgs, ... }: {

        programs.hyprland = {
          enable = true;
          withUWSM = true;
          package = pkgs.unstable.hyprland;
          portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
        };
        programs.uwsm.package = pkgs.unstable.uwsm;

      };

    };

    homeManager = { };

  };

}
