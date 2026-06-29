{ inputs, ... }:

{

  den.aspects.stylix.nixos = { config, pkgs, ... }: {

    imports = [
      inputs.stylix.nixosModules.default
    ];

    stylix = {
      enable = true;
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";
      polarity = "dark";
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove Nerd Font";
        };
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;
        emoji = {
          package = pkgs.whatsapp-emoji-font;
          name = "Apple Color Emoji";
        };
      };
    };

  };

}
