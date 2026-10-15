{ inputs, ... }:

{

  den.aspects.fastfetch.homeManager = {
    programs.fastfetch = {
      enable = true;

      settings = builtins.fromJson (builtins.readFile "${inputs.self}/dots/fastfetch.jsonc");
    };
  };

}
