{
  inputs,
  den,
  withSystem,
  lib,
  ...
}:

{

  imports = [ inputs.den.flakeModule ];

  den.default = {
    os = { host, ... }: { nixpkgs.pkgs = withSystem host.system ({ pkgs, ... }: pkgs); };
    nixos = { host, ... }: {
      hardware.facter.reportPath = ../hardware-configuration/${host.name}.json;
      imports = with inputs.self.modules.nixos; [
        externalModules
        default
      ];
    };
    includes = [
      # den.batteries.define-user
      den.aspects."bat/define-user"
      den.batteries.hostname
      den.batteries.inputs'
    ];
  };

  den.schema.user = {
    classes = lib.mkDefault [ "homeManager" ];
  };
  den.schema.host = { host, ... }: {
    users = lib.mkIf (lib.hasSuffix "linux" host.system) { root = { }; };
  };

}
