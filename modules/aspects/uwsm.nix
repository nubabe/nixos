{ den, ... }:

{

  den.aspects.uwsm = {
    includes = [
      den.aspects.app-runner
      den.aspects.xdg-open
    ];
    homeManager =
      {
        config,
        ...
      }:
      {

        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

      };
  };

  den.aspects.app-runner.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    let
      package = pkgs.runapp;
    in
    {

      home.packages = [
        package
      ];

      home.sessionVariables.APP_RUNNER = "${lib.getExe package}";

    };

}
