#!/usr/bin/env zsh -f

emulate -LR zsh
setopt err_return

repo_root=${0:A:h:h}
helper=$repo_root/modules/parts/zsh/powerlevel10k_jj.zsh
real_jj=${commands[jj]:-}
[[ -x $real_jj ]] || { print -u2 'jj is required'; exit 77; }

test_root=$(mktemp -d "${TMPDIR:-/tmp}/powerlevel10k-jj.XXXXXX")
trap 'rm -rf "$test_root"' EXIT
export HOME=$test_root/home XDG_CONFIG_HOME=$test_root/config JJ_CONFIG=$test_root/jj-config.toml
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=$test_root/gitconfig
mkdir -p $HOME $XDG_CONFIG_HOME $test_root/bin $test_root/empty-bin
cat >$JJ_CONFIG <<'EOF'
[user]
name = "Powerlevel10k test"
email = "p10k@example.test"
EOF
git config --global init.defaultBranch main
export JJ_REAL=$real_jj JJ_CALLS=$test_root/jj-calls

cat >$test_root/bin/jj <<'EOF'
#!/bin/sh
printf x >>"$JJ_CALLS"
if [ "${JJ_FAIL:-}" = 1 ]; then exit 1; fi
exec "$JJ_REAL" "$@"
EOF
chmod +x $test_root/bin/jj
PATH=$test_root/bin:$PATH
rehash

typeset -ga p10k_calls
function p10k() { p10k_calls+=("${(j: :)@}"); }
source $helper

