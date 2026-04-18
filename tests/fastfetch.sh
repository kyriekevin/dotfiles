#!/usr/bin/env bash
# Non-interactive fastfetch health check. ~1s. Covers everything testable
# without a visual — nerd-font glyph rendering + actual colors live in
# docs/fastfetch.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

CFG="$HOME/.config/fastfetch/config.jsonc"
LUME_SH="$HOME/.config/fastfetch/lume-status.sh"
ALIASES="$HOME/.config/zsh/aliases.zsh"

echo "── File presence ────────────────────────────────────"
check "fastfetch on PATH"                        "command -v fastfetch >/dev/null"
check "~/.config/fastfetch/config.jsonc"         "test -r $CFG"
check "lume-status.sh present"                   "test -r $LUME_SH"
check "lume-status.sh executable"                "test -x $LUME_SH"

echo
echo "── Config parses + prompt renders ───────────────────"
# fastfetch returns 0 even on bad config; grep the output. --pipe strips ANSI
# (apart from embedded literals); --logo none drops the apple ASCII banner.
PROMPT=$(fastfetch --pipe --logo none 2>&1)
export PROMPT
check "no JsonConfig errors in output"           '! [[ "$PROMPT" == *JsonConfig* ]]'
check "no 'Error:' strings in output"            '! [[ "$PROMPT" == *"Error:"* ]]'
check "prompt has content (≥20 lines)"           '(( $(echo "$PROMPT" | wc -l) >= 20 ))'

echo
echo "── zsh alias wired ──────────────────────────────────"
check "aliases.zsh has s='fastfetch'"            "grep -qE \"alias +s=['\\\"]fastfetch['\\\"]\" $ALIASES"

echo
echo "── Modules fire ─────────────────────────────────────"
# Every module below should appear in clean-render output. If one drops out
# it's either a schema drift (upstream renamed / removed the module) or our
# config got trimmed — both regressions worth flagging loudly.
for k in Account os Host Kernel Uptime Packages Terminal Shell \
         CPU GPU Memory Battery Swap LocalIP \
         PhysicalDisk FileSystem Dev Editor Claude lume; do
    check "\$$k in output"                       "[[ \"\$PROMPT\" == *$k* ]]"
done

echo
echo "── Dev-group command invariants ─────────────────────"
check "claude on PATH (backs Dev.Claude)"        "command -v claude >/dev/null"
check "lume on PATH (backs Dev.lume)"            "command -v lume >/dev/null"
check "python3 on PATH (backs lume-status.sh)"   "command -v python3 >/dev/null"
# lume row = version + tree-indented per-VM sub-lines (├/└ prefixes). If the
# helper ever stops emitting the version or the tree markers we've broken
# the Hermes ops view. Zero-VMs case still has a version; skip the sub-row
# check when no VMs are registered locally.
check "lume version looks like N.N.N"            '[[ "$PROMPT" =~ lume.*[0-9]+\.[0-9]+\.[0-9]+ ]]'
# Detect "has any VMs" via lume itself, then require the tree prefix + ':'
# in the rendered output (indicating per-VM row made it through).
if lume ls --format json 2>/dev/null | python3 -c 'import json,sys; sys.exit(0 if json.load(sys.stdin) else 1)' 2>/dev/null; then
    check "lume sub-line has └ or ├ tree prefix" '[[ "$PROMPT" == *"└ "* ]] || [[ "$PROMPT" == *"├ "* ]]'
    check "lume sub-line shows status"           '[[ "$PROMPT" =~ (stopped|running) ]]'
else
    ok "lume sub-line check skipped (no VMs registered)"
fi

echo
echo "── Schema drift regression guards ───────────────────"
# Both were real bugs during Phase 4c bring-up — fastfetch ≥2.x rejects
# general.multithreading outright and renamed display.bar.charElapsed.
# If either comes back, fastfetch will exit with JsonConfig Error before
# ever rendering, so catch them at the source.
check "no general.multithreading (removed)"      "! grep -q multithreading $CFG"
check "no display.bar.charElapsed (renamed)"     "! grep -q charElapsed $CFG"
# Every SGR sequence must end with `m`. Missing terminator = fastfetch
# either drops the color silently (today) or corrupts the line when the
# threshold fires (future). Match `u001b[<digits;>+"` — the trailing quote
# with no `m` in between is what we're catching.
check 'no unterminated SGR sequences'            "! grep -qE 'u001b\\[[0-9;]+\"' $CFG"

echo
echo "── Nerd-font PUA codepoints preserved ───────────────"
# PUA codepoints are invisible to most editors and got stripped multiple
# times during the starship rewrite. Same trap exists here — guard the
# Phase 4c additions + one original glyph from the old dotfiles.
has_cp() { python3 -c 'import sys; sys.exit(0 if chr(int(sys.argv[1],16)) in open(sys.argv[2]).read() else 1)' "$1" "$2"; }
export -f has_cp
export CFG
check "Account glyph U+F0DAB in config"          'has_cp F0DAB "$CFG"'
check "Host glyph U+F0322 in config"             'has_cp F0322 "$CFG"'
check "Uptime glyph U+F0150 in config"           'has_cp F0150 "$CFG"'
check "LocalIP glyph U+F0A5F in config"          'has_cp F0A5F "$CFG"'
check "Dev header glyph U+F06A9 in config"       'has_cp F06A9 "$CFG"'
check "Editor glyph U+F0219 in config"           'has_cp F0219 "$CFG"'
check "Claude glyph U+F0B79 in config"           'has_cp F0B79 "$CFG"'
check "lume glyph U+F0862 in config"             'has_cp F0862 "$CFG"'

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual fidelity (nerd-font glyphs, actual colors, Apple"
    echo "  logo) is NOT covered here — run 's' in a real terminal"
    echo "  and walk the Manual checklist in docs/fastfetch.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + module logic OK. Visual still needs a real TTY —"
echo "  see docs/fastfetch.md → Health check → Manual."
