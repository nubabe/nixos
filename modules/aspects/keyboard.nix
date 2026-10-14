{

  den.aspects.keyboard =
    let
      kbcfg = {
        layout = "us";
        variant = "intl";
        options = [
          "shift:both_capslock"
          "ctrl:nocaps"
        ];
      };
    in

    {
      nixos.services.xserver.xkb = {
        inherit (kbcfg) layout variant;
        options = builtins.concatStringsSep "," kbcfg.options;
      };
      homeManager.home.keyboard = { inherit (kbcfg) layout variant options; };

    };

}
