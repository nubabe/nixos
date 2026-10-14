{ inputs, den, ... }:

{

  den.schema.host.includes = [ den.aspects.sops-nix ];

  den.aspects.sops-nix = {

    nixos = {

      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

    };

  };

}
