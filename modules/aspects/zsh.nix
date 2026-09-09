_:

{

  den.aspects.zsh = {

    homeManager = { lib, ... }: {
      home.shell.enableZshIntegration = true;

      programs.zsh = {
        enable = true;

        autosuggestion.enable = true;
        autosuggestion.strategy = [
          "history"
          "completion"
        ];
        syntaxHighlighting.enable = true;

        defaultKeymap = "emacs";

        enableCompletion = true;

        history = {
          append = true;
          ignoreAllDups = true;
          ignoreDups = true;
          ignoreSpace = true;
          saveNoDups = true;
          findNoDups = true;
        };

        initContent =
          let
            earlyConfig = lib.mkOrder 500 ''
              zmodload zsh/complist
            '';

            preCompInit = lib.mkOrder 550 ''
              zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

              zstyle ':completion:*' menu select
              zstyle ':completion:*' group-name '''
              zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

              zstyle ':completion:*:descriptions' format $'\e[01;33m-- %d --\e[00m'
              zstyle ':completion:*:warnings' format $'\e[01;31mNo matches for: %d\e[00m'
            '';
          in
          lib.mkMerge [
            earlyConfig
            preCompInit
          ];
      };

      home.shellAliases = {
        ls = "ls --color=auto";
        l = "ls -la";
        sudo = "sudo ";
      };
    };

  };

}
