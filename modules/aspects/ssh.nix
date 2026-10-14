_:

{

  # Host concern: enable and harden sshd. Include in a host aspect.
  den.aspects.sshd = {
    ssh = { config, ... }: {
      hostname = config.networking.hostName;
      ipAddress = config.nubabe.services.tailscale.ipv4;
      port = builtins.head config.services.openssh.ports;
    };
    nixos =
      { config, lib, ... }:
      let
        tailscaleInterface = config.services.tailscale.interfaceName;
        ports = config.services.openssh.ports;
      in
      {
        networking.firewall.interfaces.${tailscaleInterface}.allowedTCPPorts =
          lib.mkIf config.services.tailscale.enable ports;
        services.openssh = {
          enable = true;
          openFirewall = !config.services.tailscale.enable;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
          };
          extraConfig = ''
            MaxAuthTries 3
          '';
        };
      };
  };

  # User concern: grant this user SSH access on the hosts they live on.
  # Harmless where the host never enables sshd (option set, never rendered).
  den.aspects.ssh-access.nixos =
    { user, ... }:
    {
      services.openssh.settings.AllowUsers = [ user.userName ];
    };

  den.aspects.ssh.homeManager =
    { ssh, lib, ... }:
    let
      hosts = builtins.map (host: {
        name = host.hostname;
        value = lib.hm.dag.entryBefore [ "*" ] {
          inherit (host) port;
          hostname = host.ipAddress;
        };
      }) ssh;

      hostBlocks = builtins.listToAttrs hosts;
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            ControlMaster = "yes";
            ControlPath = "~/.ssh/master-%r@%h:%p";
            ControlPersist = 300;
            ServerAliveInterval = 15;
          };
        }
        // hostBlocks;
      };
    };

}
