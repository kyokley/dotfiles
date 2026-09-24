# Refresh this once per prompt. Rendering must only use this cached text.
typeset -g _dotfiles_jj_text=
typeset -g _dotfiles_jj_warning=

function _dotfiles_jj_update() {
  emulate -L zsh
  setopt no_aliases

  typeset -g _dotfiles_jj_text=
  typeset -g _dotfiles_jj_warning=
  (( $+commands[jj] )) || { (( $+functions[p10k] )) && p10k display '*/vcs'=show; return 0; }

  local directory=${PWD:A} found=
  while true; do
    # A colocated repo has both markers; .jj takes precedence.
    [[ -d $directory/.jj ]] && { found=1; break; }
    # Do not leak an enclosing JJ repo into a nested Git worktree.
    [[ -d $directory/.git || -f $directory/.git ]] && break
    [[ $directory == / ]] && break
    directory=${directory:h}
  done
  [[ -n $found ]] || { (( $+functions[p10k] )) && p10k display '*/vcs'=show; return 0; }

  # Based on https://github.com/jj-vcs/jj/wiki/Starship.
  # Read live working-copy snapshots once per prompt. Redraws use cached text.
  local template='
if(conflict, "red|", if((!empty && !description) || (empty && bookmarks.len() > 0), "yellow|", "green|")) ++ separate(" ",
  change_id.shortest(4),
  bookmarks.map(|x| truncate_end(10, x.name(), "…")).join(" "),
  tags.map(|x| "#" ++ truncate_end(10, x.name(), "…")).join(" "),
  truncate_end(29, description.first_line(), "…"),
  surround("[", "]", separate(",",
    if(conflict, "conflict"),
    if(divergent, "divergent"),
    if(hidden, "hidden"),
    if(immutable, "immutable"),
    if(empty, "empty"))))
'
  local output
  output=$(command jj log -r @ --limit 1 --no-graph --color never --no-pager \
    --template "$template" 2>/dev/null) || { (( $+functions[p10k] )) && p10k display '*/vcs'=show; return 0; }
  local warning
  case $output in
    red\|*)
      warning=2
      output=${output#red\|}
      ;;
    green\|*)
      warning=0
      output=${output#green\|}
      ;;
    yellow\|*)
      warning=1
      output=${output#yellow\|}
      ;;
    *)
      (( $+functions[p10k] )) && p10k display '*/vcs'=show
      return 0
      ;;
  esac
  [[ -n $output ]] || { (( $+functions[p10k] )) && p10k display '*/vcs'=show; return 0; }

  # Make control bytes visible and prevent prompt expansion of JJ metadata.
  output=${(V)output}
  typeset -g _dotfiles_jj_text=${output//\%/%%}
  typeset -g _dotfiles_jj_warning=$warning
  (( $+functions[p10k] )) && p10k display '*/vcs'=hide
}

# P10k serializes this hook for instant prompt, before this helper may exist.
function p10k-on-pre-prompt() {
  (( $+functions[_dotfiles_jj_update] )) || return 0
  _dotfiles_jj_update
}

function prompt_jj() {
  p10k segment -b 1 -f 0 -i jj -c '${_dotfiles_jj_text:+${(M)_dotfiles_jj_warning:#2}}' -e -t '${_dotfiles_jj_text}'
  p10k segment -b 2 -f 0 -i jj -c '${_dotfiles_jj_text:+${(M)_dotfiles_jj_warning:#0}}' -e -t '${_dotfiles_jj_text}'
  p10k segment -b 3 -f 0 -i jj -c '${_dotfiles_jj_text:+${(M)_dotfiles_jj_warning:#1}}' -e -t '${_dotfiles_jj_text}'
}
