_: {

  den.aspects.tldr.homeManager =
    { pkgs, ... }:
    let
      package = pkgs.tlrc;
    in
    {

      home.packages = [ package ];

      services.tldr-update = {
        enable = true;
        inherit package;
      };

    };

}
