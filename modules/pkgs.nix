{ inputs, ... }:

let
  nixpkgs-config = {
    allowUnfree = true;
  };
in

{

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.nixpkgs-unstable ];
        config = nixpkgs-config;
      };
    };

  flake.overlays = {
    nixpkgs-unstable = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config = nixpkgs-config;
      };
    };
  };

}
