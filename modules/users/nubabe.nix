{ den, inputs, ... }:

let
  asp = den.aspects;
  bat = den.batteries;
in

{

  den.aspects.nubabe = {

    email = "nubabe.me@gmail.com";

    nixos.sops.secrets."userPassword" = {
      sopsFile = "${inputs.self}/secrets/nubabe.yaml";
      neededForUsers = true;
    };

    user = { config, ... }: {
      hashedPasswordFile = config.sops.secrets."userPassword".path;
      initialPassword = "test";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbT2ErzGeM4IKpSpCPTOh4xizMswYLFeIulTS94pI23 nubabe@t490-arch"
      ];
    };

    includes = [
      (bat.user-shell "zsh")
      asp.zsh
      asp.oh-my-posh
      asp.tools
      asp.neovim
      asp.neovim._.asDefault

      asp.git

      asp.nixmate
      asp.ssh

      asp.tldr
      asp.fastfetch

      asp.ssh-access
      asp.keyboard
    ];

  };
  # nubabe + a graphical session. Desktop is a user trait: including the hyprland
  # aspect here routes its nixos bits (compositor + greeter) onto the host and its
  # homeManager bits onto nubabe.
  den.aspects.nubabe-graphical = {
    includes = [
      asp.nubabe
      asp.hyprland
      asp.termfilechooser
      asp.foot
      asp.foot._.asDefault
      asp.mako
      asp.rofi
      asp.rofi._.asDefault
      asp.waybar
      asp.keepassxc
      asp.brave
      asp.librewolf
      asp.librewolf._.asDefault
      asp.spotify-player
      asp.doom-emacs
      asp.claude-code
    ];
  };

}
