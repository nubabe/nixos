# Den Usage Reference (agent-facing)

A working reference for **using Den in a project** — a NixOS / nix-darwin / home-manager
configuration that consumes `github:denful/den` as an input. Read this when helping with a repo
that has `den.aspects`, `den.hosts`, `den.policies`, etc. in it.

> This file is portable: copy it into any Den-consuming project's `.claude/`.
> It describes Den's *consumer API*, not Den's internals.
> Canonical docs: <https://den.denful.dev> · templates: `nix flake init -t github:denful/den#<name>`

---

## 1. Mental model

Den turns Nix config into **aspects** (features) instead of per-host module files.

- **Entity** — a typed data record: a `host`, a `user`, or a standalone `home`. Declares *what exists*.
- **Aspect** — an attrset bundling modules for several **classes** (`nixos`, `darwin`,
  `homeManager`, `hjem`, `maid`, `os`, `user`, `packages`, or custom) under one concern. Declares
  *what it does*. An aspect can be a plain attrset or a **function of context** (`{ host, user }: …`).
- **Class** — a Nix module-evaluation domain. An aspect key matching a class emits a module into it.
- **Policy** — a function `context → [effects]` that wires entities together (fan-out, context
  enrichment, content routing). Declares *how entities relate*.
- **Quirk** — a named channel for structured data many aspects contribute and one consumes,
  without referencing each other.
- **Context** — the pipeline argument (`{ host }`, `{ host, user }`, `{ home }`, …). A real function
  arg, **not** `_module.args` / `specialArgs`. Evaluated before the module system, so it can drive
  conditionals without infinite recursion. The *shape of the context is the condition* — a
  `{ host, user }:` function simply doesn't run where there's no user. No `mkIf`/`enable` needed.

Flow: `den.hosts`/`den.homes` → resolve each entity's aspect through the pipeline → per-class
modules → `flake.nixosConfigurations` / `darwinConfigurations` / `homeConfigurations` (+ `packages`
etc.).

---

## 2. Project setup

Den auto-loads every `.nix` file under `modules/` via [import-tree](https://github.com/denful/import-tree)
(files/dirs starting with `_` are ignored). You never list imports manually.

Typical project layout:

```
flake.nix            (or default.nix for the no-flakes style)
modules/
  den.nix            # imports den.flakeModule, declares den.hosts / den.homes, den.default, den.schema
  <host>.nix         # den.aspects.<host> = { … }
  <user>.nix         # den.aspects.<user> = { … }
  <feature>.nix      # shared den.aspects.<feature>, den.quirks, den.policies …
  _nixos/            # (optional) plain NixOS modules imported by an aspect; NOT auto-loaded
```

### Style A — flakes + flake-parts (recommended; template `default`)

```nix
# flake.nix
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
  inputs = {
    den.url = "github:denful/den";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  };
}
```

```nix
# modules/den.nix
{ inputs, ... }: {
  imports = [ (inputs.den.flakeModules.dendritic or {}) ];
}
```

### Style B — flakes only, no flake-parts (template `minimal`)

```nix
# any module file
{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ];
  # den.hosts / den.aspects / …
}
```

`flake.nix` runs `(inputs.nixpkgs.lib.evalModules { modules = [ (inputs.import-tree ./modules) ]; specialArgs.inputs = inputs; }).config.flake`.

### Style C — no flakes (template `noflake`)

`npins` + `with-inputs` + `lib.evalModules`; read `.config.flake`. Modules are byte-identical to the
flake styles — only the entry point differs.

### Adopting Den into an existing flake

Evaluate Den's modules and splice `<entity>.mainModule` into your existing `nixosSystem`/`darwinSystem`:

```nix
outputs = inputs:
let
  den = (inputs.nixpkgs.lib.evalModules {
    modules = [ (inputs.import-tree ./modules) ]
      ++ inputs.nixpkgs.lib.optional (inputs ? flake-parts) inputs.den.flakeOutputs.flake;
    specialArgs.inputs = inputs;
  }).config;
in {
  nixosConfigurations.igloo = inputs.nixpkgs.lib.nixosSystem {
    modules = [ ./your/existing/modules  den.den.hosts.x86_64-linux.igloo.mainModule ];
  };
}
```

Later, once everything is in `modules/`, collapse `flake.nix` to `… .config.flake` and
`inherit (den.flake) nixosConfigurations darwinConfigurations;`.

### Inputs needed by batteries (add only what you use)

`home-manager`, `hjem`, `nix-maid`, `nixos-wsl`, `microvm`, `nix-darwin`. Home integrations also need
at least one user with the matching class (§7).

---

## 3. Declaring entities — `den.hosts`, `den.homes`, `den.schema`

### Hosts & users

```nix
{
  den.hosts.x86_64-linux.igloo = {
    users.tux = {};                              # user "tux"
    users.root.classes = [ "homeManager" ];      # opt this user into home-manager
    gpu = "nvidia";                              # freeform metadata, readable as host.gpu in aspects
  };
  den.hosts.aarch64-darwin.mac.users.alice = {};
}
```

- Keyed `den.hosts.<system>.<name>`. `class` auto-detected: `*-linux` → `nixos`, `*-darwin` → `darwin`
  (override `class = "darwin";`).
- **Flat form:** drop the system level, put `system` inside — `den.hosts.igloo = { system = "x86_64-linux"; … };`.
- Host options: `name`, `hostName` (default `name`), `system`, `class`, `aspect` (default
  `den.aspects.<name>`), `users`, `instantiate`, `intoAttr`, `collisionPolicy`, plus anything from
  `den.schema.host`, plus freeform.
- User options: `name`, `userName` (default `name`), `classes` (default `[ "user" ]`), `aspect`,
  `host`, `collisionPolicy`, plus `den.schema.user`, plus freeform.

### Standalone homes

```nix
{
  den.homes.x86_64-linux.tux = {};              # homeConfigurations.tux
  den.homes.x86_64-linux."tux@igloo" = {};      # homeConfigurations."tux@igloo", bound to host igloo
}
```

`user@host` binds the home to a host's user (the `home-manager` CLI auto-selects it from
`whoami`/`hostname`); `igloo` need not be a Den-managed host. A bare key is unbound. Configure via
the aspect named after the user (`den.aspects.tux`). Host-specific bits go under `provides.<host>`.

