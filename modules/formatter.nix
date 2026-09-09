{ inputs, ... }:

{

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true; # formatting
        statix.enable = true; # anti-pattern lint + fix
        deadnix.enable = true; # dead-code lint + fix
      };
    };
  };

}
