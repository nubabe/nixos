{ den, ... }:
{

  den.quirks.ssh = {
    description = "ssh endpoint of a host";
  };

  den.policies.collect-ssh =
    _:
    let
      inherit (den.lib.policy) pipe;
    in
    [
      (pipe.from "ssh" [
        (pipe.collect (_: true))
      ])
    ];

  den.schema.host.includes = [ den.policies.collect-ssh ];

}
