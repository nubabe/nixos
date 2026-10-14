_: {

  den.aspects.claude-code.homeManager = { pkgs, ... }: {

    programs.claude-code = {
      enable = true;
      package = pkgs.unstable.claude-code;
    };

  };

  den.aspects.skills.homeManager =
    { pkgs, ... }:
    let
      package = pkgs.untstable.skills;
    in
    {
      home.packages = [ package ];
      # home.shellAliases.skills = "${lib.getExe package} --global --agent claude-code";
    };

}
