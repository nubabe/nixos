_:

# Per-deployment tweaks. A host includes exactly one of these to pick the SSH
# port (and any other environment-specific settings) for where it runs.

{

  den.aspects = {
    nubabe-env.nixos.services.openssh.ports = [ 2009 ];
  };

}
