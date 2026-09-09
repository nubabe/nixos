---
name: aspect-tree
description: Render an ASCII tree of every den aspect and how it is wired onto each host/user. Use for "aspect tree", "how are aspects wired", "map the config", "what aspects exist".
---

Produce a single ASCII tree showing every `den.aspects.<name>` and the path by
which it reaches a host or user. Eval-only — never build, never commit.

## 1. Gather

```
git ls-files 'modules/**/*.nix' 'modules/*.nix'
```

Read every match. Also read `flake.nix` (confirm `import-tree ./modules`) and
`.claude/den-reference.md` §4–5 for `provides` / auto-attach semantics if unsure.

`import-tree` skips any path with a segment starting with `_` (e.g.
`modules/aspects/_define-user.nix` is **not loaded** — call it out as dead).

## 2. Extract, per file

- Every `den.aspects.<name>` — its class keys (`nixos`, `homeManager`, `os`,
  `user`, `packages`, …), its `includes = [ … ]`, its `provides.*`.
- `imports = [ inputs.self.modules.nixos.<x> ]` inside an aspect → mark `⇒ <x>`.
- `den.default.includes` / `den.default.<class>` contributions (any file — the
  list is merged; today: `den.nix`, `pkgs.nix`, `state-version.nix`,
  `home-manager.nix`).
- `den.schema.host/user.imports` that add options (e.g. `disk`, `stateVersion`).
- `den.hosts.<sys>.<name>` entities: their schema attrs, their
  `users.<u>.aspect.includes`, any inline `nixos`/`os`.
- `flake.modules.nixos.<x>` definitions in `modules/services/` and the option
  namespace they add.

## 3. Resolve wiring

An aspect reaches an entity by one of:

1. **Global** — listed in `den.default.includes` (every host + user).
2. **Auto-attach** — an aspect whose name equals a host or user name attaches to
   that entity with no explicit include (e.g. `den.aspects.rev3-5` → host
   `rev3-5`).
3. **Explicit `includes`** — walk the chain from each entity / entity-aspect.
4. **`provides.to-users`** (on a host aspect) / **`provides.<name>`** — the
   non-default directions: host→user, or targeting one specifically-named entity.

Once an aspect is included at a scope, **every class it declares routes to that
class's owner**: `nixos`/`os` from a user aspect reach the user's host through
the normal user→host OS flow; `homeManager`/`user` stay on the user. The reverse
(host aspect's `homeManager` → users) is *not* automatic — that needs
`provides.to-users` / a policy / the `host-aspects` battery.

An aspect matching none of these is **defined but not wired** — list it separately.

## 4. Verify the non-obvious (optional, cheap)

Spot-check cross-scope hops with `nix eval` on
`.#nixosConfigurations.<host>.config…`, e.g. a user aspect's `nixos` key landing
on the host (`config.<opt>`), a `provides.to-users` key landing on a user
(`config.home-manager.users.<u>.…`), or an auto-attached host aspect actually
applying. Don't eval the whole toplevel.

## 5. Render

One fenced code block. Start with this legend, then a `GLOBAL` section, then one
block per host (host entity attrs → entity-named aspect's includes → each user
and its include chain, indented), then `DEFINED BUT NOT WIRED`, then `REUSABLE
MODULES`.

```
LEGEND  [nixos]/[hm]/[os] = class emitted   ·file = defined in
        ⇒ = imports a flake.modules.nixos.*   →host/→users = provides direction
        🔋 = den.batteries.*
```

Per aspect line: `name   [class]   one-line what-it-does   ·file`. Nest
`includes` and `provides.*` children under their parent. Keep each aspect to one
line; put any `provides.*` children under a `provides.*` sub-node.

After the block, add 2–4 sentences: the attachment routes in play for this repo,
and anything surprising (camelCase aspect names, unwired service aspects, skipped
`_` files, aspects reaching a scope you wouldn't expect).

End by offering to save it to `README.md` or `docs/aspects.md`. Do not save
unless asked.
