---
name: dotfiles-structure
description: Structure guide for this Nix flake-parts dotfiles repo. Explains how flake.nix, import-tree, modules/parts/, modules/hosts/, and modules/lib/generators.nix compose NixOS, nix-darwin, and home-manager configurations, and gives step-by-step workflows for adding a host, adding a module part, adding an agenix secret, changing opencode config, and rebuilding machines. Use this skill for ANY question about this repo's layout or where a change belongs — where to add a package, program, or service; how a host is assembled; how secrets work; what the homeManager/nixos/darwin module namespaces mean — even if the user just says "where does X go?" or "add Y to my config". ALSO invoke this skill AFTER completing any change to this repo — files added, removed, or renamed under modules/, new hosts or secrets, changed aliases, hooks, generators, or workflows — and follow its Maintenance protocol to record the change in this skill.
---

# Dotfiles Repo Structure

Personal Nix system configurations ("Yokley's Dots"): one flake managing NixOS
machines, one macOS machine, and standalone home-manager hosts. Built on
**flake-parts** with **import-tree** for automatic module discovery — there is
no central import list to maintain. Dropping a file in the right directory
registers it; hosts opt in explicitly.

## How the flake assembles

`flake.nix` does three things:

1. `flake-parts.lib.mkFlake` for systems `x86_64-linux` and `aarch64-darwin`.
2. Injects `constants` and `generators` (from `modules/lib/`) into every
   module via `_module.args`, so any module can take them as arguments.
3. Auto-imports every `.nix` file under `modules/parts/` and `modules/hosts/`
   via `import-tree`. **import-tree skips any path containing `/_`** — that is
   why `_secrets/` and `ai/_bun.nix` are invisible to it.

Every module file registers itself under one of three namespaces in
`flake.modules`:

| Namespace | Meaning |
|---|---|
| `flake.modules.homeManager.*` | home-manager modules |
| `flake.modules.nixos.*` | NixOS modules |
| `flake.modules.darwin.*` | nix-darwin modules |

`modules/lib/generators.nix` composes these into full configurations:

- `mkNixosConfiguration` — `nixosSystem` with `nixos.<host>` + `nixos.common`,
  and `home-manager.users` = `mkMerge [ homeManager."yokley@<host>", homeManager.common, homeManager.nixos ]`
- `mkDarwinConfiguration` — `darwinSystem` with `darwin.<host>` +
  `darwin.common`, HM users = `mkMerge [ "yokley@<host>", common, darwin ]`
- `mkHomeConfiguration` — `homeManagerConfiguration` with
  `[ "yokley@<host>", common ]` only (no system level)

All three pass `{ inputs, username, nixvim-output, hostName }` as
specialArgs/extraSpecialArgs. `modules/hosts/base.nix` calls the generators to
register the actual flake outputs.

```
flake.nix
 ├─ import-tree ./modules/parts  → each file sets flake.modules.{homeManager,nixos,darwin}.*
 └─ import-tree ./modules/hosts  → per-host modules + base.nix (flake outputs)

generators.nix:  parts ──mkMerge──> configurations ──base.nix──> flake outputs
```

The `common` keys are baselines every host inherits; platform keys
(`homeManager.nixos`, `homeManager.darwin`) are merged only on that platform;
`"yokley@<host>"` keys are per-host.

## Directory map

### Root

| Path | Purpose |
|---|---|
| `flake.nix` | Inputs, flake-parts setup, import-tree wiring |
| `devenv.nix` / `devenv.yaml` / `.envrc` | Dev shell (direnv + devenv), pre-commit hooks config |
| `.pre-commit-config.yaml` | **GENERATED** by git-hooks.nix — never edit |
| `.github/workflows/test.yml` | CI: evaluates flake checks and configurations, builds every unique NixOS and standalone home-manager output on Linux plus the nix-darwin output on ARM macOS, and pushes builds to Horus Cachix when a write token is available; there is no separate legacy `nix-build`/`nix-shell` test job |
| `tests/krill-widget.lua` | Standalone Lua regression tests for the Noctalia Krill widget; see "Lua widget tests" |
| `tests/noctalia-global-workspaces.lua` | Standalone Lua regression tests for the Noctalia global-workspaces plugin; see "Lua widget tests" |
| `tests/powerlevel10k-jj.zsh`, `tests/powerlevel10k-jj-integration.zsh` | JJ prompt regression tests and real Powerlevel10k rendering tests, including working-copy, description, bookmark, and conflict color states |
| `devenv.lock`, `flake.lock` | Lockfiles |

