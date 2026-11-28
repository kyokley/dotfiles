---
name: tangled-workflows
description: >
  Create, migrate, review, and troubleshoot Tangled spindle workflow configurations.
  Use whenever work involves .tangled/workflows, converting GitHub Actions to
  Tangled pipelines, choosing Tangled engines, or fixing spindle configuration
  warnings, especially pull_request branch matching. Preserve existing CI behavior
  and distinguish local validation from actual spindle execution. Do not use for
  GitHub Actions-only changes or unrelated YAML.
---

# Tangled Workflows

## Establish the contract

1. Read repository instructions, existing CI, and every command the affected
   workflows call. Inspect Makefiles, container files, dependency locks, and
   development-environment definitions as relevant.
2. Identify triggers, branch/tag filters, independent jobs, dependencies between
   jobs, working directories, services, artifacts, caches, and secrets.
3. Preserve the user's intended behavior rather than translating syntax alone.
   Do not invent branch restrictions, drop required services, or serialize
   independent checks accidentally.
4. Check current official documentation:
   - https://tangled.org/docs/spindles/workflows/
   - https://tangled.org/docs/spindles/engines/
5. Treat warnings from the actual target spindle as evidence about its deployed
   version. Documentation may describe capabilities that spindle does not have.

## Choose a compatible engine

Select the least complex engine that satisfies the workload and is available on
the target spindle. Do not assume every spindle supports every engine or image.

| Engine | Appropriate workloads | Configuration and boundaries |
| --- | --- | --- |
| `nixery` | Stateless commands that need packaged tools | `dependencies` maps registries to package lists. Each step gets a fresh container; only the workspace persists. Do not assume a Docker daemon or general service management. |
| `microvm` | Docker/Compose, persistent services, or state across steps | Use an available image. NixOS images support a flat package list, `services`, `virtualisation`, `registry`, and `substituters`. These configuration fields do not configure non-NixOS images. |
| `namespace` | A user's configured Namespace workspace | Requires workspace configuration and federation trust. Do not fabricate workspace IDs or provision external access silently. |

For Docker-based checks on a NixOS microVM, enable
`virtualisation: {docker: true}` and supply required client tools, such as
`gnumake` and `docker-compose`, rather than assuming Ubuntu runner defaults.
Docker socket access and Compose behavior still need runtime verification.

If available engines cannot satisfy the workload, explain the mismatch and ask
before changing the test strategy or introducing external infrastructure.

## Translate the workflow

- Put files under `.tangled/workflows/` at the repository root.
- For several independent checks, use separate files or a single top-level
  `workflows` map. Each named entry is a complete workflow with its own trigger,
  engine, and steps. Do not mix `workflows` with other top-level fields.
- Keep workflow names unique across files and named entries.
- Translate `run` into step `command`. Preserve command semantics and required
  environment variables; review GitHub expressions and action behavior manually.
- Rely on Tangled's automatic checkout unless explicit clone options are needed.
  Remove GitHub checkout and Nix-installer actions only when the selected engine
  provides their required behavior.
- Preserve actual job dependencies and artifact transfer requirements. Independent
  workflows are not a replacement for a job dependency graph. Check current
  capabilities before translating dependent jobs.
- Do not put secrets in committed YAML. Preserve trust boundaries and identify
  any required repository/operator setup without performing it implicitly.
- Remove the old workflow only when replacement is intended. Keep parallel CI
  when the user requests coexistence. Update repository guidance when required.

### Explicit pull-request branch matching

Always include a target-branch matcher on `pull_request` conditions for
compatibility with spindles that reject an omitted branch. Preserve existing
restrictions; when the source workflow accepts every target branch, use:

```yaml
when:
  - event: pull_request
    branch: "**"
```

`**` includes branch names containing `/`. Do not replace it with `main` or `*`
when all branches are intended. Quote the glob so YAML does not parse an alias.
Apply this to every affected workflow, not only the first.

Preserve event action filters. Current documentation defaults pull requests to
`opened`, `reopened`, and `synchronize`. Pull-request checkout uses the source
commit, which differs from GitHub's usual synthetic merge checkout; flag that
semantic difference when integration against the target branch matters.

### Nix and caches

On NixOS microVMs, install tools through the flat `dependencies` list when
appropriate. For example, `devenv` can replace a separate Nix/profile installation
sequence while keeping `devenv test` unchanged.

Preserve relevant public binary caches through the documented `substituters`
URL-to-public-key mapping. Obtain signing keys from the cache's authoritative
metadata; never guess a key or copy credentials. Binary substituters, directory
caches, and secret-backed cache publishing are different mechanisms.

## Verify proportionately

1. Inspect the final diff for preserved triggers, commands, job independence,
   services, cache behavior, and unintended changes.
2. Parse YAML and use an installed, version-appropriate Tangled validator if one
   exists. Do not invent a validator command. YAML parsing alone does not prove
   the spindle accepts the configuration.
3. Run the affected repository checks and required formatting checks. Follow
   repository instructions; avoid unrelated full suites unless required.
4. Isolate local Compose validation from existing services with a unique project
   name. Clean up only resources created for the check. Do not remove volumes or
   stop unrelated containers.
5. Distinguish local command success, configuration acceptance, and successful
   remote execution. Each establishes a different claim.
6. Do not commit, push, trigger remote runs, or change spindle settings unless the
   user authorizes those actions.

The documented workflow timeout defaults to five minutes and includes waiting
for a slot. The operator controls it. Cold Docker or Nix builds may need more;
report this requirement instead of inventing an unsupported YAML timeout field.

Report changed paths, exact check commands and exit statuses, and remaining
runtime uncertainty. Never call the migration fully verified without spindle
evidence.

## Session-derived reference

Read `references/migration-example.md` for a concrete Docker/devenv migration and
the deployed-spindle branch warning that motivated explicit matchers.
`evals/evals.json` contains three review scenarios; their presence does not mean
they have been executed.
