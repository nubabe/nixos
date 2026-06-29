{ inputs, ... }:

{

  flake.modules.nixos.externalModules.imports = [ inputs.disko.nixosModules.default ];

}
