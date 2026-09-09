_:

# Reusable NixOS module. Adds nubabe.services.tailscale.{ipv4,apiKeyFile,tags}
# on top of the upstream services.tailscale: tag advertising, nftables firewall
# mode, and a one-shot unit that pins the node's Tailscale IPv4 through the API.
# Activates whenever services.tailscale.enable is set.

{

  flake.modules.nixos.tailscale =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.nubabe.services.tailscale;
      inherit (lib) mkOption types mkIf;
    in
    {

      options.nubabe.services.tailscale = {

        ipv4 = mkOption {
          type = types.str;
          default = "";
          example = "100.64.10.5";
          description = "IPv4 address in the 100.64.0.0/10 range to use.";
        };

        apiKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          example = "/run/secrets/tailscale_api_key";
          description = "A file containing the API key. Used for setting the Tailscale IP.";
        };

        tags = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "eng"
            "montreal"
            "ssh"
          ];
          description = "ACL tags to request with the --advertise-tags flag.";
        };

      };

      config = mkIf config.services.tailscale.enable {
        services.tailscale.extraUpFlags = lib.optionals (cfg.tags != [ ]) [
          "--advertise-tags"
          (lib.concatStringsSep "," (map (tag: "tag:${tag}") cfg.tags))
        ];

        networking.firewall = {
          trustedInterfaces = [ config.services.tailscale.interfaceName ];
        };

        systemd.services.tailscaled = mkIf config.networking.nftables.enable {
          serviceConfig.Environment = [
            "TS_DEBUG_FIREWALL_MODE=nftables"
          ];
        };

        systemd.services.tailscale-set-ip = mkIf (cfg.ipv4 != "" && cfg.apiKeyFile != null) {
          after = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
            "tailscale-set.service"
          ];
          wants = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
          ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = "30s";
          };

          path = [
            pkgs.jq
            pkgs.curl
            pkgs.coreutils
            config.services.tailscale.package
          ];

          script = ''
            until tailscale status --json >/dev/null 2>&1; do
              sleep 0.5
            done

            getTailscaleIP() {
              tailscale status --json | jq --raw-output '.Self.TailscaleIPs[0]'
            }

            getDeviceID() {
              tailscale status --json | jq -r '.Self.ID'
            }

            if [[ $(getTailscaleIP) != ${cfg.ipv4} ]]; then
              echo "IP is not set. Updating IP via API..."
              curl --fail "https://api.tailscale.com/api/v2/device/$(getDeviceID)/ip" \
                --request POST \
                --header 'Content-Type: application/json' \
                --header "Authorization: Bearer $(cat ${cfg.apiKeyFile})" \
                --data '{
                "ipv4": "${cfg.ipv4}"
              }'
            else
              echo "IP is already set. Doing nothing."
            fi
          '';

        };
      };
    };

}
