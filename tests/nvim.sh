#!/usr/bin/env bash
# Non-interactive nvim health check. Covers Phase 7a (core) — options parse,
# lazy.nvim bootstraps, the 4 Phase 7a plugins install, catppuccin loads.
# Visual checks (colors, which-key popup, mini.pairs/surround interaction)
# live in docs/nvim.md → Health check → Manual.
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
echo "── Plugin directories populated ─────────────────────"
for p in lazy.nvim catppuccin which-key.nvim mini.pairs mini.surround; do
    check "$p installed"               "test -d $NVIM_DATA/lazy/$p"
done

echo
echo "── Lock file ────────────────────────────────────────"
check "lazy-lock.json exists"          "test -r $NVIM_CONFIG/lazy-lock.json"

echo
echo "── Runtime probe (colorscheme / leader / opts) ──────"
probe=$(nvim --headless \
    -c 'lua print("K_LEADER=" .. vim.g.mapleader)' \
    -c 'lua print("K_COLORS=" .. (vim.g.colors_name or ""))' \
    -c 'lua print("K_NUMBER=" .. tostring(vim.opt.number:get()))' \
    -c 'lua print("K_RELNUM=" .. tostring(vim.opt.relativenumber:get()))' \
    -c 'lua print("K_EXPANDTAB=" .. tostring(vim.opt.expandtab:get()))' \
    -c 'lua print("K_TS=" .. tostring(vim.opt.tabstop:get()))' \
    -c 'lua print("K_SW=" .. tostring(vim.opt.shiftwidth:get()))' \
    -c 'lua print("K_UNDOFILE=" .. tostring(vim.opt.undofile:get()))' \
    -c 'lua print("K_NETRW=" .. tostring(vim.g.loaded_netrw))' \
    '+qa' 2>&1)

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

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual features (catppuccin colors in a real TTY, which-key popup,"
    echo "  mini.pairs auto-close, mini.surround sa/sd/sr) are NOT covered —"
    echo "  open nvim and run the Manual checklist in docs/nvim.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Automated checks OK. Visual features still need a real TTY —"
echo "  see docs/nvim.md → Health check → Manual."
