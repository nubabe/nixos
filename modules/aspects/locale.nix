_:

{

  den.aspects.locale = {

    os.time.timeZone = "Europe/Berlin";

    nixos.i18n = {
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
