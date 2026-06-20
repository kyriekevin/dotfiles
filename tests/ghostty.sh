#!/usr/bin/env bash
# Non-interactive Ghostty health check. Ghostty is the actual terminal surface;
# Herdr runs inside it only when agent-aware workspaces are needed.
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
BREWFILE="$(cd "$(dirname "$0")/.." && pwd)/Brewfile"

echo "── Package intent ───────────────────────────────────"
check "Brewfile includes Ghostty cask"          "grep -qE '^cask \"ghostty\"' $BREWFILE"
check "Brewfile does not include cmux cask"     "! grep -qE '^cask \"cmux\"' $BREWFILE"

echo
echo "── App status ───────────────────────────────────────"
if command -v ghostty >/dev/null 2>&1; then
    ok "ghostty on PATH"
else
    ok "ghostty CLI absent from PATH (app-only cask is acceptable)"
fi
if [[ -d /Applications/Ghostty.app ]]; then
    ok "Ghostty.app installed"
else
    bad "Ghostty.app installed" "run: brew install --cask ghostty"
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
# These back the primary terminal profile. If someone deletes a line during
# refactor, the profile drifts from the workflow docs — flag here.
check "theme = Catppuccin Mocha"                "grep -qE '^theme *= *Catppuccin Mocha' $CFG"
check "font-family = Maple Mono NF CN"          "grep -qE '^font-family *= *Maple Mono NF CN\$' $CFG"
check "font-size = 12"                          "grep -qE '^font-size *= *12\$' $CFG"
check "background-opacity set"                  "grep -qE '^background-opacity *= *0\\.[0-9]+' $CFG"
check "macos-titlebar-style = transparent"      "grep -qE '^macos-titlebar-style *= *transparent' $CFG"

echo
echo "── Keybinds: minimal Ghostty layer ──────────────────"
# Herdr owns the terminal multiplexer prefix (`ctrl+b`). Ghostty keeps only
# the global quick terminal shortcut so there is no competing `ctrl+s` layer.
check "global: cmd+grave → quick_terminal"      "grep -qE '^keybind *= *global:cmd\\+grave_accent *= *toggle_quick_terminal' $CFG"
check "no Ghostty ctrl+s chord layer"           "! grep -qE '^keybind *= *ctrl\\+s>' $CFG"

# Karabiner conflict guard: no line binds bare ctrl+{h,j,k,l}=... because
# those keys are globally remapped before Ghostty can handle them.
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
    ok "running inside Ghostty (TERM=$TERM)"
else
    ok "not inside Ghostty (TERM=${TERM:-?})"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual fidelity, image previews, and chord timing are NOT covered"
    echo "  here — test them interactively in Ghostty."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + keybind logic OK. Visual behavior still needs a real Ghostty window."
