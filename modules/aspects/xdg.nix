_:

{

  den.aspects.xdg-open = {

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let

        cmd = config.home.sessionVariables.APP_RUNNER;

        xdg-open = pkgs.writeShellApplication {
          name = "xdg-open";
          runtimeInputs = [
            pkgs.handlr-regex
            pkgs.jq
          ];
          text = ''
            MIME=$(handlr mime --json "$@" | jq -r '.[0].mime')
            APP=$(handlr get --json "$MIME" | jq -r '.cmd | sub("\\s+$"; "")')
            # shellcheck disable=SC2086
            exec ${cmd}$APP "$@"
            # exec ${cmd}handlr open "$@"
          '';
        };

      in
      {

        xdg.enable = true;

        xdg.mimeApps.enable = true;

        home.packages = [
          pkgs.handlr-regex
          xdg-open
        ];

      };

  };
}