### `den.schema` — options/config shared by every entity of a kind

Not aspects — metadata that aspects read.

```nix
{
  den.schema.conf.options.copyright = lib.mkOption { default = "Copy-Left"; };  # host+user+home
  den.schema.host = { host, lib, ... }: {
    options.hardened = lib.mkEnableOption "secure host";
    config.hardened  = lib.mkDefault true;
  };
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];   # HM default for all users
  den.schema.host.includes = [ den.policies.host-to-peers ];   # activate a policy for every host
}
```

Sidecar keys on a schema entry (stripped before merge): `includes`, `excludes`, `collisionPolicy`,
`parent`, `isEntity`, `isolated`. Adding a *new* key to `den.schema` registers a new entity kind.

**Strict mode:** `imports = [ inputs.den.flakeModules.strict ];` — undeclared entity attrs throw.

---

## 4. Aspects — `den.aspects`

Den auto-creates `den.aspects.<name>` for each host/user/home with empty owned-config keys for its
classes. You extend those, from any file. Declare `den.aspects.<feature>` for shared features.

```nix
den.aspects.workstation = {
  # owned configs — one Nix module per class (attrset or `{ config, pkgs, lib, ... }:` fn)
  nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.git ]; };
  darwin.nix-homebrew.enable = true;
  homeManager.programs.starship.enable = true;

  # dependency graph (DAG)
  includes = [
    den.aspects.dev-tools
    den.aspects.gaming.emulation      # a nested aspect
    den.batteries.primary-user
    { nixos.services.xserver.enable = true; }          # inline static
    ({ host, ... }: { nixos.time.timeZone = "UTC"; })  # inline parametric
  ];

  # named sub-aspects, referenced as den.aspects.workstation.<sub>  (`_` is an alias for `provides`)
  provides.emulation = { nixos = { /* ... */ }; };
};
```

### Structural keys

