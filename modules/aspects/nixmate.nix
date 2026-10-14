{

  den.aspects.nixmate.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.nixmate ];
      xdg.configFile."nixmate/config.toml".source = (pkgs.formats.toml { }).generate "config.toml" {
        theme = "transparent";
        language = "english";
        layout = "auto";
        welcome_shown = true;
        ai_enabled = false;
        nixpkgs_channel = "auto";
      };
    };

}
