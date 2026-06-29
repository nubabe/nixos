{ ... }:

{

  den.aspects.companion.nixos = {
    nubabe.services.companion = {
      enable = true;

    };

  };

  flake.modules.nixos.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.nubabe.services.companion;
      dataDir = "/var/lib/bitfocus-companion";
    in

    {
      options.nubabe.services.companion = {
        enable = lib.mkEnableOption "Bitfocus Companion";
        package = lib.mkPackageOption pkgs.unstable "bitfocus-companion" { };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8000;
          description = ''
            Listening port of Companion.
          '';
          example = 443;
        };

        user = lib.mkOption {
          default = "companion";
          type = lib.types.str;
          description = ''
            User account under which companion runs.

            ::: {.note}
            If left as the default value this user will automatically be created
            on system activation, otherwise you are responsible for
            ensuring the user exists before the headscale service starts.
            :::
          '';
        };

        group = lib.mkOption {
          default = "companion";
          type = lib.types.str;
          description = ''
            Group under which companion runs.

            ::: {.note}
            If left as the default value this group will automatically be created
            on system activation, otherwise you are responsible for
            ensuring the user exists before the headscale service starts.
            :::
          '';
        };
      };

      config = lib.mkIf cfg.enable {

        users.groups.companion = lib.mkIf (cfg.group == "companion") { };

        users.users.companion = lib.mkIf (cfg.user == "companion") {
          description = "Bitfocus-Companion user";
          home = dataDir;
          group = cfg.group;
          isSystemUser = true;
        };

        systemd.services.companion = {
          description = "Bitfocus Companion";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            StateDirectory = "bitfocus-companion";
            ExecStart = "${cfg.package}/bin/bitfocus-companion --admin-port ${lib.toString cfg.port}";
            Restart = "on-failure";
            RestartSec = "10s";
            NoNewPrivileges = true;
            ProtectSystem = "full";
            ProtectHome = true;
          };
        };

        networking.firewall.allowedTCPPorts = [ cfg.port ];
        networking.firewall.allowedUDPPorts = [ cfg.port ];
      };

    };

}