| Key | Meaning |
|---|---|
| `<class>` | config merged into that class |
| `includes` | list of aspects / sub-aspects / functions to pull in |
| `excludes` | aspects/policies suppressed in this subtree (authoritative — children can't re-enable) |
| `provides` / `_` | sub-aspect namespace |
| `policies` | inline policy registry (activate by listing in `includes`) |
| `meta` | `handleWith` (constraints), `collisionPolicy`, `guard`/`aspects` (conditional), freeform |
| `classes` | class schemas this aspect adds to `den.classes` |
| `name`, `description` | strings |

To give an aspect its own `options` / `imports`, write it as a function so `imports` isn't read as a
class key: `den.aspects.foo = { config, lib, ... }: { imports = [ … ]; … };`. Aspects are
fixed-point — `config` inside that function *is* the aspect.

Keep custom metadata keys out of class dispatch entirely: `den.reservedKeys = [ "settings" "tags" ];`.

### `den.default`

Aspect applied to every host, user, and home:

```nix
den.default = {
  nixos.system.stateVersion = "25.11";
  homeManager.home.stateVersion = "25.11";
  includes = [ den.batteries.define-user den.batteries.inputs' ];
};
```

Owned configs dedupe across stages; parametric includes run at every stage and dispatch by arg shape.

### Context-aware (parametric) aspects — the binding rule

A function requesting an entity-kind arg (`host`/`user`/`home`/custom):

1. **Kind is in the current scope's context** → binds, emits once here.
2. **Kind is a schema descendant of this scope** (e.g. `{ user, … }:` included at *host* scope) →
   fans out once per matching descendant, emitting **class-locally at this scope** (this is how a
   host aspect produces per-user content).
3. **Neither** → **silently inert**. No error, no warning. Any entity arg at flake/root scope, or a
   misplaced arg, produces nothing.

**If a parametric aspect "isn't applying", check case 3 first.** Cross-*sibling* delivery (host →
another host, user → sibling user) is **not** expressible with a context arg — use `provides` or a
policy.

Prefer **named** aspects over inline anonymous functions in `includes` (better traces/diagrams).
Aspect-level context functions take only the args they name — `...` optional and normally omitted.

### Flat-form class modules (context inside a class module)

```nix
den.aspects.laptop = {
  # context args + module-system args together — MUST include `...`
  nixos = { host, config, pkgs, ... }: { networking.hostName = host.name; };

  # this one only applies where `user` exists; at host scope it's skipped (with a lib.warn), not an error
  homeManager = { user, config, ... }: { home.username = user.userName; };
};
```

- Wrapper pre-applies context args present in scope, hides them from the module system.
- **Missing `...`** in flat form → eval error (module system passes extra args).
- **Full application** (every arg is a context arg, `{ host }: { config, ... }: …`) — Den calls it
  directly; no `...` needed.
- **Collision** (Den injects `host` but `specialArgs`/`_module.args` also defines it) → throws by
  default. Set `collisionPolicy` = `"error"` | `"den-wins"` | `"class-wins"` at
  `meta.collisionPolicy` / entity `.collisionPolicy` / `den.schema.<kind>.collisionPolicy` /
  `den.config.classModuleCollisionPolicy` (first non-null wins; global default `"error"`).

---

## 5. Cross-entity config (`provides`) & mutual providers

Cross-entity routing is **built into the pipeline** — no battery needed
(`den.batteries.mutual-provider` is an inert shim).

| Key | On | Delivers to |
|---|---|---|
| `provides.<name>` | any aspect | the host/user named `<name>` (fires only when it's in scope, so a plain attrset is fine) |
| `provides.to-users` | a host aspect | every user on that host (`{ user, ... }:` to select per-user) |
| `provides.to-hosts` | a user aspect | every host the user lives on (`{ host, ... }:` to select) |

```nix
den.aspects.igloo = {
  provides.to-users.homeManager = { pkgs, ... }: { home.packages = [ pkgs.vim ]; };
  provides.alice.homeManager.programs.tmux.enable = true;       # only alice
};
den.aspects.tux = {
  provides.to-hosts = { host, ... }: { nixos.programs.nh.enable = host.name == "igloo"; };
  provides.igloo.nixos.programs.emacs.enable = true;            # only on igloo
};
```

**Gotcha:** a `provides` on a *user* aspect reaches that user + its hosts, **never sibling users**.
To touch several users, register the `provides` on the **host** aspect (its subtree spans all users).

For new code, `den.policies` + `policy.include` is the more explicit alternative; `provides` is a
permanent supported API.

---

## 6. Policies — `den.policies`

A policy is `context → [effects]`, fired when its args are satisfied. **Registering ≠ activating** —
it fires only when listed in an `includes`:

```nix
den.policies.my-policy = { host, ... }: [ (den.lib.policy.resolve { flag = true; }) ];

den.default.includes        = [ den.policies.my-policy ];  # all entities
den.schema.host.includes    = [ den.policies.my-policy ];  # all hosts
den.aspects.igloo.includes  = [ den.policies.my-policy ];  # igloo subtree only
```

Activation cascades to descendant scopes. `excludes` deactivates (authoritative downward).

### Effects (`den.lib.policy.*`)

| Effect | Use |
|---|---|
| `resolve bindings` | non-entity keys → **enrich** current scope (no new scope); entity keys → **child scope** + resolve that entity |
| `resolve.to kind bindings` / `.shared` / `.withIncludes` | fan-out variants |
| `include aspect` | inject an aspect that walks the tree (dedup, parametric dispatch, constraints) |
| `provide { class; module; path?; }` | deliver a module straight to a class, bypassing the tree |
| `route { fromClass; intoClass; path; guard?; adaptArgs?; collectSubtree?; }` | move a class/quirk bucket into a target class at a path |
| `deliver { from; to; at; mode; }` | the primitive under `route`/`provide`; `mode` = `merge`\|`nest`\|`verbatim` |
| `exclude aspect` | tombstone an aspect |
| `instantiate entityOrSpec` | request post-pipeline instantiation (custom builders / non-entity outputs) |
| `spawn { classes?; }` | deferred node spawn over the full fleet scope-tree |
| `pipe.*` | quirk routing (§8) |
| `mkPolicy name fn` | build a named policy record for inline use in `includes` |

### Combinators

- `policy.for entity policyOrList` — fire only when a specific entity is in context.
- `policy.when predicate policyOrList` — fire only when a context predicate holds.
- `policy.when` / `.for` over an **inline aspect** (not a registered policy) instead compiles a
  **conditional aspect** whose guard is checked structurally against the in-flight tree — this is
  what makes `host.hasAspect den.aspects.git` safe inside a guard.

### Built-in policies you'll rely on (already active)

`host-to-users` (fan-out); `flake-to-systems`, `system-to-os-outputs`, `system-to-hm-outputs`
(+ instantiate), `packages/apps/checks/devShells/legacyPackages-to-flake`; `os-to-host`,
`user-to-host`, `host-to-hm-users` (+ `hjem`/`maid`), `host-to-wsl-host`. `den.default` is injected
as schema includes for host/user/home.

### Examples

```nix
# 1. Derive per-host flags via enrichment
den.policies.host-guards = { host, ... }:
  [ (den.lib.policy.resolve { isNixos = host.class == "nixos"; isDarwin = host.class == "darwin"; }) ];
den.schema.host.includes = [ den.policies.host-guards ];

# 2. Conditionally activate a policy
den.schema.host.includes = [
  (den.lib.policy.when ({ host, ... }: host.wsl.enable) den.policies.wsl-support)
];

# 3. Inject config only where a structural guard passes
den.aspects.igloo.includes = [
  (den.lib.policy.when ({ host, ... }: host.hasAspect den.aspects.git) {
    nixos.environment.variables.GIT_ENABLED = "true";
  })
];
```

---

## 7. Home environments

Classes: `homeManager`, `hjem`, `maid` (all opt-in), plus `user` (built-in OS user env, always on).

```nix
den.hosts.x86_64-linux.igloo.users.tux.classes = [ "homeManager" "hjem" ];
den.schema.user.classes = lib.mkDefault [ "homeManager" ];   # default for all users

den.aspects.tux.homeManager = { pkgs, ... }: {
  home.packages = [ pkgs.htop ];
  programs.git.enable = true;
};
```

Integration activates automatically when ≥1 user has the class. It imports the OS module (needs the
matching input: `home-manager` / `hjem` / `nix-maid`) and forwards each user's `<class>` content
into `home-manager.users.<name>` / `hjem.users.<name>` / `users.users.<name>.maid`.

- Per-host HM module override: `den.hosts.<s>.<n>.home-manager.module = inputs.hm-unstable.nixosModules.home-manager;`
- `maid` requires host `class = "nixos"`.
- A user can be in several environments at once.
- Inside a user's HM config, the host config is available as the `osConfig` module arg.
- **Gotcha:** a host-scope `{ user, ... }:` aspect's `homeManager` content does **not** reach users
  (it emits class-locally on the host, where `homeManager` is inert). Use `provides.to-users`, a
  policy, or `den.batteries.host-aspects`.

---

## 8. Quirks & pipes — `den.quirks`

Decoupled many-producers → one-consumer data flow.

```nix
# 1. declare
den.quirks.firewall = { description = "firewall ports"; };   # description required; must not equal a class name

# 2. produce (any aspect)
den.aspects.nginx.firewall    = { ports = [ 80 443 ]; };
den.aspects.postgres.firewall = { ports = [ 5432 ]; };

# 3. consume (name the quirk in a class-module arg)
den.aspects.networking.nixos = { firewall, lib, ... }: {
  networking.firewall.allowedTCPPorts = lib.concatMap (f: f.ports or []) firewall;
};
```

- Consumer arg is a list of all scope-local values (`[]` if none). Delivered like context args.
- **List values auto-flatten** — a producer emitting `[a b]` yields two pool entries.
- **Include order doesn't matter** — consumers are deferred until all producers + pipes resolve.
- Value can be `{ config, ... }: …` (config-dependent thunk): local ones resolve lazily inside
  `evalModules`; cross-host ones (via `pipe.collect`) resolve eagerly against the source host's
  config (must be a DAG).

### Pipe stages (`den.lib.policy.pipe`, inside a policy)

`pipe.from name [ stages ]`. Transform: `filter pred`, `transform fn`, `fold fn init`
(→ `[result]`), `append v`, `for fn` (replace whole list; ≤1 per pipe/scope). Routing:
`expose` (child → parent), `collect pred` (sibling scopes), `collectAll pred` (any scope),
`broadcast pred` (push to every matching scope), `as "otherQuirk"` (derived quirk / rename),
`to [ aspects ]` (only those aspects), `withProvenance` (entries → `{ value; source; }`).

```nix
# Cross-host: every host sees the whole fleet's backends
den.policies.fleet-backends = { host, ... }:
  let inherit (den.lib.policy) pipe; in
  [ (pipe.from "http-backends" [ (pipe.collect ({ host, ... }: true)) ]) ];
den.schema.host.includes = [ den.policies.fleet-backends ];
```

---

## 9. Batteries — `den.batteries` (= `den.provides` = `den._`)

**Opt-in** = list in an `includes`. **Auto** = fires via a built-in policy.

| Battery | Kind | Effect |
|---|---|---|
| `define-user` | opt-in | `users.users.<n>` (isNormalUser + home dir) + HM `home.username`/`homeDirectory` |
| `hostname` | opt-in | system hostname from `host.hostName` |
| `primary-user` | opt-in | admin user: nixos `wheel`+`networkmanager`; darwin `system.primaryUser`; wsl `defaultUser` |
| `user-shell "fish"` | opt-in (arg) | login shell at OS + HM |
| `tty-autologin "u"` / `vm-autologin "u"` | opt-in (arg) | systemd getty autologin (NixOS / NixOS VM) |
| `unfree [ "steam" ]` / `insecure [ "openssl-1.1.1w" ]` | opt-in (arg) | allow packages; any class; predicate builder auto-in-`den.default` |
| `host-aspects` | opt-in | project host aspect's `homeManager` keys onto opting-in users |
| `flake-scope` | opt-in | expose `lib`/`inputs`/`den` to pipeline/parametric fns (non-flake-parts) |
| `inputs'` / `self'` | opt-in | flake-parts only; system-preselected `inputs'`/`self'` as module args |
| `import-tree ./dir` | opt-in | recursively import plain `.nix`; class from `_nixos/`,`_darwin/`,`_homeManager/` dir names; `.provides.host` / `.provides.user` variants |
| `forward { … }` | opt-in | build a custom class (§10) |
| `os-class` | auto | `os` class → both `nixos` and `darwin` |
| `os-user` | auto | `user` class → `users.users.<userName>` at OS level |
| `home-manager` / `hjem` / `maid` | auto (when a user has the class) | import OS module + forward per user |
| `wsl` | auto (when `host.wsl.enable`) | adds `wsl-host` kind, forwards `wsl` class into host NixOS; needs `inputs.nixos-wsl` |
| `mutual-provider` | inert shim | does nothing |

```nix
den.default.includes = [ den.batteries.define-user den.batteries.hostname den.batteries.inputs' ];
den.aspects.alice.includes = [
  den.batteries.primary-user
  (den.batteries.user-shell "zsh")
  (den.batteries.unfree [ "vscode" ])
  { nixos.security.sudo.wheelNeedsPassword = false; }
];
den.schema.user.includes = [ den.batteries.define-user ];
```

The `os` class (write once, applies to nixos + darwin) and the `user` class (write into it instead
of `nixos.users.users.<name>`) are auto-enabled:

```nix
den.aspects.my-host.os.networking.hostName = "yavanna";
den.aspects.alice.user = { pkgs, ... }: { packages = [ pkgs.hello ]; extraGroups = [ "wheel" ]; };
```

---

## 10. Custom classes

Forward a class's content into a target submodule path on another class.

```nix
# A `container` class -> virtualisation.oci-containers.containers.<user>
den.schema.user.includes = [ ({ host, user }: den.batteries.forward {
  each       = lib.singleton user;
  fromClass  = _: "container";
  intoClass  = _: host.class;
  intoPath   = _: [ "virtualisation" "oci-containers" "containers" user.userName ];
  fromAspect = _: den.aspects.${user.aspect};
  # guard = { options, ... }: options ? virtualisation.oci-containers;   # only when target has the option
  # adaptArgs = args: { osConfig = args.config; };
}) ];

den.aspects.alice.container = { image = "nginx:latest"; ports = [ "8080:80" ]; };
```

- `each`: items to fan over (often `[ user ]` or `[ true ]`). Other params are `item: …` functions.
- Guard: `{ options, ... }: options ? path` tests **option presence**;
  `{ config, ... }: _: lib.mkIf config.programs.vim.enable` tests a **config value**.

Lower-level (`den.classes` + `route`), used for flake-parts perSystem integration:

```nix
den.classes.devshell = { };
den.policies.devshell-to-flake-parts = _: [
  (den.lib.policy.route {
    fromClass = "devshell"; intoClass = "flake-parts"; path = [ "devshells" "default" ];
    adaptArgs = { config, ... }: config.allModuleArgs;
  })
];
den.schema.flake-parts.includes = [ den.policies.devshell-to-flake-parts ];
```

`den.classes.<name>` fields: `description`, `forwardTo { class; path?; }`, `parentPath`
(`name → attrpath` for nested classes), `parentArg` (module arg for the enclosing owner, e.g.
`"osConfig"`).

---

## 11. Namespaces (sharing aspects across flakes)

```nix
# modules/namespace.nix
{ inputs, ... }: {
  imports = [
    (inputs.den.namespace "my" false)                     # local library, not exported
    (inputs.den.namespace "eg" true)                       # + export as flake.denful.eg
    (inputs.den.namespace "shared" [ inputs.team true ])   # merge upstream flake.denful.shared, and re-export
  ];
}
```

Creates `den.ful.<name>` + a module-arg alias `<name>`. Populate/consume via that arg:

```nix
{ eg, ... }: {
  eg.vim.homeManager.programs.vim.enable = true;
  den.aspects.laptop.includes = [ eg.vim ];   # or <eg/vim> with angle brackets
}
```

---

## 12. Angle brackets (optional sugar)

Enable once: `_module.args.__findFile = den.lib.__findFile;`. Then add `__findFile` to a module's
args and use `<…>`:

| Form | Resolves to |
|---|---|
| `<den/primary-user>` | `den.batteries.primary-user` |
| `<den.lib.foo>` | `config.den.lib.foo` |
| `<laptop>` | `den.aspects.laptop` |
| `<tools/editors>` | `den.aspects.tools.editors` |
| `<eg/desktop>` | `den.ful.eg.desktop` (namespace) |

Functionally identical to attribute access.

---

## 13. Flake outputs beyond configs (`packages`, `apps`, `checks`, `devShells`, …)

Aspects can contribute to per-system flake outputs via same-named classes.

```nix
# modules/outputs.nix — only needed without flake-parts when >1 definition
{ inputs, ... }: { imports = [ inputs.den.flakeOutputs.packages ]; }

# any aspect
den.aspects.tools.packages = { pkgs, ... }: { inherit (pkgs) hello ripgrep; };
den.schema.flake-system.includes = [ den.aspects.tools ];   # include the aspect in output resolution
```

Host/user aspects producing `packages` fan out per host automatically.

- `den.systems` — list of systems the flake walks (default: union of `den.hosts`/`den.homes` system
  keys, else `lib.systems.flakeExposed`).
- Per host/home: `intoAttr` (output path; `[ ]` = don't emit), `instantiate` (builder override,
  e.g. pin nixpkgs).

### `nh` build wrappers — `nix run .#<hostname>`

```nix
# flake-parts
perSystem = { pkgs, ... }: { packages = den.lib.nh.denPackages { fromFlake = true; } pkgs; };
```

```console
nix run .#igloo              # default action "build"
nix run .#igloo -- switch --dry
```

Also `den.lib.nh.denShell` / `denApps` / `hostApps` / `homeApps`. Args: `fromFlake`, `fromPath`,
`outPrefix`, `defaultAction`, `defaultArgs`.

### VM test loop (from the `default` template)

```nix
packages.vm = pkgs.writeShellApplication {
  name = "vm";
  text = "${inputs.self.nixosConfigurations.igloo.config.system.build.vm}/bin/run-igloo-vm \"$@\"";
};
```
`nix run .#vm` — edit config, launch VM, no reboot.

---

## 14. Structural introspection (`hasAspect`) & constraints

Read "is aspect X in this entity's tree?":

```nix
den.aspects.impermanence.nixos = { host, lib, ... }: lib.mkMerge [
  (lib.mkIf (host.hasAspect den.aspects.zfs-root)   { /* zfs flavor  */ })
  (lib.mkIf (host.hasAspect den.aspects.btrfs-root) { /* btrfs flavor */ })
];
```

Variants: `host.hasAspect.forClass "nixos" ref`, `.forAnyClass ref`; list all nodes with
`host.aspects` (each has `.identity`, `.name`, `.meta`, `.includes`, `.isNamed`).

- Membership is **structural**, **scoped to the entity** (own scope + descendants; siblings don't
  leak), **exclude-aware**.
- **Safe** only in class-module bodies and policy guards. **NEVER in an `includes` list** →
  infinite recursion (the tree depends on every `includes`).

Write structure — `meta.handleWith` with `den.lib.aspects.fx.constraints`:

```nix
den.aspects.secrets-bundle = {
  includes = [ den.aspects.agenix-rekey den.aspects.workstation-role ];
  meta.handleWith = den.lib.aspects.fx.constraints.exclude den.aspects.sops-nix;   # never resolves below this
};
```

`exclude ref` / `substitute ref replacement` / `filterBy predicate`; each has a `.global` variant
(default is subtree-scoped). `excludes` (the structural key) is shorthand for `exclude` and also
matches policies by name.

---

## 15. Common gotchas

- **Parametric silent-inert** — an entity-kind arg that's neither in-context nor a schema descendant
  of the include scope contributes nothing, silently. Any entity arg at flake/root scope is inert.
- **Cross-sibling delivery isn't parametric** — host → another host, user → sibling user: use
  `provides` (on the parent) or a policy.
- **`provides` on a user aspect never reaches sibling users** — put it on the host aspect.
- **`hasAspect` in an `includes` list = infinite recursion.** Class-module bodies and policy guards
  only. Use constraints for structural decisions.
- **Flat-form class modules need `...`** (except full-application form).
- **Unsatisfied entity arg in a class module → silent skip** (with `lib.warn`), not an error. If a
  class module "isn't applying", check its entity args are all in scope there.
- **Host-scope `{ user, ... }:` `homeManager` content does not reach users** — emits on the host
  (inert). Use `provides.to-users` / policy / `host-aspects`.
- **Quirk name must not equal a class name** (asserted). **Quirk list values auto-flatten.**
- **Cross-host config thunks must form a DAG.**
- **Darwin hosts have `class = "darwin"`** — check `host.class` when darwin config is missing.
- **New `.nix` files must be `git add`'d** before Nix evaluates them (flakes only see tracked files).
- **`den.ctx` and `den.batteries.mutual-provider`** are deprecated/inert shims. `den.lib.perHost` /
  `perUser` / `perHome` / `take.exactly` / `parametric` are deprecated — write bare parametric
  functions.
- **`excludes` is authoritative downward** — a child cannot re-include what a parent excluded.
- **`den.default` parametric includes run at every stage** — a `{ host }:` fn only in host scope, a
  `{ host, user }:` fn only in user scope; owned configs dedupe.
- **Enrichment cycle** — if policies keep adding new context keys, `den: enrichment cycle` after 10
  rounds.

---

## 16. Inspecting a Den config (REPL & debugging)

```console
nix repl
nix-repl> :lf .
nix-repl> nixosConfigurations.igloo.config.networking.hostName
```

Expose Den for inspection (remove after):

```nix
{ den, ... }: { flake.den = den; }
```
```
nix-repl> den.aspects.igloo
nix-repl> den.hosts.x86_64-linux.igloo
nix-repl> den.policies
nix-repl> den.lib.policyInspect.inspect { kind = "host"; context = { host = den.hosts.x86_64-linux.igloo; }; }
```

Trace context during eval (remove before commit):

```nix
den.aspects.laptop.includes = [
  ({ host, ... }@ctx: builtins.trace ctx { nixos.networking.hostName = host.hostName; })
];
```

Resolved entity module (for building): `den.hosts.x86_64-linux.igloo.mainModule`.

Build:

```console
nixos-rebuild build --flake .#igloo          # or  nix run .#igloo   (nh wrapper)
darwin-rebuild build --flake .#mac
home-manager build --flake .#"tux@igloo"
nix flake check
```

---

## 17. Testing your own config (`denTest`)

If the project has `templates/ci`-style tests or `flake.tests`, they use the `denTest` helper.
Test files export `flake.tests.<suite>.<test-name>`:

```nix
{ denTest, lib, ... }:
{
  flake.tests.my-suite.test-hostname = denTest (
    { den, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo.users.tux = { };
      den.aspects.igloo.nixos.networking.hostName = "test";

      expr = igloo.networking.hostName;
      expected = "test";
    }
  );
}
```

- Args: `den`, `igloo` (`nixosConfigurations.igloo.config`), `iceberg`, `apple`
  (`darwinConfigurations.apple.config`), `tuxHm` (`igloo.home-manager.users.tux`), `pinguHm`,
  `ns` (namespace, when imported), `trace`, plus `config`, `inputs`, `lib`.
- Partial match: if `expr` and `expected` are both attrsets, only `expected`'s keys are compared.
- Error assertion: `expectedError = { type = "ThrownError"; msg = "…"; }`
  (types: `ThrownError`, `AssertionError`, `EvalError`, `TypeError`, `MissingArgumentError`,
  `RestrictedPathError`, `UndefinedVarError`, `Abort`, `ParseError`).
- Multi-file simulation: `imports = [ { … } { … } ]` (a single file can't repeat a key).
- Run with nix-unit: `nix-unit --flake .#tests.<suite>` (or the project's `just ci` if present).

---

## 18. Further reading (den.denful.dev)

| Topic | Page |
|---|---|
| Concepts | `/explanation/core-principles/`, `/explanation/aspects/`, `/explanation/policies/`, `/explanation/quirks-and-pipes/` |
| Parametric binding rule | `/explanation/parametric/` |
| Class modules (flat form) | `/explanation/class-modules/` |
| Getting started | `/guides/from-zero-to-den/`, `/guides/from-flake-to-den/` |
| Hosts / homes / schema | `/guides/declare-hosts/`, `/reference/schema/` |
| Home envs | `/guides/home-manager/` |
| Batteries | `/reference/batteries/` |
| Custom classes | `/guides/custom-classes/` |
| Namespaces | `/guides/namespaces/` |
| Mutual providers | `/guides/mutual/` |
| Policies / quirks reference | `/reference/policies/`, `/reference/quirks/` |
| Fleets / multi-host | `/explanation/fleet/` |
| Flake outputs | `/reference/output/` |
| Templates | `/tutorials/overview/` · `nix flake init -t github:denful/den#<name>` |
