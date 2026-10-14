# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [den](https://github.com/denful/den)-based NixOS flake (`flake-parts` + `import-tree`).
One host today (`rev3-5`). `README.md` has the layout and the "add a host" recipe.
`.claude/den-reference.md` is the den consumer API reference — read it before
touching `den.aspects` / `den.hosts` / `den.schema` / `provides` / policies.

## Commands

- Format + lint: `nix fmt` (treefmt: nixfmt, statix, deadnix). Runs automatically
  after every `.nix` edit via a `PostToolUse` hook. `deadnix` **rewrites** files —
  it strips unused `let` bindings and function args, so a `{ pkgs, lib, ... }:`
  header loses `lib` the moment you save without using it. Add the arg back when
  you actually need it.
- Check: `nix flake check --no-build` (or the `/check` skill, which formats first).
- Build / smoke-test a host: `nix build .#nixosConfigurations.<host>.config.system.build.vm`
  — use the VM build, **not** `nixos-rebuild`, to verify changes.
- A real toplevel build (`.config.system.build.toplevel`) needs a non-empty
  `hardware-configuration/<host>.json` (nixos-facter). The `facter` aspect
  (`modules/aspects/facter.nix`, global via `den.default.includes`) sets
  `hardware.facter.reportPath` only when that file has real content, so VM
  builds work with an empty/absent report.

## Gotchas

- `import-tree` auto-loads **every** `.nix` under `modules/` — never add manual
  `imports` lists for them. But a new `.nix` file is invisible to Nix until it is
  `git add`-ed (flakes only see tracked files). `git add` new modules before
  running any `nix` command.
- Host and user schemas are **strict**: setting an undeclared attribute on a
  `den.hosts.<…>` entity or a user throws `STRICT MODE`. Declare new metadata
  with `den.schema.host.imports = [ ({ lib, ... }: { options.<name> = lib.mkOption {…}; }) ]`
  (see `modules/aspects/state-version.nix`, `modules/aspects/disko.nix`).

## Conventions

- Aspect names are flat: `nubabe-env`, `ssh-access` — no `"path/like"` string keys.
- Trivial single-class aspects use the attr-path form
  (`den.aspects.foo.nixos.services.bar.enable = true`); anything with `includes`,
  `provides`, or multiple classes uses the block form (`den.aspects.foo = { … }`).
- A self-contained NixOS module that could stand alone lives in `modules/services/`
  as `flake.modules.nixos.<name>` (options + generic behaviour); the matching
  aspect in `modules/aspects/` does `imports = [ inputs.self.modules.nixos.<name> ]`
  and sets the actual values. See `tailscale`.
- Desktop/WM is a **user** trait: the `hyprland` aspect is included by a user
  aspect. Its `nixos` bits (compositor + greeter) reach the host through the
  normal user→host OS flow; its `homeManager` bits land on the user.
- SSH is two aspects: `sshd` (host: enable + harden) and `ssh-access` (user: adds
  the user to `AllowUsers`). A host runs sshd only if it includes `sshd`.

## Workflow

- Everything is on `main` for now (a `dev` branch and feature branches come later).
- Do not commit unless asked.
