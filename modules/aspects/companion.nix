{ inputs, ... }:

# Enables Bitfocus Companion. Reusable module: modules/services/companion.nix.

{

  den.aspects.companion.nixos = {
    imports = [ inputs.self.modules.nixos.companion ];
    nubabe.services.companion.enable = true;
  };

}
