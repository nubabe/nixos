# nixos-v3

nubabe's NixOS configuration, built with [flake-parts], [import-tree] and [den]
(the aspect / entity model).

## How it fits together

`flake.nix` only declares inputs and hands `./modules` to `import-tree`, which
auto-loads **every** `.nix` file under `modules/` — no manual `imports` lists.
`den` turns those files into `nixosConfigurations`.

- **Entity** — a host or a user. Declares *what exists*:
  `den.hosts.<system>.<name>` and `den.hosts.<...>.users.<name>`. Entities carry
  freeform/typed metadata (`stateVersion`, `disk`, …) that aspects read.
- **Aspect** — a reusable bundle of config for one concern
  (`den.aspects.<name>`): `nixos` / `homeManager` class modules and an `includes`
  list of other aspects. Each class routes to its owner — a user aspect's `nixos`
  content reaches the host automatically, its `homeManager` content the user.
- A host's config = its aspect (`den.aspects.<hostname>`) plus everything that
  aspect `includes`, plus `den.default` (applied to every entity).

Full consumer reference: [`.claude/den-reference.md`](.claude/den-reference.md).
Upstream: <https://den.denful.dev>.

## Conventions

- **Aspect names are flat** (`nubabe-env`, `define-user`, `ssh-access`) — no
  `"path/like"` string keys.
- **Aspect shape:** trivial single-class aspects use the attr-path form
  (`den.aspects.foo.nixos.services.bar.enable = true`). Anything with `includes`,
  `provides`, or more than one class uses the block form
  (`den.aspects.foo = { … }`).
- **Reusable module vs my config:** a self-contained NixOS module that could be
  used by anyone lives in `modules/services/` as
  `flake.modules.nixos.<name>` (declares options + generic behaviour). The
  matching aspect in `modules/aspects/` imports it and sets *my* values.
  See `tailscale` for the pattern.
- **Desktop is a user trait.** `hyprland` is included by a user aspect; its
  `nixos` bits (compositor + greeter) reach the host through the normal user→host
  OS flow, its `homeManager` bits land on the user.

## Layout

```
modules/
  den.nix            den.default (every entity), den.schema tweaks
  parts.nix          flake-parts + nix-darwin flake modules
  systems.nix        systems the flake builds for
  pkgs.nix           nixpkgs instantiation + the `unstable` overlay
  formatter.nix      nixfmt-tree (`nix fmt`)
  home-manager.nix   home-manager wiring

  aspects/           reusable feature aspects, one concern per file
    core.nix           base: man-pages, git, nix flakes
    locale.nix         timezone + i18n
    state-version.nix  `stateVersion` schema option + fan-out to system / home
    disko.nix          `disk` schema option + GPT layout + disko module import
    boot.nix network.nix vm.nix stylix.nix greetd.nix uwsm.nix ...
    ssh.nix            defines `sshd` (host) and `ssh-access` (user)
    hyprland.nix pipewire.nix oh-my-posh.nix zsh.nix ...
    tailscale.nix ontime.nix companion.nix   (consume modules/services/*)
    environments.nix   per-deployment aspects (`nubabe-env`, `pgTechEvent-env`)
    define-user.nix    OS + home user definition (local den.batteries.define-user)

  services/          reusable NixOS modules (flake.modules.nixos.<name>)
    tailscale.nix ontime.nix companion.nix

  users/             per-user aspects (den.aspects.nubabe, .nubabe-graphical, .root)
  hosts/             one file per host: entity declaration + host aspect
    rev3-5.nix

hardware-configuration/   nixos-facter reports, <hostname>.json per host
scripts/deploy.sh         first install via nixos-anywhere
```

## Adding a host

1. `modules/hosts/<name>.nix`:

   ```nix
   { den, ... }:
   let asp = den.aspects; in
   {
     den.hosts.x86_64-linux.<name> = {
       stateVersion = "26.05";                       # optional, default 26.05
       disk = { device = "/dev/nvme0n1"; swap = "16G"; rootSize = "64G"; home = true; };
       users.nubabe = { stateVersion = "26.05"; };   # optional, default 26.05
       users.nubabe.aspect.includes = [ asp.nubabe-graphical den.batteries.primary-user ];
     };

     den.aspects.<name>.includes = [
       asp.core asp.locale asp.boot asp.network asp.vm
       asp.nubabe-env       # deployment environment (SSH port)
       asp.sshd             # if the host runs sshd
       asp.disko
     ];
   }
   ```

2. `git add` it (flakes ignore untracked files).
3. `nix flake check` then
   `nix build .#nixosConfigurations.<name>.config.system.build.vm`.

## SSH

`sshd` (host: enable + harden) and `ssh-access` (user: add the user to
`AllowUsers` on the hosts they live on) are separate aspects. A host runs sshd
only if its aspect includes `sshd`; a user can log in only if their aspect
includes `ssh-access`. `ssh-access` on a host without `sshd` is inert.

## Deploy

```
nix build .#nixosConfigurations.<host>.config.system.build.vm   # test in a VM
sudo nixos-rebuild switch --flake .#<host>                       # existing host
./scripts/deploy.sh -a <ip> -n <host>                            # first install
```

## Formatting

```
nix fmt
```

[flake-parts]: https://github.com/hercules-ci/flake-parts
[import-tree]: https://github.com/denful/import-tree
[den]: https://github.com/denful/den
