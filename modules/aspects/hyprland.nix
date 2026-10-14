{ inputs, den, ... }:

let
  asp = den.aspects;
in

{

  den.aspects.hyprland = {

    includes = [
      asp.uwsm
      asp.greetd
      asp.pipewire
      asp.cursor
      asp.brightnessctl
      asp.hyprmoncfg
      asp.clipboard
    ];

    nixos = { pkgs, ... }: {

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        package = pkgs.unstable.hyprland;
        portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
      };
      programs.uwsm.package = pkgs.unstable.uwsm;

    };

    homeManager = { config, lib, ... }: {

      # xdg.configFile.hypr = {
      #     recursive = true;
      #     source = "${inputs.self}/dots/hypr";
      #   };

      home.sessionVariables.NIXOS_OZONE_WL = "1";
      home.sessionVariables.GDK_BACKEND = "wayland";

      services.hyprpolkitagent.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd.enable = false;

        extraConfig = ''
          require("${inputs.self}/dots/hypr/*")
        '';

        settings = {
          config = {
            input =
              let
                kb = config.home.keyboard;
              in
              lib.mkIf (kb != null) {
                kb_layout = kb.layout;
                kb_variant = kb.variant;
                kb_options = builtins.concatStringsSep "," kb.options;
              };
          };
        };
      };
    };

  };

}
