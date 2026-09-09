_:

{

  # Host concern: enable and harden sshd. Include in a host aspect.
  den.aspects.sshd.nixos.services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    extraConfig = ''
      MaxAuthTries 3
    '';
  };

  # User concern: grant this user SSH access on the hosts they live on.
  # Harmless where the host never enables sshd (option set, never rendered).
  den.aspects.ssh-access.nixos =
    { user, ... }:
    {
      services.openssh.settings.AllowUsers = [ user.userName ];
    };

}
