{ den, ... }:

let
  asp = den.aspects;
  bat = den.batteries;
in

{

  den.aspects.nubabe = {

    user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbT2ErzGeM4IKpSpCPTOh4xizMswYLFeIulTS94pI23 nubabe@t490-arch"
    ];

    includes = [
      (bat.user-shell "zsh")
      asp.zsh
      asp.oh-my-posh

      asp.ssh-access
    ];

  };
  # nubabe + a graphical session. Desktop is a user trait: including the hyprland
  # aspect here routes its nixos bits (compositor + greeter) onto the host and its
  # homeManager bits onto nubabe.
  den.aspects.nubabe-graphical = {
    includes = [
      asp.nubabe
      asp.hyprland
    ];
  };

}
