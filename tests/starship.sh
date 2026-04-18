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
echo "── Nerd-font / Powerline glyph invariants ───────────"
# These codepoints live in the Private Use Area. They are invisible to
# most text editors and were silently stripped four times during earlier
# refactors, yielding a visually broken prompt while every other check
# passed. Count from the live render for what's always visible, and grep
# the config file for conditional symbols (git/c/python) that only fire
# in matching projects.
PUA_COUNTS=$(starship prompt 2>/dev/null | python3 -c '
import sys, re
raw = sys.stdin.buffer.read().decode("utf-8", errors="replace")
txt = re.sub(r"\x1b\[[0-9;]*m", "", raw)
pl = sum(1 for c in txt if 0xE0B0 <= ord(c) <= 0xE0BF)
mac = sum(1 for c in txt if ord(c) == 0xF0035)
arrow = sum(1 for c in txt if ord(c) == 0xF432)
print(f"{pl} {mac} {arrow}")
')
read PL MAC ARROW <<<"$PUA_COUNTS"
export PL MAC ARROW
check 'Powerline glyphs in prompt (≥5)'          '(( PL >= 5 ))'
check 'macOS nerd-font icon (U+F0035) present'   '(( MAC >= 1 ))'
check 'character arrow glyph (U+F432) present'   '(( ARROW >= 1 ))'
STARSHIP_CFG="$HOME/.config/starship.toml"
has_cp() { python3 -c 'import sys; sys.exit(0 if chr(int(sys.argv[1],16)) in open(sys.argv[2]).read() else 1)' "$1" "$2"; }
export -f has_cp
export STARSHIP_CFG
check '[git_branch] symbol U+F418 in config'     'has_cp F418 "$STARSHIP_CFG"'
check '[c] symbol U+E61E in config'              'has_cp E61E "$STARSHIP_CFG"'
check '[python] symbol U+E606 in config'         'has_cp E606 "$STARSHIP_CFG"'
check '[time] clock icon U+F43A in config'       'has_cp F43A "$STARSHIP_CFG"'
check 'Downloads dir icon U+F019 in config'      'has_cp F019 "$STARSHIP_CFG"'
check 'Pictures dir icon U+F03E in config'       'has_cp F03E "$STARSHIP_CFG"'

echo
echo "── Contrast / vi-mode invariants ────────────────────"
# Regression guards for the fix/starship PR: feedback modules used to live
# inside the mauve ribbon and had bg:mauve in their style, which killed
# the semantic-color contrast. vi-normal was written as fg:green, making
# it visually indistinguishable from the success arrow.
check '[status] has no bg:mauve'                 '! grep -A2 "^\[status\]" "$STARSHIP_CFG" | grep -q "bg:mauve"'
check '[cmd_duration] has no bg:mauve'           '! grep -A3 "^\[cmd_duration\]" "$STARSHIP_CFG" | grep -q "bg:mauve"'
check '[jobs] has no bg:mauve'                   '! grep -A4 "^\[jobs\]" "$STARSHIP_CFG" | grep -q "bg:mauve"'
check '[custom.claude] has no bg:mauve'          '! grep -A6 "^\[custom.claude\]" "$STARSHIP_CFG" | grep -q "bg:mauve"'
check 'vimcmd_symbol uses fg:mauve'              'grep -q "^vimcmd_symbol.*fg:mauve" "$STARSHIP_CFG"'

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
