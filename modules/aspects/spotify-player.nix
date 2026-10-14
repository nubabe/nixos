{

  den.aspects.spotify-player = {
    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        programs.spotify-player = {
          enable = true;
          package = pkgs.unstable.spotify-player;
          settings = {
            enable_streaming = "DaemonOnly";
            enable_notify = false;
            play_icon = "";
            pause_icon = "";
            liked_icon = "";
            explicit_icon = "󰯷";
            cover_img_length = 18;
            cover_img_width = 9;
            enable_mouse_scroll_volume = false;
            enable_relative_line_number = true;
            tracks_playback_limit = 100;
            device = {
              name = lib.mkDefault "spotify-player";
              device_type = "computer";
              volume = 100;
              bitrate = 320;
              audio_cache = true;
            };
          };
        };
        systemd.user.services.spotify-player-daemon =
          let
            target = config.wayland.systemd.target;
          in
          {
            Unit = {
              Description = "spotify-player daemon";
              After = [ target ];
              PartOf = [ target ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${config.programs.spotify-player.package}/bin/spotify_player --daemon";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install.WantedBy = [ target ];
          };
      };
    provides.to-users = { host, ... }: {
      homeManager.programs.spotify-player.settings.device.name = "spotify-player ${host.hostName}";
    };

  };
}
