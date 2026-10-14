{

  den.aspects.git = {
    homeManager = { user, ... }: {
      programs.git = {
        enable = true;
        settings = {
          user.email = user.email;
          user.name = user.userName;
          core.editor = "$EDITOR";
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          help.autocorrect = 15;
        };
      };
      home.shellAliases = {
        ga = "git add -A";
        gc = "git commit";
        gp = "git push";
        gs = "git status";
      };
    };
  };

}