function fail() { print -u2 "FAIL: $*"; exit 1; }
function assert_eq() { [[ $1 == $2 ]] || fail "expected [$2], got [$1]"; }
function assert_contains() { [[ $1 == *$2* ]] || fail "[$1] lacks [$2]"; }
function calls() { print -r -- ${#$(<$JJ_CALLS)}; }
function last_display() { print -r -- ${p10k_calls[-1]}; }
function reset_recorder() { : >$JJ_CALLS; p10k_calls=(); }
function assert_jj_segments() {
  assert_eq ${#p10k_calls} 2
  assert_contains ${p10k_calls[1]} '-b 2 -f 0 -i jj -c ${_dotfiles_jj_text:+${_dotfiles_jj_warning:#1}} -e -t ${_dotfiles_jj_text}'
  assert_contains ${p10k_calls[2]} '-b 3 -f 0 -i jj -c ${_dotfiles_jj_text:+${_dotfiles_jj_warning:#0}} -e -t ${_dotfiles_jj_text}'
}
function assert_warning() {
  local expected=$1
  reset_recorder
  _dotfiles_jj_update
  assert_eq "$(calls)" 1
  assert_eq $_dotfiles_jj_warning $expected
}

# Plain and Git-only paths never start JJ.
mkdir $test_root/plain
cd $test_root/plain
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 0
assert_eq $_dotfiles_jj_text ''
assert_eq $_dotfiles_jj_warning ''
assert_contains "$(last_display)" '*/vcs=show'

git init -q $test_root/git-only
cd $test_root/git-only
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 0
assert_eq $_dotfiles_jj_warning ''
assert_eq $_dotfiles_jj_text ''

# Colocated and native JJ repos, including descendants, use JJ over Git.
jj --quiet git init --colocate $test_root/colocated >/dev/null
cd $test_root/colocated
jj --quiet describe -m $'%F{red} $() `x` \e\r\00112345678901234567890'
jj --quiet bookmark create bookmark-name-is-too-long
mkdir -p nested/path
cd nested/path
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1
assert_contains $_dotfiles_jj_text 'bookmark-…'
assert_contains $_dotfiles_jj_text '…'
assert_contains $_dotfiles_jj_text '%%'
[[ $_dotfiles_jj_text != *$'\t'* ]] || fail 'control character reached prompt text'
[[ $_dotfiles_jj_text != *$'\e'* && $_dotfiles_jj_text != *$'\r'* && $_dotfiles_jj_text != *$'\001'* ]] || fail 'control character reached prompt text'
assert_contains $_dotfiles_jj_text '%%F{red}'
assert_contains $_dotfiles_jj_text '$()'
assert_contains $_dotfiles_jj_text '`x`'
assert_contains $_dotfiles_jj_text empty
assert_eq $_dotfiles_jj_warning 1
assert_contains "$(last_display)" '*/vcs=hide'

cd $test_root
jj --quiet git init --no-colocate $test_root/native >/dev/null
[[ ! -e $test_root/native/.git ]] || fail 'non-colocated JJ repo has .git'
mkdir -p $test_root/native/child
cd $test_root/native/child
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1

# A nested Git repository prevents discovering the enclosing JJ repository.
git init -q $test_root/colocated/nested-git
mkdir -p $test_root/colocated/nested-git/deep
cd $test_root/colocated/nested-git/deep
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 0
assert_eq $_dotfiles_jj_text ''

# A .git file is the same ancestor boundary as a nested Git directory.
mkdir -p $test_root/colocated/nested-git-file/deep
print 'gitdir: nowhere' >$test_root/colocated/nested-git-file/.git
cd $test_root/colocated/nested-git-file/deep
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 0

# Prompt refresh reads changed description/bookmarks, while redraws never query JJ.
cd $test_root/colocated
reset_recorder
_dotfiles_jj_update
before=$_dotfiles_jj_text
jj --quiet describe -m 'refreshed description'
jj --quiet bookmark create refreshed-bookmark
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1
assert_contains $_dotfiles_jj_text refreshed
[[ $_dotfiles_jj_text != $before ]] || fail 'prompt cache did not refresh'
queried=$(calls)
p10k_calls=()
prompt_jj
assert_jj_segments
prompt_jj
assert_eq "$(calls)" $queried
assert_eq ${#p10k_calls} 4

# Nonempty descriptions display and truncate.
jj --quiet describe -m '123456789012345678901234567890'
_dotfiles_jj_update
assert_contains $_dotfiles_jj_text '1234567890123456789012345678…'

# Absent descriptions omit placeholder and separator; failed and missing JJ show Git.
jj --quiet describe -m ''
_dotfiles_jj_update
[[ $_dotfiles_jj_text != *'(no description)'* ]] || fail 'absent description rendered placeholder'
[[ $_dotfiles_jj_text != *'  '* ]] || fail 'absent description rendered extra separator'
export JJ_FAIL=1
_dotfiles_jj_update
unset JJ_FAIL
assert_eq $_dotfiles_jj_text ''
assert_eq $_dotfiles_jj_warning ''
assert_contains "$(last_display)" '*/vcs=show'
saved_path=$PATH
PATH=$test_root/empty-bin
rehash
_dotfiles_jj_update
assert_eq $_dotfiles_jj_text ''
assert_eq $_dotfiles_jj_warning ''
PATH=$saved_path
rehash

# Empty cache still emits P10k's deferred segment for hook-order-safe rendering.
p10k_calls=()
prompt_jj
assert_jj_segments

# Warning state comes from JJ metadata, never prompt text.
cd $test_root/colocated
jj --quiet new -m ''
assert_warning 0 # Empty, undescribed, unbookmarked.

# Adding and removing a bookmark changes an empty working copy immediately.
jj --quiet bookmark create empty-undescribed -r @
assert_warning 1 # Empty, undescribed, bookmarked.
jj --quiet bookmark delete empty-undescribed
assert_warning 0

# Empty working copies with descriptions warn only when bookmarked.
jj --quiet describe -m 'empty description'
assert_warning 0 # Empty, described, unbookmarked.
jj --quiet bookmark create empty-described -r @
assert_warning 1 # Empty, described, bookmarked.

# A bookmark on @- must not affect an unbookmarked empty @.
jj --quiet new -m ''
jj --quiet bookmark create parent-bookmark -r @-
assert_warning 0

# Nonempty working copies warn when undescribed, regardless of bookmarks.
print matrix-nonempty >$test_root/colocated/matrix-nonempty
assert_warning 1 # Nonempty, undescribed, unbookmarked.
jj --quiet describe -m 'nonempty description'
assert_warning 0 # Nonempty, described, unbookmarked.
jj --quiet bookmark create nonempty-described -r @
assert_warning 0 # Nonempty, described, bookmarked.
jj --quiet describe -m ''
assert_warning 1 # Nonempty, undescribed, bookmarked.
p10k_calls=()
prompt_jj
assert_jj_segments

# First prompt after a file edit reads live state, creating a snapshot operation.
jj --quiet describe -m 'nonempty description'
before_operation=$(command jj op log --ignore-working-copy --limit 1 --no-graph --template 'id.short()')
print unsnapshotted >$test_root/colocated/unsnapshotted
reset_recorder
_dotfiles_jj_update
after_operation=$(command jj op log --ignore-working-copy --limit 1 --no-graph --template 'id.short()')
[[ $_dotfiles_jj_text != *'[empty]'* ]] || fail 'unsnapshotted file edit still rendered empty'
assert_eq $_dotfiles_jj_warning 0
[[ $after_operation != $before_operation ]] || fail 'live prompt query did not create snapshot operation'
p10k_calls=()
prompt_jj
assert_jj_segments

# Clearing description transitions a nonempty working copy to yellow immediately.
jj --quiet describe -m ''
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1
assert_eq $_dotfiles_jj_warning 1

# Restoring a description transitions it back to green immediately.
jj --quiet describe -m 'empty| hostile description'
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1
assert_eq $_dotfiles_jj_warning 0

jj --quiet new -m ''
reset_recorder
_dotfiles_jj_update
assert_eq "$(calls)" 1
assert_eq $_dotfiles_jj_warning 0
p10k_calls=()
prompt_jj
assert_jj_segments

# P10k's serialized instant hook can run before helper definition.
unfunction _dotfiles_jj_update
p10k-on-pre-prompt
source $helper

# Real conflict rendering retains comma-separated state flags.
jj --quiet git init --colocate $test_root/conflict >/dev/null
cd $test_root/conflict
print base >file
jj --quiet describe -m base >/dev/null
jj --quiet new -m left >/dev/null
print left >file
jj --quiet describe -m left >/dev/null
left=$(jj log -r @ --no-graph --template 'change_id')
jj --quiet new @- -m right >/dev/null
print right >file
jj --quiet describe -m right >/dev/null
right=$(jj log -r @ --no-graph --template 'change_id')
jj --quiet new "$left" "$right" -m merge >/dev/null
_dotfiles_jj_update
assert_contains $_dotfiles_jj_text '[conflict,empty]'
print nonempty >extra
jj --quiet describe -m merge >/dev/null
_dotfiles_jj_update
assert_contains $_dotfiles_jj_text '[conflict]'

print 'powerlevel10k-jj: ok'
