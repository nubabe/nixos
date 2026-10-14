{

  den.aspects.brave = {
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.brave ]; };
    provides.asDefault.homeManager.home.sessionVariables.BROWSER = "brave";
  };

}
