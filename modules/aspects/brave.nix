{

  den.aspects.brave = {
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.unstable.brave-origin ]; };
    provides.asDefault.homeManager.home.sessionVariables.BROWSER = "brave";
  };

}
