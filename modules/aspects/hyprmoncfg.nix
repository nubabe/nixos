_:

{

  den.aspects.hyprmoncfg.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "1.22.1";
      commit = "7e096f2";
      sourceSri = "sha256-M/X9CnN5AM/zYSfFHgdlLIaYb8o3aSDRA0KBsht2PsA=";
      vendorSri = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";

      # Upstream only ships the real Nix recipe as a template, substituted by
      # their own release tooling (see PACKAGING.md) rather than committed as
      # a usable default.nix. Fetch it and fill in the same placeholders
      # ourselves instead of vendoring the recipe body.
      template = builtins.readFile (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/crmne/hyprmoncfg/v${version}/packaging/nix/default.nix.in";
          hash = "sha256-oOE9lJH5AbTFJztQAmMwB11LH3FY/RtZdYPPVUC9Sc8=";
        }
      );

      # v1.22.1's template still references a test file removed from the
      # tree (internal/omarchywatch/internalscale_test.go); drop it so
      # postPatch doesn't fail on a missing path.
      patched =
        builtins.replaceStrings [ "      internal/omarchywatch/internalscale_test.go \\\n" ] [ "" ]
          template;

      substituted =
        builtins.replaceStrings
          [ "@VERSION@" "@SOURCE_SRI@" "@NIX_VENDOR_SRI@" "@COMMIT@" ]
          [
            version
            sourceSri
            vendorSri
            commit
          ]
          patched;

      package =
        (pkgs.unstable.callPackage (builtins.toFile "hyprmoncfg.nix" substituted) { }).overrideAttrs
          (_: {
            # The test suite shells out to a live hyprctl/Hyprland session; it
            # can't run in the build sandbox.
            doCheck = false;
            doInstallCheck = false;
          });

      target = config.wayland.systemd.target;
    in
    {

      home.activation.ensureHyprmoncfgFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run touch "${config.xdg.configHome}/hypr/hyprmoncfg-monitors.lua"
      '';

      wayland.windowManager.hyprland.extraConfig = ''
        require("hyprmoncfg-monitors")
      '';

      home.packages = [ package ];
      systemd.user.packages = [ package ];
      systemd.user.services.hyprmoncfgd = {
        Unit = {
          Description = "Hyprland monitor profile daemon (hyprmoncfgd)";
          After = [ target ];
          PartOf = [ target ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${package}/bin/hyprmoncfgd";
          Restart = "on-failure";
          RestartSec = 0;
        };
        Install.WantedBy = [ target ];
      };
    };

}
