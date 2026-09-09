---
name: check
description: Format and evaluate the flake. Runs `nix fmt` then `nix flake check --no-build`. Use after making changes to Nix files, or when asked to "check" / "verify" the config.
---

Run, from the repo root, in order:

1. `git add -A -- ':!result'` — new `.nix` files are invisible to the flake until tracked.
2. `nix fmt` — treefmt: nixfmt (format) + statix (anti-patterns) + deadnix (dead code). statix and deadnix **rewrite** files.
3. `nix flake check --no-build` — evaluate every flake output and NixOS configuration.

Report:

- Whether formatting/lint changed any files (name them). If deadnix removed a
  function arg that is actually needed, flag it.
- The result of `nix flake check`. If it fails, quote the shortest decisive error
  line and the file it points to. Common causes: an undeclared host/user attribute
  (`STRICT MODE` — declare it via `den.schema.{host,user}.imports`), or a `.nix`
  file that was never `git add`-ed.

Do not build (`system.build.vm` / `toplevel`) unless the user asks — this skill is
eval-only. Do not commit.
