{ inputs, ... }:

{

  den.aspects.stylix = {
    nixos = { pkgs, ... }: {

      imports = [
        inputs.stylix.nixosModules.default
      ];

      stylix = {
        enable = true;
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        image = "${inputs.self}/dots/backgrounds/1-glowing-city.png";
        polarity = "dark";
        opacity = {
          applications = 0.9;
          terminal = 0.9;
          desktop = 0.3;
          popups = 0.8;
        };
        cursor = {
          package = pkgs.graphite-cursors;
          name = "graphite-dark";
          size = 24;
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

    homeManager =
      { config, ... }:
      let
        colors = config.lib.stylix.colors.withHashtag;
        inherit (config) stylix;
      in
      {
        programs.wlr-which-key.settings = {
          background = colors.base00;
          color = colors.base05;
          border = colors.base0D;
          font = "${stylix.fonts.monospace.name} ${stylix.fonts.sizes.popups}";
        };
      };

  };

}
