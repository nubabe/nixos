{

  den.aspects.librewolf = {
    homeManager = {
      programs.librewolf = {
        enable = true;
      };
    };
    provides.asDefault.homeManager = {lib, config, ...}: let package = config.programs.librewolf.package; in {
      home.sessionVariables.BROWSER = "${lib.getExe package}";
      xdg.mimeApps.defaultApplicationPackages = [ package ];
    };

  };

}
