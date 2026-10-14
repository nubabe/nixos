{ den, ... }:

{

  den.aspects.network = {
    nixos.networking = {
      firewall.enable = true;
      nftables.enable = true;

    };

    provides.wireless = {
      nixos = {
        networking.networkmanager.wifi.backend = "iwd";
        networking.wireless.iwd = {
          enable = true;
          settings.General = {
            AddressRandomization = "network";
          };
        };
      };

      provides.to-users.includes = [ den.aspects.wlctl ];

    };
    provides.networkmanager.nixos = {
      networking.networkmanager = {
        enable = true;
      };
    };

  };

  den.aspects.wlctl.homeManager = { inputs', ... }: {
    home.packages = [ inputs'.wlctl.packages.wlctl ];
  };

}
