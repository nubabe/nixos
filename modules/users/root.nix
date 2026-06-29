{ den, ... }:

let
  asp = den.aspects;
  bat = den.batteries;
in

{

  den.aspects.root = {

    includes = [
      (bat.user-shell "zsh")
      asp.zsh
      asp.oh-my-posh
    ];

  };

}