### `modules/lib/`

- `constants.nix` — `defaultUsername = "yokley"`, systems map
- `generators.nix` — `mkHomeConfiguration`, `mkDarwinConfiguration`, `mkNixosConfiguration`
- `sysc-greet.nix` — re-evaluates the pinned upstream flake with unfree allowed only for `sysc-greet`; repairs its stale Go module fixed-output hash only at the affected upstream revision, shared by NixOS and devenv

### `modules/parts/` (auto-imported; each registers under `flake.modules.*`)

| Part | Namespace(s) | Purpose |
|---|---|---|
| `home.nix` | `homeManager.common` | Baseline HM for every host: nix settings, core packages (incl. nixvim), `nh`, zoxide, `home-manager-switch` alias |
| `nixos.nix` | `nixos.common` + `homeManager.nixos` | NixOS system baseline (networkmanager, pipewire, docker, fonts, user account, zsh, nix-ld) + desktop HM (hyprland, kitty, terminator); `nixos-switch`/`nixos-test` aliases |
| `darwin.nix` | `darwin.common` + `homeManager.darwin` | macOS baseline + mac HM adjustments |
| `agenix.nix` | `homeManager.common` | Imports agenix HM module, adds `ragenix` |
| `dev.nix` | `homeManager.dev` | Dev tools: age (+`init-age`/`show-age`), devenv, direnv, usql, tig, jq |
| `git.nix`, `bitwarden.nix`, `clamav.nix`, `flatpak.nix`, `shutdown.nix` | various | Single-purpose parts, names say it all |
| `syncthing.nix`, `systemd.nix` (`systemd-services`), `tailscale.nix`, `distributed_builds.nix`, `laptop.nix` | various | Services / system integration parts |
| `hyprland.nix`, `waybar/`, `rofi/`, `dunst.nix`, `picom.nix` (+ `picom.conf`), `noctalia/` | various | Window managers / desktop; Noctalia includes local bar plugins such as `krill/`, `workspace-layout/`, and `global-workspaces/` |
| `kitty.nix`, `terminator.nix`, `tmux.nix`, `vim.nix` | `homeManager.*` | Terminal / editor |
| `zsh/` (`zsh.nix`, `powerlevel10k_config.zsh`, `powerlevel10k_jj.zsh`) | `homeManager.common` | Prezto shell and Powerlevel10k prompt, with JJ status replacing Git in JJ workspaces |
| `ai/` | `homeManager.opencode`, `.fabric`, `.gitoc`, `.jitoc` | AI tooling; `jitoc.nix` generates descriptions for the current jj working copy — see "opencode config" below |
| `ai/conventional-commit-ai-prompt.md` | N/A | Emoji-free Conventional Commit prompt used by the OpenCode `commit` command, `gitoc`, and `jitoc` |
| `_secrets/` | **not imported** | agenix secrets: `secrets.nix` (definitions), `*.age` (encrypted), `syncthing/<host>/` certs+keys |

### `modules/hosts/` (auto-imported)

- `base.nix` — registers all flake outputs by calling the generators
- `<host>/<host>.nix` — defines `flake.modules.homeManager."yokley@<host>"`
  (and `flake.modules.nixos.<host>` / `darwin.<host>` where applicable);
  imports parts via `inputs.self.modules.<namespace>.<part>`
- `<host>/<host>.pub`, `<host>-root.pub` — age public keys for agenix
- extras like `mars/games.nix`, `mars/ssh.nix`, `mercury/ssh.nix`

## Host inventory

| Host | Type | Notes |
|---|---|---|
| `mars` | NixOS laptop | Default `nixosConfigurations`; AMD/amdgpu, Hyprland, VM variant for debugging |
| `mercury` | NixOS | Also holds `saturn` age keys |
| `dioxygen` | nix-darwin | aarch64 |
| `venus`, `almagest`, `jupiter`, `singularity` | home-manager only | venus & singularity use `nixvim-output = "minimal"` |
| `saturn` | syncthing identity | Keyed under `mercury/` |

## Where does a change go?

- User package/program on **every** host → `modules/parts/home.nix` (`common`)
  or a new dedicated part
