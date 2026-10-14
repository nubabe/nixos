{ inputs, den, ... }:

{

  den.aspects.pipewire = {
    includes = [ den.aspects.wiremix ];
    nixos = {
      services.pipewire = {
        enable = true;
        audio.enable = true;
        wireplumber.enable = true;

        pulse.enable = true;
        alsa.enable = true;
        jack.enable = true;
      };
    };
  };

  den.aspects.wiremix.homeManager = { pkgs, ... }: {
    imports = [ "${inputs.home-manager-unstable}/modules/programs/wiremix.nix" ];
    programs.wiremix = {
      enable = true;
      package = pkgs.unstable.wiremix;
    };
  };

}
