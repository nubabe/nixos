{ inputs, ... }:

# Per-deployment tweaks. A host includes exactly one of these to pick the SSH
# port (and any other environment-specific settings) for where it runs.

{

  den.aspects = {
    nubabe-env.nixos = { config, ... }: {
      services.openssh.ports = [ 2009 ];

      sops.secrets = {
        "tailscale/apiKey".sopsFile = "${inputs.self}/secrets/nubabe-env.yaml";
        "tailscale/authKey".sopsFile = "${inputs.self}/secrets/nubabe-env.yaml";
      };

      nubabe.services.tailscale.apiKeyFile = config.sops.secrets."tailscale/apiKey".path;
      services.tailscale.authKeyFile = config.sops.secrets."tailscale/authKey".path;
    };
  };

}
