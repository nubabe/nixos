{
  inputs,
  den,
  lib,
  ...
}:

{

  imports = [ inputs.den.flakeModule ];

  # Strict host/user schemas only — undeclared attrs on a host or user throw
  # (catches typos). NOT `inputs.den.flakeModules.strict`: that also strictens
  # `den.schema.aspect`, which swaps the aspect submodule's freeform class-key
  # type for an unconditional throw and breaks every `den.aspects.<x>.<class>`
  # attr-path in this repo. Declare new host/user metadata with
  # `den.schema.{host,user}.imports = [ { options.<name> = lib.mkOption {...}; } ]`.
  den.schema.host.isStrict = true;
  den.schema.user.isStrict = true;
  den.schema.user.imports = [
    (
      { config, lib, ... }:
      {
        options.email = lib.mkOption {
          type = lib.types.str;
          description = "Email used for git commits etc., sourced from the user's own aspect.";
        };
        config.email = lib.mkDefault den.aspects.${config.name}.email;
      }
    )
  ];

  # Lets `den.aspects.<user>.email` hold a plain value without den's key
  # classifier mistaking `email` for an unknown class.
  den.reservedKeys = [ "email" ];

  den.default = {
    includes = [
      den.batteries.define-user
      # den.aspects.define-user
      den.batteries.hostname
      den.batteries.inputs'
    ];
  };

  den.schema.user = {
    classes = lib.mkDefault [ "homeManager" ];
  };
  # den.schema.host = { host, ... }: {
  #   users = lib.mkIf (lib.hasSuffix "linux" host.system) { root = { }; };
  # };

}
