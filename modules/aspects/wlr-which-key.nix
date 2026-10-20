{ inputs, ... }: {

  den.aspects.wlr-which-key.homeManager =
    { config, ... }:
    let
      appRunner = config.home.sessionVariables.APP_RUNNER;
    in
    {

      imports = [ "${inputs.home-manager-unstable}/modules/programs/wlr-which-key.nix" ];

      programs.wlr-which-key = {
        enable = true;
        settings = {
          separator = " ❯ ";
          anchor = "bottom-right";
          margin_right = 5;
          margin_bottom = 5;
          border_width = 3;
          corner_r = 0;
          padding = 5;
          menu = [
            {
              key = "p";
              desc = "power";
              submenu = [
                {
                  key = "s";
                  desc = "shutdown";
                  cmd = "shutdown now";
                }
                {
                  key = "r";
                  desc = "reboot";
                  cmd = "reboot";
                }
              ];
            }
            {
              key = "o";
              desc = "open";
              submenu = [
                {
                  key = "b";
                  desc = "browser";
                  cmd = "${appRunner}${config.home.sessionVariables.BROWSER}";
                }
                {
                  key = "t";
                  desc = "terminal";
                  cmd = "${appRunner}${config.home.sessionVariables.TERMINAL}";
                }
                {
                  key = "o";
                  desc = "app menu";
                  cmd = "${config.home.sessionVariables.APP_MENU_DRUN}";
                }
              ];
            }
          ];
        };
      };

    };
}
