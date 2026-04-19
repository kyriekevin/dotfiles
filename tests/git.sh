#!/usr/bin/env bash
# Non-interactive git config health check. ~1s. Covers binary presence,
# target-file presence, and a regression guard on every setting we
# intentionally pin in dot_gitconfig.tmpl. Identity-per-machine is verified
# by grepping the source template (both branches must be present); the
# currently-active identity is verified via `git config --global`. Manual
# cross-machine check is in docs/git.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

SRC="/Users/bytedance/.dotfiles/dot_gitconfig.tmpl"
GC="$HOME/.gitconfig"
GI="$HOME/.gitignore_global"

echo "── Binary ───────────────────────────────────────────"
check "git on PATH"                             "command -v git >/dev/null"
check "delta on PATH"                           "command -v delta >/dev/null"

echo
echo "── Target files present ─────────────────────────────"
check "~/.gitconfig present"                    "test -r $GC"
check "~/.gitignore_global present"             "test -r $GI"

echo
echo "── Active global config ─────────────────────────────"
check "user.name set"                           "test -n \"$(git config --global user.name)\""
check "user.email set"                          "test -n \"$(git config --global user.email)\""
check "core.editor = nvim"                      "test \"$(git config --global core.editor)\" = nvim"
check "core.pager = delta"                      "test \"$(git config --global core.pager)\" = delta"
check "core.excludesFile = ~/.gitignore_global" "test \"\$(git config --global core.excludesFile)\" = '~/.gitignore_global'"
check "init.defaultBranch = main"               "test \"$(git config --global init.defaultBranch)\" = main"
check "push.autoSetupRemote = true"             "test \"$(git config --global push.autoSetupRemote)\" = true"
check "fetch.prune = true"                      "test \"$(git config --global fetch.prune)\" = true"
check "rebase.autoStash = true"                 "test \"$(git config --global rebase.autoStash)\" = true"
check "merge.conflictstyle = zdiff3"            "test \"$(git config --global merge.conflictstyle)\" = zdiff3"
check "interactive.diffFilter uses delta"       "git config --global interactive.diffFilter | grep -q '^delta'"
check "delta.navigate = true"                   "test \"$(git config --global delta.navigate)\" = true"
check "delta.side-by-side = true"               "test \"$(git config --global delta.side-by-side)\" = true"
check "delta.line-numbers = true"               "test \"$(git config --global delta.line-numbers)\" = true"
check "commit.verbose = true"                   "test \"$(git config --global commit.verbose)\" = true"
check "credential.helper = osxkeychain"         "test \"$(git config --global credential.helper)\" = osxkeychain"
check "alias.lg set"                            "test -n \"$(git config --global alias.lg)\""

echo
echo "── Identity per is_work (template both branches) ────"
# Non-interactive check: both identities must be present in source, and
# must be guarded by is_work so the render picks exactly one.
check "template branches on is_work"            "grep -q '{{- if .is_work }}' $SRC"
check "work name (zyz) in template"             "grep -q 'name  = zyz' $SRC"
check "work email (bytedance) in template"      "grep -q 'email = zhongyuzhe@bytedance.com' $SRC"
check "personal name (Kyrie) in template"       "grep -q 'name  = Kyrie' $SRC"
check "personal email (qq) in template"         "grep -q 'email = yuzhezhong0117@qq.com' $SRC"

echo
echo "── Smoke ────────────────────────────────────────────"
# Active identity matches the active machine's is_work — we're always on
# one or the other, so whichever renders must be self-consistent.
check "active identity matches template"        "git config --global user.email | grep -qE '^(zhongyuzhe@bytedance\.com|yuzhezhong0117@qq\.com)$'"
check "git lg alias renders (cat pager)"        "git -C /Users/bytedance/.dotfiles -c core.pager=cat lg -1 >/dev/null"

echo
if [ $FAIL -eq 0 ]; then
    printf "\n  \033[32m%d passed, 0 failed\033[0m\n" $PASS
    exit 0
else
    printf "\n  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    exit 1
fi
