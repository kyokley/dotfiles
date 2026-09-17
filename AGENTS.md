# dotfiles

Nix flake-parts dotfiles: NixOS + nix-darwin + standalone home-manager hosts.

- For anything about repo layout or where a change belongs, consult the
  `dotfiles-structure` skill.
- Before deciding where to apply a change, check the current hostname and
  user to identify the target machine and configuration.
- After completing any change to this repo, follow the Maintenance protocol
  in `.opencode/skills/dotfiles-structure/SKILL.md` and record
  structure-relevant changes there — same session, ideally same commit.
- Create incremental commits as you make changes. Keep each commit focused
  on a coherent, validated change rather than collecting unrelated work.
- Before committing, identify the project's VCS: use `jj root` to check for
  a Jujutsu workspace; otherwise check with `git rev-parse --show-toplevel`.
  Prefer Jujutsu in colocated repositories where both are present.
- For Jujutsu, create each commit with `jj commit -m "<message>"`, not just
  `jj describe`. For Git, stage only the intended changes and use
  `git commit -m "<message>"`.
- Always include a commit message summarizing the most significant changes.
  Review the status and diff first; never include unrelated changes or secrets.
- Immediately before each commit, display the full, exact commit message in
  a user-visible message. Do not rely only on tool calls or command output.
