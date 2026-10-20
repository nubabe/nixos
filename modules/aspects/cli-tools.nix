{

  den.aspects.tools.homeManager = {pkgs, ...}: {
    programs = {
      bat.enable = true;
      btop.enable = true;
      fd.enable = true;
      fzf.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      zoxide.enable = true;
      yazi.enable = true;
    };
    home.packages = [ pkgs.file pkgs.xxd pkgs.tree ];
    home.shellAliases = {
      cd = "z";
      cat = "bat";
    };
  };

}
