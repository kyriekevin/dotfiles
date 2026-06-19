#!/usr/bin/env bash
# Non-interactive tmux health check. Covers package presence, source config,
# target config after chezmoi apply, and the zsh helper aliases/functions that
# make tmux usable as an optional fallback agent dashboard.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/dot_tmux.conf"
TGT="$HOME/.tmux.conf"
ALIASES="$REPO_ROOT/dot_config/zsh/aliases.zsh"
TOOLS="$REPO_ROOT/dot_config/zsh/tools.zsh"
BREWFILE="$REPO_ROOT/Brewfile"

echo "── Binary + packages ────────────────────────────────"
check "tmux on PATH"                         "command -v tmux >/dev/null"
check "Brewfile includes tmux"                "grep -qE '^brew \"tmux\"' $BREWFILE"
check "Brewfile does not include claude-squad" "! grep -qE '^brew \"claude-squad\"' $BREWFILE"

echo
echo "── Config presence ──────────────────────────────────"
check "dot_tmux.conf present"                 "test -r $SRC"
check "~/.tmux.conf present after apply"      "test -r $TGT"

echo
echo "── Pinned tmux behavior ─────────────────────────────"
check "prefix is C-a"                         "grep -qE '^set -g prefix C-a' $SRC"
check "default C-b unbound"                   "grep -qE '^unbind C-b' $SRC"
check "mouse enabled"                         "grep -qE '^set -g mouse on' $SRC"
check "activity monitor enabled"              "grep -qE '^set -g monitor-activity on' $SRC"
check "visual activity enabled"               "grep -qE '^set -g visual-activity on' $SRC"
check "OSC passthrough enabled"               "grep -qE '^set -g allow-passthrough on' $SRC"
check "new windows keep cwd"                  "grep -qE '^bind c new-window -c' $SRC"
check "split right keeps cwd"                 "grep -qE '^bind \\| split-window -h -c' $SRC"
check "zoom binding uses m"                   "grep -qE '^bind m resize-pane -Z' $SRC"
check "reload binding present"                "grep -qE '^bind r source-file ~/.tmux.conf' $SRC"

echo
echo "── Zsh entry points ─────────────────────────────────"
check "alias am"                               "grep -qE \"^alias am='agentmux'\" $ALIASES"
check "alias ad"                               "grep -qE \"^alias ad='agentdesk'\" $ALIASES"
check "agentmux function declared"             "grep -qE '^    agentmux\\(\\)' $TOOLS"
check "agentdesk function declared"            "grep -qE '^    agentdesk\\(\\)' $TOOLS"
check "helpers switch inside tmux"             "grep -q 'tmux switch-client -t' $TOOLS"
check "helpers attach outside tmux"            "grep -q 'tmux attach-session -t' $TOOLS"

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  If only ~/.tmux.conf is missing, run chezmoi apply and retry."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
