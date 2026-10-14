{
  den.aspects.swapfile = { sizeInGiB }: {

    nixos.swapDevices = [
      {
        size = sizeInGiB * 1024;
        device = "/var/lib/swapfile";
      }
    ];

  };
}