- User package on **one** host → `modules/hosts/<host>/<host>.nix`
  (`home.packages`)
- System service / setting → `nixos.common` in `modules/parts/nixos.nix`, or a
  part registering `flake.modules.nixos.*`
- macOS-specific → `modules/parts/darwin.nix`
- AI/opencode tooling → `modules/parts/ai/`
- Per-host hardware/boot/kernel → `modules/hosts/<host>/<host>.nix`
  (`nixos.<host>` section)

## Workflows

### Add a module part

1. Create `modules/parts/<name>.nix` (or `<name>/<name>.nix`) registering
   e.g. `flake.modules.homeManager.<name> = { ... };`
2. Nothing else needed for it to exist — import-tree picks it up.
3. It is **not active anywhere until a host imports it**: add
   `inputs.self.modules.homeManager.<name>` to a host's imports (or to
   `home.nix`/`nixos.nix` common lists to enable it everywhere).

### Add a host

1. `mkdir modules/hosts/<name>`; create `<name>.nix` defining
   `flake.modules.homeManager."yokley@<name>"` (plus `nixos.<name>` for NixOS
   or `darwin.<name>` for macOS).
2. Add age public keys `<name>.pub` and `<name>-root.pub` in the host dir
   (required for agenix secrets).
3. Register in `modules/hosts/base.nix` with the right generator
   (`mkNixosConfiguration` / `mkDarwinConfiguration` / `mkHomeConfiguration`).
4. Add the identity to `modules/parts/_secrets/secrets.nix` and the host to
   the appropriate build matrix/job in `.github/workflows/test.yml` (and the
   evaluation loops for NixOS or standalone home-manager hosts).
5. Set `home.stateVersion` (and `system.stateVersion`) on first deploy — then
   never touch them.

### Add a secret

1. Encrypt with `ragenix`/`agenix` against the host public keys defined in
   `modules/parts/_secrets/secrets.nix`; the `.age` file lands in `_secrets/`.
2. Consume in a module: `age.secrets.<name> = { file = ...; path = ...; }` —
   see `opencode-zen` in `modules/parts/ai/opencode.nix` for a worked example.

### Rebuild / switch

- NixOS: `nixos-switch` alias →
  `nixos-rebuild switch --refresh --sudo --flake github:kyokley/dotfiles`
  (pulls from GitHub, not the local checkout) — or `nh os switch` locally.
- home-manager-only host: `home-manager-switch` → `nh home switch`
  (`nh` flake defaults to `~/dotfiles`, where the repo lives on hosts).
- macOS: `darwin-rebuild switch --flake .#dioxygen`.
- CI evaluates flake checks and configurations on PRs and pushes to main;
  only pushes to main build each distinct NixOS and standalone home-manager
  configuration on Linux and the nix-darwin system on ARM macOS. Linux jobs
  pin Ubuntu 24.04 rather than following `ubuntu-latest` migrations.
  Cachix uploads require `CACHIX_AUTH_TOKEN`; fork PRs do not receive
  repository secrets. The NixOS `default` alias shares the `mars` build output.

### Dev shell & formatting

- `direnv allow` (or `devenv shell`) — provides bun, bun2nix, sysc-greet.
- Hooks: **alejandra** formats `.nix`, ruff + ruff-format for Python,
  ripsecrets/detect-private-keys block secret commits, yamlfmt, whitespace
  checks.
- `.pre-commit-config.yaml` is generated from `devenv.nix` `git-hooks` —
  change hooks there, never in the yaml.

### Lua widget tests

Run the Noctalia widget regression tests from the repository root:

```sh
nix shell nixpkgs#lua5_4 --command lua tests/krill-widget.lua
nix shell nixpkgs#lua5_4 --command lua tests/noctalia-global-workspaces.lua
```

`tests/krill-widget.lua` loads `modules/parts/noctalia/krill/widget.luau`
with stubbed `barWidget` and `noctalia` APIs, so no desktop session or browser
is needed. It covers title/URL synchronization for repeated headlines,
history deduplication and scrolling, text toggling, fresh pushes, and linkless
headlines. The widget currently uses a Lua-compatible subset of Luau; this
test does not validate Noctalia runtime integration. Use Lua 5.4 explicitly:
the default `nixpkgs#lua` may reject the `\u{...}` escapes. These tests run
manually and are not wired into flake checks or CI.

