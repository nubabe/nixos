{ inputs, ... }:

{

  den.aspects.fastfetch.homeManager = {
    programs.fastfetch = {
      enable = true;
    };
    xdg.configFile."fastfetch/config.jsonc".source = "${inputs.self}/dots/fastfetch.jsonc";
  };

}
