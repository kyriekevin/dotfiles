#!/usr/bin/env bash
# Non-interactive nvim health check. Covers Phase 7a (core) + 7b (nav) —
# options parse, lazy.nvim bootstraps, all declared plugins install,
# catppuccin + snacks load at startup. Visual checks (colors, which-key
# popup, picker UI, neo-tree reveal, flash jump, gitsigns gutter, lualine
# bar, bufferline tab) live in docs/nvim.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

NVIM_CONFIG="$HOME/.config/nvim"
NVIM_DATA="$HOME/.local/share/nvim"

echo "── File presence ────────────────────────────────────"
check "~/.config/nvim/init.lua"        "test -r $NVIM_CONFIG/init.lua"

echo
echo "── Lua syntax (luac -p if available) ────────────────"
if command -v luac >/dev/null 2>&1; then
    check "init.lua parses (luac -p)"  "luac -p $NVIM_CONFIG/init.lua"
else
    ok "luac not installed — skipping (headless nvim below catches errors)"
fi

echo
echo "── Binary on PATH ───────────────────────────────────"
check "nvim"                           "command -v nvim >/dev/null"
check "git (needed for lazy clone)"    "command -v git >/dev/null"

echo
echo "── Headless startup ─────────────────────────────────"
# A clean +qa run is the strongest smoke test: parses init.lua, bootstraps
# lazy.nvim, evaluates plugin specs. stderr is captured separately because
# lazy prints install progress to stdout.
startup_err=$(nvim --headless '+qa' 2>&1 >/dev/null)
if [[ -z "$startup_err" ]]; then
    ok "nvim --headless +qa exits clean"
else
    # Lazy's first-run install prints to stderr under some builds; only fail
    # if the message mentions "Error" or "E".
    if grep -qE 'E[0-9]+:|Error' <<<"$startup_err"; then
        bad "nvim --headless +qa exits clean" "$startup_err"
    else
        ok "nvim --headless +qa exits clean (startup warnings are benign)"
    fi
fi

echo
echo "── Lazy sync (installs missing plugins on first run) ─"
# --headless "+Lazy! sync" installs without the TUI. `Lazy!` blocks until done.
sync_log=$(mktemp)
if nvim --headless '+Lazy! sync' '+qa' >"$sync_log" 2>&1; then
    ok "lazy sync completes"
else
    bad "lazy sync completes" "$(tail -n 20 "$sync_log")"
fi

echo
echo "── Plugin directories populated (7a + 7b) ───────────"
for p in \
    lazy.nvim \
    catppuccin \
    which-key.nvim \
    mini.pairs \
    mini.surround \
    snacks.nvim \
    neo-tree.nvim \
    nui.nvim \
    plenary.nvim \
    nvim-web-devicons \
    flash.nvim \
    gitsigns.nvim \
    mini.ai \
    mini.comment \
    lualine.nvim \
    bufferline.nvim; do
    check "$p installed"               "test -d $NVIM_DATA/lazy/$p"
done

echo
echo "── Lock file ────────────────────────────────────────"
check "lazy-lock.json exists"          "test -r $NVIM_CONFIG/lazy-lock.json"

echo
echo "── Runtime probe (colorscheme / leader / opts / 7b) ──"
# Probe lives in tests/nvim_probe.lua and is loaded via +luafile — avoids
# the fragile "multi-line lua inside a single -c arg" pattern flagged by
# code review. +luafile runs AFTER init.lua, so plugins are initialized.
probe_script="$(dirname "$0")/nvim_probe.lua"
if [[ ! -r "$probe_script" ]]; then
    bad "probe script $probe_script missing"
    probe=""
else
    probe=$(nvim --headless "+luafile $probe_script" '+qa' 2>&1)
fi

get() { awk -F= -v k="$1" '$1==k { sub(/^[^=]+=/, ""); print; exit }' <<<"$probe"; }
export -f get
export probe

check "mapleader = <space>"            '[[ "$(get K_LEADER)" == " " ]]'
check "colorscheme = catppuccin*"      '[[ "$(get K_COLORS)" == catppuccin* ]]'
check "number on"                      '[[ "$(get K_NUMBER)" == true ]]'
check "relativenumber on"              '[[ "$(get K_RELNUM)" == true ]]'
check "expandtab on (spaces, not tabs)" '[[ "$(get K_EXPANDTAB)" == true ]]'
check "tabstop = 4"                    '[[ "$(get K_TS)" == 4 ]]'
check "shiftwidth = 4"                 '[[ "$(get K_SW)" == 4 ]]'
check "undofile on"                    '[[ "$(get K_UNDOFILE)" == true ]]'
check "netrw disabled (1)"             '[[ "$(get K_NETRW)" == 1 ]]'
check "Snacks global loaded"           '[[ "$(get K_SNACKS)" == true ]]'
check "<leader>cd diagnostic bound"    '[[ "$(get K_LEADER_CD)" == true ]]'

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual features (catppuccin colors in a real TTY, which-key popup,"
    echo "  snacks.picker UI, neo-tree sidebar, flash hint chars, gitsigns"
    echo "  gutter, lualine bar, bufferline tabs) are NOT covered — open"
    echo "  nvim and run the Manual checklist in docs/nvim.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Automated checks OK. Visual features still need a real TTY —"
echo "  see docs/nvim.md → Health check → Manual."