`tests/noctalia-global-workspaces.lua` loads the deployed
`modules/parts/noctalia/global-workspaces/widget.luau` entrypoint in independent
stubbed Noctalia instances. Numbered workspaces sort by ID before ID-less
workspaces sorted by canonical address; ID-less labels use display names.
Fixtures cover legacy Hyprland `{id,name}` and newer typed workspace identities,
three-monitor snapshots, focused windows/special overlays, canonical safe selectors,
native bubble/font styling, bar-local visible-workspace expansion in both orientations
without changing focus colors, stable keys, stale callbacks, malformed snapshots,
and polling. Pill rows require API 32 for container tooltips; client snapshots
provide occupancy and urgency colors. A cancellable `runStream` listener uses
Nix-rendered `socat`/`sleep` paths; five-second polling is fallback. Async
callbacks lack bar context, so output/orientation are cached at load and each
update. Manual Lua 5.4 coverage; not CI.

### Powerlevel10k JJ tests

Run `zsh -f tests/powerlevel10k-jj.zsh` from the repository root. The test
creates isolated real JJ and Git repositories, stubs P10k rendering, and checks
prompt refresh snapshots working-copy edits while redraws use cached text.
It also checks description truncation, omission of unset descriptions without extra spacing,
and cached color state across all combinations of empty/nonempty,
described/undescribed, and bookmarked/unbookmarked working copies.
Bookmark add/remove transitions, bookmarks on only the parent, conflict color
precedence, and conflict resolution are covered.
Requires `zsh`, `jj`, and `git` on PATH.

Run the real rendering test with
`P10K_THEME=/path/to/powerlevel10k.zsh-theme zsh -f tests/powerlevel10k-jj-integration.zsh`.
Prezto bundles this theme at
`share/zsh-prezto/modules/prompt/external/powerlevel10k/powerlevel10k.zsh-theme`
inside its package. The test checks first-prompt freshness, Git fallback,
redraw caching, metadata escaping, and immediate background transitions: red
when `@` is conflicted; otherwise yellow for nonempty working copies without a
description or empty working copies with a bookmark on `@`, green otherwise.
Both suites run manually, not in CI.

### opencode config

The `opencode` module imports `gitoc` and `jitoc`. Both use its `commit`
command, backed by `conventional-commit-ai-prompt.md`, to generate emoji-free
messages; `jitoc` feeds `jj diff --git -r @` into that
command and applies the result with `jj commit` by default. Use
`jitoc -d` / `jitoc --describe` to run `jj describe -r @` instead, without
creating a new working-copy change. `jitoc --dry-run` prints the generated
description without committing or describing, including with `--describe`
(jj may still snapshot the working copy).

`modules/parts/ai/opencode.nix` — `programs.opencode` (skills, commands,
agents, settings), oh-my-opencode-slim presets, kdco notification timeout
config, zen key from the
`opencode_zen.age` secret, third-party plugin sources pinned with Nix, and node
deps built with **bun2nix** from `package.json` + `_bun.nix`. When
`package.json` changes, regenerate `_bun.nix` with `bun2nix` in the devenv
shell. OpenCode v2.0.32's local-directory plugin loader reads concrete
`server.js` and `tui.js` entry files; it does not resolve package `exports` for
local directories. The Nix-built adapter directories provide regular wrapper
files that re-export oh-my-opencode-slim 3.0.5's server and TUI entries, and
opencode-skill-creator 0.3.6's server plugin. Keep the adapters separate from
the package roots so runtime dependencies resolve through the original
Nix-built tree. The notifier is pinned to `@mohak34/opencode-notifier@1.1.0`;
`opencode-mem@2.29.0` remains an OpenCode registry plugin. The module keeps
`lsp = true` for schema compatibility, although OpenCode v2 does not run
language servers through it.
`OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true` is retained as a legacy flag;
its effect on v2 is unverified. The derivation explicitly copies the installed
`node_modules` tree; the default bun2nix install phase only emits the package
executable.

The native `opencode-mem@2.29.0` registry plugin is pinned outside the Nix-built
node tree; its declarative `opencode-mem.jsonc` reuses OpenCode's OpenAI auth
and model provider, with local memory and embeddings (the embedding model
downloads on first use). Captured context is sent to the configured provider;
the web UI binds to loopback.

