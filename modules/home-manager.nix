{ inputs, ... }:

{

  imports = [
    inputs.home-manager.flakeModules.default
  ];

  den.default.os = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

}
