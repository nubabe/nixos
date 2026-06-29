{ ... }:

{

  den.aspects = {
    "env/nubabe".nixos = {
      nubabe.services.tailscale.apiKeyFile = null;
      services.tailscale.authKeyFile = null;
      services.openssh.ports = [ 2009 ];
    };
    "env/pgTechEvent".nixos = {
      nubabe.services.tailscale.apiKeyFile = null;
      services.tailscale.authKeyFile = null;
      services.openssh.ports = [ 1868 ];
    };
  };

}
