# Docker and devenv migration

This example comes from a MediaConverter migration. Its commands are
project-specific, not defaults for other repositories. Both GitHub jobs ran on
pull requests without branch restrictions and were independent.

```yaml
# .tangled/workflows/pr.yml
workflows:
  test:
    when:
      - event: pull_request
        branch: "**"
    engine: microvm
    image: nixos
    dependencies:
      - gnumake
      - docker-compose
    virtualisation:
      docker: true
    steps:
      - name: Run tests
        command: make ci-tests
  format-checks:
    when:
      - event: pull_request
        branch: "**"
    engine: microvm
    image: nixos
    dependencies:
      - devenv
    substituters:
      https://devenv.cachix.org: devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    steps:
      - name: Build the devenv shell and run any pre-commit hooks
        command: devenv test
```

The cache's public key was obtained from
https://cachix.org/api/v1/cache/devenv. Recheck authoritative metadata when
adapting the example.

## The failure to avoid

Current reference documentation allowed an omitted pull-request branch, but the
user's deployed spindle warned:

```text
test: invalid configuration: when[0] listens for pull_request without branch and won't match any ref
format-checks: invalid configuration: when[0] listens for pull_request without branch and won't match any ref
```

The correction added `branch: "**"` to both conditions. This kept all target
branches eligible, including names with slashes, without adding a new branch
restriction.

## Evidence and limits

- `COMPOSE_PROJECT_NAME=mediaconverter-tangled-ci make ci-tests` exited 0;
  238 tests passed.
- `devenv test` exited 0.
- Test-created Compose containers and network were removed without deleting
  volumes.
- These results established local command success, not successful execution on
  Tangled. The session did not establish that the remote accepted the corrected
  configuration or that the target spindle could execute the microVM workflows.

The reusable lesson is to preserve behavior, account for deployed versions, and
report the validation boundary. The specific engine, cache, package names, and
commands must still fit the next repository.
