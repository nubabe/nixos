{ ... }:

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
            exec ${cmd} "$APP" "$@"
            # exec ${cmd} handlr open "$@"
          '';
        };

      in
      {

        home.packages = [
          pkgs.handlr-regex
          xdg-open
        ];

      };

  };
}
