{ inputs, ... }:

# My tailscale setup. The reusable module lives in modules/services/tailscale.nix.

{

  den.aspects.tailscale.nixos = {
    imports = [ inputs.self.modules.nixos.tailscale ];

    services.tailscale = {
      enable = true;
      openFirewall = true;
      disableTaildrop = true;
      disableUpstreamLogging = true;
    };
  };

}
