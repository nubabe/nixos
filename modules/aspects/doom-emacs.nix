{ inputs, ... }: {

  den.aspects.doom-emacs.homeManager = { lib, pkgs, ... }: {
    imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];
    services.emacs = {
      enable = true;
      client.enable = true;
      startWithUserSession = "graphical";
    };
    programs.doom-emacs = {
      enable = true;
      emacs = pkgs.emacs-pgtk;
      tangleArgs = ".";
      doomDir = "${inputs.self}/dots/doom";
    };
    home.activation.ensureOrgDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $VERBOSE_ARG "$HOME/org"
    '';
  };
}
