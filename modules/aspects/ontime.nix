{ ... }:

{
  den.aspects.ontime.nixos = {

    nubabe.services.ontime = {
      enable = true;
    };

  };

  flake.modules.nixos.default =
    { config, lib, ... }:
    let
      cfg = config.nubabe.services.ontime;
    in
    {
      options.nubabe.services.ontime = {
        enable = lib.mkEnableOption "Bitfocus Companion";
        port = lib.mkOption {
          type = lib.types.port;
          default = 4001;
          description = ''
            Listening port of Ontime.
          '';
          example = 443;
        };
        OSCPort = lib.mkOption {
          type = lib.types.port;
          default = 8888;
          description = ''
            Listening port of Ontime.
          '';
          example = 443;
        };
      };
      config = lib.mkIf cfg.enable {
        virtualisation.oci-containers.containers."ontime" = {
          image = "getontime/ontime:latest";
          ports = [
            "${lib.toString cfg.port}:4001/tcp"
            "${lib.toString cfg.OSCPort}:8888/udp"
            "9999:9999/udp"
          ];
          volumes = [
            "/var/lib/ontime:/data"
          ];
          environment = {
            TZ = "Europe/Berlin";
          };
        };

        systemd.services."${config.virtualisation.oci-containers.backend}-ontime" = {
          serviceConfig = {
            StateDirectory = "ontime";
          };
        };

        networking.firewall.allowedTCPPorts = [ cfg.port ];
        networking.firewall.allowedUDPPorts = [ cfg.OSCPort ];
      };
    };

}
