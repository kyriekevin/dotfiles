#!/usr/bin/env bash
# Non-interactive Herdr health check. Covers package intent, config presence,
# key choices, and installed CLI availability. Interactive pane rendering and
# agent state detection still need a real Ghostty window.
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
BREWFILE="$REPO_ROOT/Brewfile"
ALIASES="$REPO_ROOT/dot_config/zsh/aliases.zsh"
CFG="$REPO_ROOT/dot_config/herdr/config.toml"
DOC_ZH="$REPO_ROOT/docs/agent-workflows.zh.md"
DOC_EN="$REPO_ROOT/docs/agent-workflows.md"

echo "── Package intent ───────────────────────────────────"
check "Brewfile includes herdr"                 "grep -qE '^brew \"herdr\"' $BREWFILE"
check "Brewfile includes Ghostty cask"          "grep -qE '^cask \"ghostty\"' $BREWFILE"
check "Brewfile does not include cmux"          "! grep -qE 'cmux|manaflow-ai/cmux' $BREWFILE"
check "Brewfile does not include tmux"          "! grep -qE '^brew \"tmux\"' $BREWFILE"
check "alias hd"                                "grep -qE \"^alias hd='herdr'\" $ALIASES"
check "no cmux alias"                           "! grep -qE \"^alias cm='cmux'\" $ALIASES"
check "no tmux agent aliases"                   "! grep -qE \"^alias a[md]='agent\" $ALIASES"

echo
echo "── Config ───────────────────────────────────────────"
check "dot_config/herdr/config.toml present"     "test -r $CFG"
check "onboarding disabled"                     "grep -qE '^onboarding *= *false' $CFG"
check "terminal palette theme"                  "grep -qE '^name *= *\"terminal\"' $CFG"
check "toast delivery off"                      "grep -qE '^delivery *= *\"off\"' $CFG"
check "Herdr prefix stays ctrl+b"               "grep -qE '^prefix *= *\"ctrl\\+b\"' $CFG"
check "split vertical uses prefix+v"            "grep -qE '^split_vertical *= *\"prefix\\+v\"' $CFG"
check "split horizontal uses prefix+minus"      "grep -qE '^split_horizontal *= *\"prefix\\+minus\"' $CFG"
check "pane focus uses prefix hjkl"             "grep -qE '^focus_pane_left *= *\"prefix\\+h\"' $CFG && grep -qE '^focus_pane_down *= *\"prefix\\+j\"' $CFG && grep -qE '^focus_pane_up *= *\"prefix\\+k\"' $CFG && grep -qE '^focus_pane_right *= *\"prefix\\+l\"' $CFG"
check "zoom uses prefix+z"                      "grep -qE '^zoom *= *\"prefix\\+z\"' $CFG"

echo
echo "── Docs ─────────────────────────────────────────────"
check "Chinese docs make herdr tier A"           "grep -qE '^### A\\. Ghostty \\+ herdr' $DOC_ZH"
check "English docs make herdr tier A"           "grep -qE '^### A\\. Ghostty \\+ herdr' $DOC_EN"
check "Docs apply herdr config"                  "grep -q '~/.config/herdr/config.toml' $DOC_EN && grep -q '~/.config/herdr/config.toml' $DOC_ZH"
check "Docs no longer prefer cmux"               "! grep -q 'cmux is the primary' $DOC_EN && ! grep -q 'cmux 是主' $DOC_ZH"

echo
echo "── Installed CLI ────────────────────────────────────"
if command -v herdr >/dev/null 2>&1; then
    ok "herdr on PATH"
    check "herdr --version runs"                 "herdr --version >/dev/null"
    check "herdr --default-config runs"          "herdr --default-config >/dev/null"
else
    bad "herdr on PATH" "run: brew install herdr"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Install Herdr before using this as the primary workflow."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
