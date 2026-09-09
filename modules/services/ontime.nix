_:

# Reusable NixOS module: runs Ontime (getontime/ontime) as an OCI container,
# opens its HTTP and OSC ports. Enable with nubabe.services.ontime.enable.

{

  flake.modules.nixos.ontime =
    { config, lib, ... }:
    let
      cfg = config.nubabe.services.ontime;
    in
    {
      options.nubabe.services.ontime = {
        enable = lib.mkEnableOption "Ontime";
        port = lib.mkOption {
          type = lib.types.port;
          default = 4001;
          description = ''
            HTTP listening port of Ontime.
          '';
        };
        OSCPort = lib.mkOption {
          type = lib.types.port;
          default = 8888;
          description = ''
            OSC listening port of Ontime.
          '';
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
            TZ = config.time.timeZone;
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
