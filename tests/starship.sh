#!/usr/bin/env bash
# Non-interactive starship health check. ~1s. Covers everything testable
# without a real TTY — powerline glyph rendering, nerd-font fallback, and
# actual color output live in docs/starship.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

echo "── File presence ────────────────────────────────────"
check "starship on PATH"                         "command -v starship >/dev/null"
check "~/.config/starship.toml"                  "test -r ~/.config/starship.toml"

echo
echo "── Config parses ────────────────────────────────────"
check "starship print-config exits 0"            "starship print-config >/dev/null"

echo
echo "── zsh integration wired ────────────────────────────"
check "tools.zsh invokes 'starship init zsh'"    "grep -q 'starship init zsh' ~/.config/zsh/tools.zsh"

echo
echo "── Prompt renders ───────────────────────────────────"
check "starship prompt (clean)"                  "starship prompt >/dev/null"
check "starship prompt --status 1 (error)"       "starship prompt --status 1 >/dev/null"

echo
echo "── Feedback modules fire under correct conditions ───"
PROMPT_ERR=$(starship prompt --status=1 2>/dev/null || true)
PROMPT_LONG=$(starship prompt --cmd-duration=5000 2>/dev/null || true)
PROMPT_JOB=$(starship prompt --jobs=1 2>/dev/null || true)
PROMPT_NO_CLAUDE=$(env -u CLAUDECODE starship prompt 2>/dev/null || true)
PROMPT_CLAUDE=$(CLAUDECODE=1 starship prompt 2>/dev/null || true)
export PROMPT_ERR PROMPT_LONG PROMPT_JOB PROMPT_NO_CLAUDE PROMPT_CLAUDE

check '$status shows ✘ on exit 1'                '[[ "$PROMPT_ERR" == *✘* ]]'
check '$cmd_duration shows "took" after ≥3s'     '[[ "$PROMPT_LONG" == *took* ]]'
check '$jobs shows ✦ when a bg job exists'       '[[ "$PROMPT_JOB" == *✦* ]]'
check 'custom.claude hidden without CLAUDECODE'  '[[ "$PROMPT_NO_CLAUDE" != *claude* ]]'
check 'custom.claude visible with CLAUDECODE=1'  '[[ "$PROMPT_CLAUDE" == *claude* ]]'

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual fidelity (nerd-font glyphs, powerline segments,"
    echo "  actual colors) is NOT covered here — open a real terminal"
    echo "  and run the Manual checklist in docs/starship.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + module logic OK. Visual rendering still needs a real"
echo "  TTY — see docs/starship.md → Health check → Manual."