The shared module exposes its platform-specific base executable as
`opencode_base_package` through `_module.args`; `programs.opencode.package`
uses the same binding. Host wrappers should execute this argument, not
`pkgs.opencode` or `config.programs.opencode.package`: the former bypasses
Linux's patch and the latter recurses when the wrapper is the configured package.
On Linux, the shared base package adds a wrapper that prefixes `LD_PRELOAD`
with Nix's `libstdc++.so.6`, preserving the existing Wayland `LD_LIBRARY_PATH`
and caller `LD_PRELOAD`. Patching Bun's compiled ELF with `DT_NEEDED` makes
`opencode --version` crash. This preloads the C++ runtime before cached native
plugins such as ONNX Runtime need it; Darwin keeps the stock package.
The Linux `homeManager.dev` package overrides ai-browser's `opencode` argument
with this same base executable, preserving ai-browser's wrapper settings while
avoiding its default `pkgs.opencode` reference. Darwin does not install ai-browser.

## Maintenance protocol (this skill self-updates)

This skill is the source of truth for repo structure, so it must evolve with
the repo. After completing ANY change to this repository, check the table
below. If the change is structure-relevant, update this file in the same
session — ideally in the same commit as the change — and tell the user you
did so. `AGENTS.md` at the repo root points every session here.

### Change → section to update

| Change made | Update in this file |
|---|---|
| File/dir added, removed, or renamed under `modules/` | Directory map tables (namespace + one-line purpose) |
| New host, or host removed/renamed | Host inventory; "Add a host" workflow if the steps changed |
| New secret or new identity in `_secrets/secrets.nix` | `_secrets/` row; "Add a secret" workflow if the flow changed |
| New flake input in `flake.nix` | Root table, or the workflow that uses it |
| `generators.nix` composition changed | "How the flake assembles" |
| devenv hooks / dev tooling changed | "Dev shell & formatting" |
| Test files or test commands added, removed, or changed | Root directory map and the relevant test workflow |
| Rebuild aliases or commands changed | "Rebuild / switch" |
| opencode / ai config layout changed | "opencode config" |
| A non-obvious behavior you had to discover the hard way | "Conventions & gotchas" — capture it so future sessions don't rediscover it |

### What NOT to record

Per-host package lists, one-off fixes, hardware quirks (they live in the host
files), or anything a table row already implies. This file loads into context
on every trigger — keep it lean.

### Drift check

Run `bash .opencode/skills/dotfiles-structure/scripts/inspect.sh` to dump the
repo's current objective facts (parts, hosts, generator registrations, flake
inputs, secrets). Wherever the output disagrees with the tables above, the
tables are stale — fix them. Use it after bulk changes or whenever accuracy
is uncertain.

## Conventions & gotchas

- Underscore prefix (`_secrets/`, `_bun.nix`) = invisible to import-tree.
- Hosts explicitly opt into parts — a new part does nothing until imported.
- `stateVersion` comments say "Don't touch me!" — obey.
- `nixvim-output` (`"default"` | `"minimal"`) selects the neovim package from
  the `kyokley/nixvim` fork input.
- Kitty's Zsh integration is patched in `kitty.nix` to use `preexec` argument
  `$2`; Zsh permits Kitty's upstream `$1` history text to be empty. Prezto's
  bundled Powerlevel10k is also patched in `zsh.nix` to include its saved
  command in the later OSC 133 marker; upstream emits an empty marker that
  leaves `%c` blank in command-finish notifications.
- The repo is expected at `~/dotfiles` on hosts (`nh` default).
- GitHub-hosted `macos-15` is arm64 for this public repository; `macos-15-arm`
  is not a valid runner label and leaves the Darwin CI job queued indefinitely.
- Add custom Nix caches with `nix.settings.extra-substituters` and
  `extra-trusted-public-keys`, as Dioxygen does for Horus. Home Manager's
  user-level `substituters` and `trusted-public-keys` replace system settings;
  a Horus-only list hides `cache.nixos.org` and causes unnecessary source builds.
  Check the effective configuration with `nix config show substituters`.
- `sysc-greet` exports a package from its own `nixpkgs.legacyPackages`; system
  and Home Manager unfree settings do not apply. `modules/lib/sysc-greet.nix`
  re-evaluates each pinned input with only `sysc-greet` allowed, for NixOS and
  devenv; keep each consumer's lock pin unchanged.
