{ den, ... }:

{

  den.schema.host.imports = [
    (
      { lib, ... }:
      {
        options.stateVersion = lib.mkOption {
          type = lib.types.str;
          default = "26.05";
          example = "26.05";
          description = "NixOS `system.stateVersion` for this host.";
        };
      }
    )
  ];

  den.schema.user.imports = [
    (
      { lib, ... }:
      {
        options.stateVersion = lib.mkOption {
          type = lib.types.str;
          default = "26.05";
          example = "26.05";
          description = "home-manager `home.stateVersion` for this user.";
        };
      }
    )
  ];

  den.aspects.stateVersion = {
    nixos =
      { host, ... }:
      {
        system.stateVersion = host.stateVersion;
      };
    homeManager =
      { user, ... }:
      {
        home.stateVersion = user.stateVersion;
      };
  };

  den.default.includes = [ den.aspects.stateVersion ];

}
