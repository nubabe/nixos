_:

{

  den.aspects.greetd.nixos = { pkgs, lib, ... }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = "${lib.getExe pkgs.tuigreet}";
    };
  };

}
