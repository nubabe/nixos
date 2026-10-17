{ inputs, ... }:

{

  den.aspects.stylix.nixos = { config, pkgs, ... }: {

    imports = [
      inputs.stylix.nixosModules.default
    ];

    stylix = {
      enable = true;
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";
      opacity = {
        applications = 0.9;
        terminal = 0.9;
        desktop = 0.3;
        popups = 0.8;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove Nerd Font";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };

  };

}
