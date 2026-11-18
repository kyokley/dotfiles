# Tangled CI

These workflows follow the [Spindle workflow guide](https://tangled.org/docs/spindles/writing-workflows/)
and mirror the Linux checks in `.github/workflows/test.yml`:

- `workflows/test.yml` checks the flake and evaluates the same NixOS and
  Home Manager configurations on all pull requests and pushes to `main`.
- `workflows/build-linux.yml` builds all seven Linux configurations on pushes
  to `main`. A single `nix build --keep-going` attempts independent builds even
  when another fails; Tangled has no job matrix. Evaluation and builds run as
  separate workflows, without a dependency between them.
- Both workflows read the public Horus Cachix cache. Linux builds also upload
  new store paths when `CACHIX_AUTH_TOKEN` is available; builds work without it.

## Setup

1. In the Tangled repository's **Settings → Pipelines**, select a spindle with
   the `microvm` engine and an x86_64 Linux `nixos` image.
2. Confirm the spindle's workflow timeout allows these builds. The default is
   five minutes, including queue time; GitHub allows 15 minutes for evaluation
   and 360 minutes for each build. Tangled has no per-workflow timeout field.
3. Optionally add `CACHIX_AUTH_TOKEN` under **Settings → Pipelines → Secrets**
   with write access to Horus. Tangled exposes repository secrets to every step
   of every trusted workflow, including same-repository pull requests; the
   push-only build trigger is not a secret-access boundary. Fork, patch, and
   collaborator-approved pull request runs receive no secrets.
4. Push the workflow files and inspect **Pipelines**. The knot reports workflow
   validation errors during push; local YAML checks alone do not validate a
   spindle run.
