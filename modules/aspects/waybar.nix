{ inputs, ... }: {

  den.aspects.waybar.homeManager = {

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    xdg.configFile."waybar/config.jsonc".source = "${inputs.self}/dots/waybar.jsonc";

  };

}
