{ inputs, ... }: {

  den.aspects.stami-buchhaltung =
    let
      interfaceName = "wg-stami";
    in
    {
      nixos = { config, ... }: {

        sops.secrets = {
          "wg-stami-buchhaltung" = {
            sopsFile = "${inputs.self}/secrets/stami-buchhaltung.conf.enc";
            format = "binary";
          };
        };
        networking.wg-quick.interfaces.${interfaceName} = {
          autostart = false;
          configFile = config.sops.secrets."wg-stami-buchhaltung".path;
        };

      };

      homeManager =
        {
          config,
          pkgs,
          osConfig,
          ...
        }:
        {
          sops.secrets."stami-buchhaltung.RDP" = {
            sopsFile = "${inputs.self}/secrets/stami-buchhaltung.RDP.enc";
            format = "binary";
          };
          home.packages = [
            (pkgs.writeShellApplication {
              name = "stami-buchhaltung";
              runtimeInputs = [
                pkgs.freerdp
                osConfig.systemd.package
              ];
              text = ''
                sudo="${osConfig.security.wrapperDir}/sudo"
                unit="wg-quick-${interfaceName}.service"


                started_by_us=0
                if ! systemctl is-active --quiet "$unit"; then
                  "$sudo" systemctl start "$unit"
                  started_by_us=1
                fi
                trap '[ "$started_by_us" -eq 1 ] && "$sudo" systemctl stop "$unit"' EXIT
                trap 'exit 130' INT TERM
                rc=0
                xfreerdp ${config.sops.secrets."stami-buchhaltung.RDP".path} || rc="$?"
                exit "$rc"
              '';
            })
          ];
        };

    };

}
