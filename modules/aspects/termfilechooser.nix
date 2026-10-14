{

  den.aspects.termfilechooser = {
    nixos =
      { pkgs, ... }:
      let
        package = pkgs.xdg-desktop-portal-termfilechooser;
      in
      {
        xdg.portal = {
          enable = true;
          extraPortals = [ package ];
          config.common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    homeManager =
      { pkgs, config, ... }:
      let
        package = pkgs.xdg-desktop-portal-termfilechooser;
      in
      {

        xdg.configFile."xdg-desktop-portal-termfilechooser/config".source =
          (pkgs.formats.ini { }).generate "config"
            {
              filechooser = {
                cmd = "${package}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
                default_dir = "$HOME";
                env = "TERMCMD='${config.home.sessionVariables.TERMINAL} --title=termfilechooser'";
                open_mode = "suggested";
                save_mode = "suggested";
              };
            };
      };
  };

}
