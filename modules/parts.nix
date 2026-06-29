{ inputs, ... }:

{

  imports = with inputs; [
    flake-parts.flakeModules.modules
    nix-darwin.flakeModules.default
  ];

}
