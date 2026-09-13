{
  flake.modules.homeManager.jitoc = {pkgs, ...}: let
    jitoc = pkgs.writeShellScriptBin "jitoc" ''
      set -euo pipefail

      dry_run=false
      describe=false
      show_help=false
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -h|--help)
            show_help=true
            shift
            ;;
          -n|--dry-run)
            dry_run=true
            shift
            ;;
          -d|--describe)
            describe=true
            shift
            ;;
          *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 2
            ;;
        esac
      done

      if [[ "$show_help" == true ]]; then
        printf '%s\n' "Usage: jitoc [OPTIONS]"
        printf '%s\n' "Commit current jj working copy with an AI-generated message."
        printf '%s\n' ""
        printf '%s\n' "Options:"
        printf '%s\n' "  -d, --describe Update description instead of committing"
        printf '%s\n' "  -n, --dry-run  Generate description but do not commit or describe"
        printf '%s\n' "  -h, --help     Show this help message"
        printf '%s\n' ""
        printf '%s\n' "jj may create snapshots while inspecting working copy."
        exit 0
      fi

      diff="$(
        ${pkgs.jujutsu}/bin/jj --no-pager --color never diff --git -r @
      )"

      if [[ -z "$diff" ]]; then
        printf '%s\n' "Nothing to describe"
        exit 1
      fi

      if ! message="$(
        printf '%s\n' "$diff" | ${pkgs.opencode}/bin/opencode --log-level INFO run --command commit 2>/dev/null
      )"; then
        printf '%s\n' "Failed to generate description" >&2
        exit 1
      fi

      if [[ -z "''${message//[[:space:]]/}" ]]; then
        printf '%s\n' "Generated description is blank" >&2
        exit 1
      fi

      if [[ "$dry_run" == true ]]; then
        printf '%s\n' "$message"
        exit 0
      fi

      if [[ "$describe" == true ]]; then
        ${pkgs.jujutsu}/bin/jj describe -r @ -m "$message"
      else
        ${pkgs.jujutsu}/bin/jj commit -m "$message"
      fi
      printf '%s\n' "$message"
    '';
  in {
    home.packages = [jitoc];
  };
}
