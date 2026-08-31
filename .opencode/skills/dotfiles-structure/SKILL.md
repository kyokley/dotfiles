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
| `.github/workflows/test.yml` | CI: evaluates flake checks plus every NixOS and standalone home-manager config on PR / push to main |
| `devenv.lock`, `flake.lock` | Lockfiles |

### `modules/lib/`

- `constants.nix` — `defaultUsername = "yokley"`, systems map
- `generators.nix` — `mkHomeConfiguration`, `mkDarwinConfiguration`, `mkNixosConfiguration`

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
| `hyprland.nix`, `qtile/`, `waybar/`, `rofi/`, `dunst.nix`, `picom.nix` (+ `picom.conf`), `noctalia/` | various | Window managers / desktop |
| `kitty.nix`, `terminator.nix`, `tmux.nix`, `vim.nix`, `zsh/` (zsh.nix + powerlevel10k config) | `homeManager.*` | Terminal / editor / shell |
| `ai/` | `homeManager.opencode`, `.fabric`, `.gitoc` | AI tooling — see "opencode config" below |
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
   the CI matrix in `.github/workflows/test.yml`.
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
- CI evaluates every NixOS and standalone home-manager config on PR/push to
  main — a green check means configurations evaluate, not that their complete
  system closures build.

### Dev shell & formatting

- `direnv allow` (or `devenv shell`) — provides bun, bun2nix, sysc-greet.
- Hooks: **alejandra** formats `.nix`, ruff + ruff-format for Python,
  ripsecrets/detect-private-keys block secret commits, yamlfmt, whitespace
  checks.
- `.pre-commit-config.yaml` is generated from `devenv.nix` `git-hooks` —
  change hooks there, never in the yaml.

### opencode config

`modules/parts/ai/opencode.nix` — `programs.opencode` (skills, commands,
agents, settings), oh-my-opencode-slim presets, kdco notification timeout
config, zen key from the
`opencode_zen.age` secret, third-party plugin sources pinned with Nix, and node
deps built with **bun2nix** from `package.json` + `_bun.nix`. When
`package.json` changes, regenerate `_bun.nix` with `bun2nix` in the devenv
shell. Its derivation explicitly copies the installed `node_modules` tree;
the default bun2nix install phase only emits the package executable.

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
- Nix-managed OpenCode plugins resolve imports from their canonical Nix store
  path, not the Home Manager symlink path. Bundle each plugin with a sibling
  `node_modules` link when it has runtime dependencies.
- This skill self-maintains: after any structure-relevant change, follow the
  Maintenance protocol above. `AGENTS.md` at the repo root reminds every
  session of this duty.
