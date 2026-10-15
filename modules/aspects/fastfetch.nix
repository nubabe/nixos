{inputs, ...}:

{

  den.aspects.fastfetch.homeManager = {
    programs.fastfetch = { enable = true; 

      settings = builtins.fromJson (builtints.readFile "${inputs.self}/dots/fastfetch.jsonc");
    };
  };

}
