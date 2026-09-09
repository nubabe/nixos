_:

{

  den.aspects.core.nixos = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      man-pages
      man-pages-posix
    ];
    programs.git.enable = true;

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

  };

}
