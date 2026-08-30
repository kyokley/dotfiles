#!/usr/bin/env bash
# Drift check for the dotfiles-structure skill.
#
# Dumps the repo's current objective structure facts. Compare against the
# tables in ../SKILL.md — wherever the output disagrees, SKILL.md is stale
# and must be updated (see the Maintenance protocol there).
#
# Mirrors import-tree's visibility rules: paths containing "/_" are skipped,
# node_modules is skipped. Run from anywhere.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$REPO_ROOT"

echo "=== modules/parts (import-tree visible) ==="
find modules/parts -name node_modules -prune -o -path '*/_*' -prune -o -type f -print | sort

echo
echo "=== modules/hosts ==="
find modules/hosts -type f | sort

echo
echo "=== base.nix generator registrations ==="
grep -nE 'mk(Nixos|Darwin|Home)Configuration|hostName =|nixvim-output =' modules/hosts/base.nix

echo
echo "=== flake.nix inputs ==="
grep -n 'url = ' flake.nix

echo
echo "=== _secrets (names only, never print contents) ==="
find modules/parts/_secrets -type f | sort
