#!/usr/bin/env bash
# Non-interactive Ghostty-compatible config check. cmux is the actual terminal
# surface now; this validates the ~/.config/ghostty/config file that cmux/
# libghostty reads for terminal rendering and keybind defaults. Standalone
# Ghostty.app is optional and intentionally not required.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

CFG="$HOME/.config/ghostty/config"

echo "── Standalone app status ────────────────────────────"
if command -v ghostty >/dev/null 2>&1; then
    ok "ghostty on PATH (optional)"
else
    ok "ghostty CLI absent (cmux-only setup)"
fi
if [[ -d /Applications/Ghostty.app ]]; then
    ok "Ghostty.app installed (optional)"
else
    ok "Ghostty.app absent (cmux-only setup)"
fi

echo
echo "── Config presence + syntax ─────────────────────────"
check "config present"                          "test -r $CFG"
if command -v ghostty >/dev/null 2>&1; then
    # Ghostty's own validator is authoritative when the optional CLI exists.
    check "ghostty +validate-config passes"     "ghostty +validate-config --config-file=$CFG"
else
    ok "ghostty validator skipped (CLI absent)"
fi

echo
echo "── Appearance fields ────────────────────────────────"
# These back the cmux/libghostty terminal profile. If someone deletes a line
# during refactor, the profile drifts from the workflow docs — flag here.
check "theme = Catppuccin Mocha"                "grep -qE '^theme *= *Catppuccin Mocha' $CFG"
check "font-family = Maple Mono NF CN"          "grep -qE '^font-family *= *Maple Mono NF CN\$' $CFG"
check "font-size = 12"                          "grep -qE '^font-size *= *12\$' $CFG"
check "background-opacity set"                  "grep -qE '^background-opacity *= *0\\.[0-9]+' $CFG"
check "macos-titlebar-style = transparent"      "grep -qE '^macos-titlebar-style *= *transparent' $CFG"

echo
echo "── Keybinds: chord prefix integrity ─────────────────"
# Regression guards for the tmux-style chord scheme:
#   1. Prefix must be ctrl+s (if someone changes it, they should also update docs).
#   2. hjkl navigation must live BEHIND the prefix, not as bare ctrl+hjkl —
#      Karabiner remaps ctrl+hjkl → arrow keys globally, so a bare binding
#      would never fire inside ghostty.
check "prefix chord ctrl+s>... present"         "grep -qE '^keybind *= *ctrl\\+s>' $CFG"
check "chord: ctrl+s>h = goto_split:left"       "grep -qE '^keybind *= *ctrl\\+s>h *= *goto_split:left' $CFG"
check "chord: ctrl+s>j = goto_split:bottom"     "grep -qE '^keybind *= *ctrl\\+s>j *= *goto_split:bottom' $CFG"
check "chord: ctrl+s>k = goto_split:top"        "grep -qE '^keybind *= *ctrl\\+s>k *= *goto_split:top' $CFG"
check "chord: ctrl+s>l = goto_split:right"      "grep -qE '^keybind *= *ctrl\\+s>l *= *goto_split:right' $CFG"
check "chord: ctrl+s>c = new_tab"               "grep -qE '^keybind *= *ctrl\\+s>c *= *new_tab' $CFG"
check "chord: ctrl+s>m = toggle_split_zoom"     "grep -qE '^keybind *= *ctrl\\+s>m *= *toggle_split_zoom' $CFG"
check "chord: ctrl+s>x = close_surface"         "grep -qE '^keybind *= *ctrl\\+s>x *= *close_surface' $CFG"
check "chord: ctrl+s>r = reload_config"         "grep -qE '^keybind *= *ctrl\\+s>r *= *reload_config' $CFG"
check "global: cmd+grave → quick_terminal"      "grep -qE '^keybind *= *global:cmd\\+grave_accent *= *toggle_quick_terminal' $CFG"

# Karabiner conflict guard: no line binds bare ctrl+{h,j,k,l}=... (would be
# a live grenade — the key never reaches ghostty). chord form `ctrl+s>h`
# contains `>` before the letter, so the negation below ignores those.
check "no bare ctrl+hjkl binding (karabiner)"   "! grep -qE '^keybind *= *ctrl\\+[hjkl] *=' $CFG"

echo
echo "── Font + theme availability ────────────────────────"
if command -v ghostty >/dev/null 2>&1; then
    # Capture-then-match (not `grep -q` on the pipe) because `ghostty +list-*`
    # output is long and grep -q exits on first match → ghostty dies with
    # SIGPIPE → `set -o pipefail` fails the whole check. Reading into a var
    # first drains ghostty cleanly.
    _fonts=$(ghostty +list-fonts 2>/dev/null || true)
    _themes=$(ghostty +list-themes 2>/dev/null || true)
    check "font 'Maple Mono NF CN' available"   "grep -q '^Maple Mono NF CN\$' <<<\"\$_fonts\""
    check "theme 'Catppuccin Mocha' available"  "grep -q 'Catppuccin Mocha' <<<\"\$_themes\""
else
    ok "font availability check skipped (Ghostty CLI absent)"
    ok "theme availability check skipped (Ghostty CLI absent)"
fi

echo
echo "── Runtime context ──────────────────────────────────"
# Informational — helps debug when tests run from a non-ghostty shell.
if [[ ${TERM_PROGRAM:-} == "ghostty" ]] || [[ ${TERM:-} == "xterm-ghostty" ]]; then
    ok "running inside a Ghostty/libghostty terminal (TERM=$TERM)"
else
    ok "not inside Ghostty/libghostty (TERM=${TERM:-?})"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual fidelity and chord timing are NOT covered here — test"
    echo "  them interactively in cmux."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + keybind logic OK. Visual behavior still needs a real cmux window."
