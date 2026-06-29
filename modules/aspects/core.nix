{ ... }:

{

  den.aspects.core.nixos = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      man-pages
      man-pages-posix
    ];
    programs.git.enable = true;

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    time.timeZone = "Europe/Berlin";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "en_DK.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_MONETARY = "en_IE.UTF-8";
      };
    };

  };

}
