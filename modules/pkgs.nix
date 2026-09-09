{
  inputs,
  den,
  withSystem,
  ...
}:

let
  nixpkgs-config = {
    allowUnfree = true;
  };
in

{

  # Every entity's `os` nixpkgs instance comes from the flake-parts perSystem
  # `pkgs` (unfree allowed + the nixpkgs-unstable overlay), wired onto all hosts
  # through `den.default.includes`.
  den.default.includes = [ den.aspects.nixpkgs ];

  den.aspects.nixpkgs.os =
    { host, ... }:
    {
      nixpkgs.pkgs = withSystem host.system ({ pkgs, ... }: pkgs);
    };

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
    nixpkgs-unstable = _final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config = nixpkgs-config;
      };
    };
  };

}
