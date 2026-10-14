{ inputs, den, ... }:

# Point each host at its nixos-facter hardware report
# (hardware-configuration/<host>.json, path relative to the flake root). Applied
# only when that file exists and has real content, so `system.build.vm` builds
# work without one; a real toplevel build needs the report populated
# (`nixos-facter > <host>.json`). Wired onto every host through
# den.default.includes.

{

  den.default.includes = [ den.aspects.facter ];

  den.aspects.facter.nixos =
    { host, lib, ... }:
    let
      report = "${inputs.self}/hardware-configuration/${host.name}.json";
    in
    lib.optionalAttrs
      (builtins.pathExists report && builtins.match "[[:space:]]*" (builtins.readFile report) == null)
      {
        hardware.facter.reportPath = report;
      };

}
