{ ... }:

{

  den.aspects.pipewire.provides.to-hosts.nixos.services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;

    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

}
