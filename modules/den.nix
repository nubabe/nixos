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
  den.schema.host.imports = [ den.lib.strict ];
  den.schema.user.imports = [ den.lib.strict ];

  den.default = {
    nixos = _: {
      # hardware.facter.reportPath = ../hardware-configuration/${host.name}.json;
    };
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
