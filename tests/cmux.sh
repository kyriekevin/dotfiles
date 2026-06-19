#!/usr/bin/env bash
# Non-interactive cmux health check. Covers source intent and, once installed,
# validates that the CLI/app are reachable. cmux is the preferred agent control
# plane experiment; tmux remains only a fallback layer.
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
CFG="$REPO_ROOT/dot_config/cmux/cmux.json"
DOC_ZH="$REPO_ROOT/docs/agent-workflows.zh.md"
DOC_EN="$REPO_ROOT/docs/agent-workflows.md"

echo "── Package intent ───────────────────────────────────"
check "Brewfile taps manaflow-ai/cmux"          "grep -qE '^tap \"manaflow-ai/cmux\"' $BREWFILE"
check "Brewfile cask cmux"                      "grep -qE '^cask \"cmux\"' $BREWFILE"
check "Brewfile does not include claude-squad"  "! grep -qE '^brew \"claude-squad\"' $BREWFILE"
check "alias cm"                                "grep -qE \"^alias cm='cmux'\" $ALIASES"

echo
echo "── Config ───────────────────────────────────────────"
check "dot_config/cmux/cmux.json present"        "test -r $CFG"
check "cmux config is valid JSON"                "python3 -m json.tool $CFG >/dev/null"
check "sidebar matches terminal background"      "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"sidebarAppearance\"][\"matchTerminalBackground\"] is True' $CFG"
check "sidebar tint disabled"                    "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"sidebarAppearance\"][\"tintOpacity\"] == 0.0' $CFG"
check "sidebar hides noisy metadata"             "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); s=d[\"sidebar\"]; assert not s[\"showPorts\"] and not s[\"showPullRequests\"] and not s[\"showLog\"]' $CFG"
check "cmux uses ctrl+s chord prefix"            "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); b=d[\"shortcuts\"][\"bindings\"]; assert b[\"focusLeft\"] == [\"ctrl+s\", \"h\"] and b[\"toggleSidebar\"] == [\"ctrl+s\", \"b\"]' $CFG"
check "cmux new workspace uses ctrl+s semicolon" "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); b=d[\"shortcuts\"][\"bindings\"]; assert b[\"newTab\"] == [\"ctrl+s\", \";\"]' $CFG"
check "cmux new surface uses ctrl+s c"           "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); b=d[\"shortcuts\"][\"bindings\"]; assert b[\"newSurface\"] == [\"ctrl+s\", \"c\"]' $CFG"
check "cmux zoom uses ctrl+s m"                  "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); b=d[\"shortcuts\"][\"bindings\"]; assert b[\"toggleSplitZoom\"] == [\"ctrl+s\", \"m\"]' $CFG"
check "workspace movement chords pinned"         "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); b=d[\"shortcuts\"][\"bindings\"]; assert b[\"nextSidebarTab\"] == [\"ctrl+s\", \"n\"] and b[\"prevSidebarTab\"] == [\"ctrl+s\", \"p\"] and b[\"goToWorkspace\"] == [\"ctrl+s\", \"w\"]' $CFG"

echo
echo "── Docs ─────────────────────────────────────────────"
check "Chinese docs make cmux tier A"            "grep -qE '^### A\\. cmux' $DOC_ZH"
check "English docs make cmux tier A"            "grep -qE '^### A\\. cmux' $DOC_EN"
check "Docs apply cmux config"                   "grep -q '~/.config/cmux/cmux.json' $DOC_EN && grep -q '~/.config/cmux/cmux.json' $DOC_ZH"
check "Docs keep tmux as fallback"               "grep -q 'fallback' $DOC_EN && grep -q 'fallback' $DOC_ZH"

echo
echo "── Installed app / CLI ──────────────────────────────"
if command -v cmux >/dev/null 2>&1; then
    ok "cmux on PATH"
else
    bad "cmux on PATH" "run: brew tap manaflow-ai/cmux && brew install --cask cmux"
fi
check "cmux.app installed"                       "test -d /Applications/cmux.app || test -d /Applications/Cmux.app || test -d /Applications/CMUX.app"

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Install cmux before using this as the primary workflow."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
