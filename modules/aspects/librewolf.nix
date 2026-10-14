{

  den.aspects.librewolf = {
    homeManager = {
      programs.librewolf = {
        enable = true;
      };
    };
    provides.asDefault.homeManager.home.sessionVariables.BROWSER = "librewolf";
  };

}
