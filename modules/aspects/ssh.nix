{ ... }:

{

  den.aspects.ssh = {

    nixos.services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [ ];
      };
      extraConfig = ''
        MaxAuthTries 3
      '';
    };

    provides.to-hosts.nixos = { user, ... }: {
      services.openssh.settings.AllowUsers = [ user.userName ];
    };
  };

}
