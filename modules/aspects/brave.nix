{ inputs, ... }: {

  den.aspects.brave = {
    homeManager = { pkgs, ... }: {
      imports = [ "${inputs.home-manager-unstable}/modules/programs/chromium.nix" ];
      disabledModules = [ "programs/chromium.nix" ];

      programs.brave-origin = {
        enable = true;
        package = pkgs.unstable.brave-origin;
      };
    };

    provides.asDefault.homeManager = {lib, config, ...}: let package = config.programs.brave-origin.package; in {
      home.sessionVariables.BROWSER = "${lib.getExe package}";
      xdg.mimeApps.defaultApplicationPackages = [ package ];
    };
  };

}
