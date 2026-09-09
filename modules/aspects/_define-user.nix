{ lib, ... }:
let
  description = ''
    Defines a user at OS and Home levels.

    Works in NixOS/Darwin and standalone Home-Manager.

    Applied to every entity via den.default.includes (see modules/den.nix).
    Equivalent to the upstream den.batteries.define-user battery.
  '';

  isRoot = user: user.userName == "root";

  homeDir =
    host: user:
    if lib.hasSuffix "darwin" host.system then
      "/Users/${user.userName}"
    else if isRoot user then
      "/root"
    else
      "/home/${user.userName}";

  userContext =
    { host, user }:
    {
      name = "define-user/${user.userName}@${host.name}";
      nixos.users.users.${user.userName} = {
        name = user.userName;
        group = user.userName;
        home = homeDir host user;
        isNormalUser = !(isRoot user);
      };
      nixos.users.groups.${user.userName} = {
        name = user.userName;
      };
      darwin.users.users.${user.userName} = {
        name = user.userName;
        home = homeDir host user;
      };
      homeManager = {
        home.username = user.userName;
        home.homeDirectory = homeDir host user;
      };
    };

  hmContext =
    { home }:
    userContext {
      host.system = home.system;
      user.userName = home.userName;
    }
    // {
      name = "define-user/home";
    };
in
{
  den.aspects.define-user = {
    name = "define-user";
    inherit description;
    includes = [
      userContext
      hmContext
    ];
  };
}
