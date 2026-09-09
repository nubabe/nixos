{ inputs, ... }:

# Enables Ontime. Reusable module: modules/services/ontime.nix.

{

  den.aspects.ontime.nixos = {
    imports = [ inputs.self.modules.nixos.ontime ];
    nubabe.services.ontime.enable = true;
  };

}