- At `fc406221767da5557bace80e455db6312aac44bd`, upstream `sysc-greet` has no
  vendored source tree and its fixed-output Go dependency hash is stale after
  the `sysc-Go` module update. The shared adapter replaces only that revision's
  `packages.default` vendor hash; regenerate it from the build's hash mismatch,
  rather than changing Go vendoring behavior or lock pins.
- Remote builders are not automatically substituters. Mars explicitly queries
  Mercury's existing store over `ssh-ng` in `modules/hosts/mars/mars.nix` with
  priority 50, below the default public cache. `trusted=true` accepts Mercury's unsigned
  outputs over authenticated SSH without disabling signature checks for other
  caches. This reuses the daemon's root SSH identity and the system SSH settings
  for `bangup.dyndns.org:10101`; `mars/ssh.nix` sets a 10-second SSH connection
  and initial-handshake timeout, not a DNS or total substitution timeout.
  Mercury needs no additional cache service. Only paths still present
  in Mercury's store can be reused; remote garbage collection can remove them.
- Powerlevel10k builds segments before `p10k-on-pre-prompt` runs. The JJ
  segment uses deferred variable references so this hook's refreshed text
  appears immediately. Three fixed-color segments use mutually exclusive deferred
  conditions so background changes also appear immediately: red when `@` is
  conflicted; otherwise yellow when JJ's working copy is nonempty and has no
  description, or is empty with a bookmark on `@`; green otherwise.
  Bookmarks on parents do not affect the color.
  It snapshots the working copy once per prompt refresh
  so status reflects file edits; redraws use cached text. JJ is omitted from
  instant prompt; the serialized hook guards against an unavailable helper.
- Nix-managed OpenCode plugins resolve imports from their canonical Nix store
  path, not the Home Manager symlink path. Bundle each plugin with a sibling
  `node_modules` link when it has runtime dependencies.
- `modules/parts/hyprland.nix` uses nixpkgs `pkgs.hyprmoncfg` directly for the
  system package and `hyprmoncfgd`. Its Lua-mode default generated file is
  `monitors.lua`; the module keeps a mutable file with a
  `-- Generated by hyprmoncfg` header and loads it with a literal absolute
  `dofile` path. Activation preserves arbitrary existing files, initializes
  absent or empty files, and backs up only the exact known 1.9.x retirement
  stub before restoring the old ownership header.
- The shared NixOS Hyprland module selects 64-bit and 32-bit Mesa from
  Hyprland's pinned nixpkgs package set. Hyprland dynamically loads Mesa, so
  their glibc must match. Keeping the source pin avoids incompatible Hyprland
  toolkit dependencies; update Hyprland and Mesa pins together for driver
  updates. The module asserts both graphics package selection and ABI match.
- Noctalia must follow system `nixpkgs`: it dynamically loads host PAM libraries,
  so an independent older glibc can fail the system PAM ABI. Unlike Hyprland and
  Mesa, do not preserve an independent older libc pin for Noctalia.
- Noctalia 5.2.1 applies declarative `radius` to row backgrounds, not buttons.
  Rounded Flex backgrounds do not clip children; wrappers must accommodate
  native button corner geometry and padding.
- Hyprland 0.56.0 workspace JSON uses `{id,name}`, without `address` or `type`.
  The global-workspaces plugin adapts both legacy and typed identities; keep
  both schemas covered when changing snapshot validation.
- Noctalia notification filters resolve the first match in name order.
  `match_content` is a case-insensitive ECMAScript regex searched against the
  title OR body separately; it cannot require both fields to match. Omit
  `match` to filter content regardless of the sending app.
- An unversioned OpenCode plugin name can load a stale `@latest` cache instead
  of the version pinned in `ai/package.json`. OpenCode v2.0.32's local-directory
  plugin loader does not honor package exports: configure Nix-built adapter
  directories containing real `server.js` and, when needed, `tui.js` files.
  Re-export source package entries from those wrappers; do not configure an npm
  package root or a direct compiled file as a local directory plugin.
- `gitoc` and `jitoc` use `config.programs.opencode.package`, not
  `pkgs.opencode`, so package overrides also apply to commit generation.
  Their baked-in store paths do not follow the shell's `opencode` executable.
  `jitoc` preserves OpenCode stderr so generation failures remain visible.
- This skill self-maintains: after any structure-relevant change, follow the
  Maintenance protocol above. `AGENTS.md` at the repo root reminds every
  session of this duty.
