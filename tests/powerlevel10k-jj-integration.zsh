#!/usr/bin/env zsh -f

emulate -LR zsh
setopt err_return

repo_root=${0:A:h:h}
helper=$repo_root/modules/parts/zsh/powerlevel10k_jj.zsh
theme=${1:-${P10K_THEME:-}}
[[ -n $theme && -r $theme ]] || {
  print -u2 "usage: P10K_THEME=/path/to/powerlevel10k.zsh-theme $0 [theme-path]"
  exit 77
}

real_jj=${commands[jj]:-}
[[ -x $real_jj ]] || { print -u2 'jj is required'; exit 77; }
test_root=$(mktemp -d "${TMPDIR:-/tmp}/powerlevel10k-jj-integration.XXXXXX")
trap 'rm -rf "$test_root"' EXIT
export HOME=$test_root/home XDG_CONFIG_HOME=$test_root/config JJ_CONFIG=$test_root/jj-config.toml
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=$test_root/gitconfig JJ_REAL=$real_jj JJ_CALLS=$test_root/jj-calls
mkdir -p $HOME $XDG_CONFIG_HOME $test_root/bin $test_root/plain
cat >$JJ_CONFIG <<'EOF'
[user]
name = "Powerlevel10k test"
email = "p10k@example.test"
EOF
git config --global init.defaultBranch main
git config --global user.name 'Powerlevel10k test'
git config --global user.email p10k@example.test
cat >$test_root/bin/jj <<'EOF'
#!/bin/sh
printf x >>"$JJ_CALLS"
if [ "${JJ_FAIL:-}" = 1 ]; then exit 1; fi
exec "$JJ_REAL" "$@"
EOF
chmod +x $test_root/bin/jj
PATH=$test_root/bin:$PATH
rehash

function fail() { print -u2 "FAIL: $*"; exit 1; }
function assert_contains() { [[ $1 == *$2* ]] || fail "[$1] lacks [$2]"; }
function assert_not_contains() { [[ $1 != *$2* ]] || fail "[$1] contains [$2]"; }
function assert_eq() { [[ $1 == $2 ]] || fail "expected [$2], got [$1]"; }
function calls() { print -r -- ${#$(<$JJ_CALLS)}; }
function reset_calls() { : >$JJ_CALLS; }
green_background=$(print -P -- '%K{2}')
yellow_background=$(print -P -- '%K{3}')

source $helper
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(jj vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
source $theme

git init -q $test_root/repo
git -C $test_root/repo commit --allow-empty -qm initial
git -C $test_root/repo branch -M git-visible
jj --quiet git init --colocate $test_root/repo >/dev/null
git init -q $test_root/git-only
git -C $test_root/git-only commit --allow-empty -qm initial
git -C $test_root/git-only branch -M git-visible-only
cd $test_root/repo
jj --quiet describe -m 'first description' >/dev/null

# P10k builds prompt_jj before this hook. Deferred -c/-e content must still render now.
reset_calls
_p9k_precmd
first=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $first 'first description'
assert_not_contains $first git-visible
assert_contains $first $green_background
assert_not_contains $first $yellow_background

jj --quiet describe -m 'refreshed description' >/dev/null
reset_calls
_p9k_precmd
refreshed=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $refreshed 'refreshed description'
assert_not_contains $refreshed 'first description'
assert_contains $refreshed $green_background
assert_not_contains $refreshed $yellow_background

# A redraw expands cached text only; it never starts another JJ process.
print -rP -- "$PROMPT" >/dev/null
assert_eq "$(calls)" 1

jj --quiet describe -m '$(>PWNED) `>PWNED2` %F{red}' >/dev/null
reset_calls
_p9k_precmd
hostile=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $hostile '$('
assert_contains $hostile '`>PWNED2`'
assert_contains $hostile '%F{red}'
[[ ! -e PWNED && ! -e PWNED2 ]] || fail 'rendered JJ metadata executed a command'

# Leaving JJ restores Git VCS rendering.
cd $test_root/git-only
reset_calls
_p9k_precmd
git_only=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 0
assert_not_contains $git_only 'refreshed description'
assert_not_contains $git_only PWNED
assert_contains $git_only git-visible-only

# A failed JJ query restores the colocated Git VCS segment.
cd $test_root/repo
export JJ_FAIL=1
reset_calls
_p9k_precmd
failed=$(print -rP -- "$PROMPT")
unset JJ_FAIL
assert_eq "$(calls)" 1
assert_not_contains $failed 'refreshed description'
assert_not_contains $failed PWNED
assert_contains $failed git-visible

# File edits keep described working copies green on the very next prompt.
print unsnapshotted >unsnapshotted
reset_calls
_p9k_precmd
nonempty_described=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $nonempty_described $green_background
assert_not_contains $nonempty_described $yellow_background

# Clearing a nonempty working-copy description turns the prompt yellow immediately.
jj --quiet describe -m '' >/dev/null
reset_calls
_p9k_precmd
nonempty_undescribed=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $nonempty_undescribed $yellow_background
assert_not_contains $nonempty_undescribed $green_background

# Describing it again turns the prompt green immediately, regardless of description text.
jj --quiet describe -m 'empty| hostile description' >/dev/null
reset_calls
_p9k_precmd
hostile_marker=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $hostile_marker $green_background
assert_not_contains $hostile_marker $yellow_background

# New empty, undescribed working copies remain green.
jj --quiet new -m '' >/dev/null
reset_calls
_p9k_precmd
empty_again=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $empty_again $green_background
assert_not_contains $empty_again $yellow_background

# Describing an empty working copy remains green.
jj --quiet describe -m 'empty description' >/dev/null
reset_calls
_p9k_precmd
empty_described=$(print -rP -- "$PROMPT")
assert_eq "$(calls)" 1
assert_contains $empty_described $green_background
assert_not_contains $empty_described $yellow_background

print 'powerlevel10k-jj-integration: ok'
