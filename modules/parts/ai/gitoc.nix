{
  flake.modules.homeManager.gitoc = {
    config,
    pkgs,
    ...
  }: let
    gitoc = pkgs.writeShellScriptBin "gitoc" ''
      # Parse command line arguments
      add_all=false
      dry_run=false
      while [[ $# -gt 0 ]]; do
          case $1 in
              -a|--all)
                  add_all=true
                  shift
                  ;;
              -h|--help)
                  show_help=true
                  shift
                  ;;
              -n|--dry-run)
                  dry_run=true
                  shift
                  ;;
              *)
                  shift
                  ;;
          esac
      done

      # Show help if requested
      if [[ "$show_help" == true ]]; then
          echo "Usage: gitoc [OPTIONS]"
          echo "Automatically commit changes with AI-generated commit messages."
          echo ""
          echo "Options:"
          echo "  -a, --all      Run 'git add' before committing (adds all changes)"
          echo "  -n, --dry-run  Generate commit message but do not run 'git commit'"
          echo "  -h, --help     Show this help message"
          echo ""
          echo "If no changes are staged, the script will exit."
          exit 0
      fi

      # Run git add if --all flag is provided
      if [[ "$add_all" == true ]]; then
          git add .
      fi

      # Exit immediately if there are no staged changes
      if [[ ! $(git diff --cached --name-only) ]]; then
          echo "Nothing to commit"
          exit 1
      fi

      prompt="Generate only the commit message. Do not run tools or modify the repository.
      $(< ${./commands/conventional-commit-ai-prompt.md})"

      if ! message="$(set -o pipefail; git diff --staged | ${config.programs.opencode.package}/bin/opencode --log-level info run --title "gitoc generator" "$prompt")"; then
          printf '%s\n' "Failed to generate commit message" >&2
          exit 1
      fi

      if [[ -z "''${message//[[:space:]]/}" ]]; then
          printf '%s\n' "Generated commit message is blank" >&2
          exit 1
      fi

      subject_pattern='^[a-z][a-z0-9]*(\([^()]+\))*!?: .+'
      if [[ ! "$message" =~ $subject_pattern ]]; then
          printf '%s\n' "Generated commit message must start with a Conventional Commit subject" >&2
          exit 1
      fi

      if [[ "$dry_run" != true ]]; then
          echo
          echo "$message"
          echo
          echo
          git commit -m "$message"
      else
          echo -e "\033[33mDry run: No changes will be made. Commit message would be:\033[0m"
          printf '%s\n' "$message"
      fi
    '';
  in {
    home = {
      packages = [
        gitoc
      ];
    };
  };
}
