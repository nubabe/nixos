{

  den.aspects.brightnessctl = {
    nixos =
      { pkgs, ... }:
      let
        package = pkgs.brightnessctl;
      in
      {
        environment.systemPackages = [ package ];
        services.udev.packages = [ package ];
      };

    provides.to-users.homeManager.home.sessionVariables = {
      INCREASE_BRIGHTNESS = "brightnessctl set +5% -e";
      DECREASE_BRIGHTNESS = "brightnessctl set -5% -e";
    };
  };

}
