{

  den.aspects.rofi = {
    homeManager =
      { config, ... }:
      let
        prefix = config.home.sessionVariables.APP_RUNNER;
      in
      {
        programs.rofi = {
          enable = true;
          terminal = config.home.sessionVariables.TERMINAL;
          extraConfig = {
            run-command = "${prefix}{cmd}";
            run-shell-command = "${prefix}{terminal} -e {cmd}";
          };
        };
      };

    provides.asDefault.homeManager.home.sessionVariables = {
      APP_MENU = "rofi";
      APP_MENU_DRUN = "rofi -show drun";
    };
  };

}
