{

  den.aspects.cursor.homeManager = { pkgs, ... }: {
    home.pointerCursor = {
      enable = true;
      package = pkgs.graphite-cursors;
      name = "graphite-dark";
      hyprcursor.enable = true;
      gtk.enable = true;
      size = 24;
    };
  };

}
