#!/usr/bin/env bash
# Non-interactive yazi health check. ~1s. Covers binary presence, config
# parseability, plugin install state, and backend availability. Visual
# fidelity (image preview, borders, git gutter) is Manual-only —
# see docs/yazi.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

YZDIR="$HOME/.config/yazi"
CFG="$YZDIR/yazi.toml"
KEYMAP="$YZDIR/keymap.toml"
THEME="$YZDIR/theme.toml"
INIT="$YZDIR/init.lua"
TOOLS="$HOME/.config/zsh/tools.zsh"

echo "── Binaries on PATH ─────────────────────────────────"
check "yazi on PATH"                             "command -v yazi >/dev/null"
check "ya (companion) on PATH"                   "command -v ya >/dev/null"

echo
echo "── File presence ────────────────────────────────────"
check "yazi.toml present"                        "test -r $CFG"
check "keymap.toml present"                      "test -r $KEYMAP"
check "theme.toml present"                       "test -r $THEME"
check "init.lua present"                         "test -r $INIT"
check "zsh y() wrapper in tools.zsh"             "grep -q 'yazi.*--cwd-file' $TOOLS"

echo
echo "── TOML parses ──────────────────────────────────────"
# Python 3.11+ ships tomllib; earlier macOS CLT python3 (3.9) doesn't.
# When absent, skip parse-validation — structural grep below still catches
# obvious breakage (missing section headers).
if python3 -c 'import tomllib' 2>/dev/null; then
    check "yazi.toml parses as TOML"             "python3 -c 'import tomllib; tomllib.load(open(\"$CFG\",\"rb\"))'"
    check "keymap.toml parses as TOML"           "python3 -c 'import tomllib; tomllib.load(open(\"$KEYMAP\",\"rb\"))'"
    check "theme.toml parses as TOML"            "python3 -c 'import tomllib; tomllib.load(open(\"$THEME\",\"rb\"))'"
else
    ok "TOML parse check skipped (python3 lacks tomllib, needs ≥3.11)"
fi

echo
echo "── Expected sections / keys ─────────────────────────"
# Catches accidental section deletions during refactors. Each section
# here backs a real feature referenced by the docs — if one goes missing,
# the docs are lying.
for sect in '\[mgr\]' '\[preview\]' '\[opener\]' '\[open\]' '\[tasks\]' '\[plugin\]'; do
    check "yazi.toml has $sect"                  "grep -qE '^$sect' $CFG"
done
check "yazi.toml: fetcher 'git' registered"      "grep -q 'id = \"git\"' $CFG"
# url (not name) is the yazi ≥26 pattern key — using `name` made the fetcher
# silently no-op, which is how we shipped broken git-status on the first cut.
check "yazi.toml: fetcher uses url= (not name=)" "grep -q 'url = \"\\*\"' $CFG"
check "keymap: smart-enter bound"                "grep -q 'plugin smart-enter' $KEYMAP"
check "init.lua: full-border setup"              "grep -q 'full-border' $INIT"
check "init.lua: git setup"                      "grep -q 'require(\"git\")' $INIT"
check "theme.toml: flavor activated"             "grep -qE '^dark *=' $THEME"

echo
echo "── Preview backends on PATH ─────────────────────────"
# yazi auto-detects these by PATH; missing ones silently degrade
# (e.g. no PDF → text fallback). Flag loudly here — the brewfile
# should keep them present.
check "ffmpegthumbnailer (video thumb)"          "command -v ffmpegthumbnailer >/dev/null"
check "magick (imagemagick fallback)"            "command -v magick >/dev/null"
check "pdftoppm (poppler, PDF preview)"          "command -v pdftoppm >/dev/null"
check "7z (sevenzip, archive list)"              "command -v 7z >/dev/null || command -v 7zz >/dev/null"

echo
echo "── Plugins + flavor installed ───────────────────────"
# Plugins land under plugins/, flavors under flavors/ — both populated
# by `ya pkg install`. If the post-apply hook hasn't run yet, skip
# cleanly — docs explain how.
PLUG="$YZDIR/plugins"
FLAV="$YZDIR/flavors"
if [[ -d $PLUG ]]; then
    for plug in git smart-enter full-border; do
        # ya pkg unpacks into <name>.yazi/
        check "plugin $plug installed"           "test -d $PLUG/$plug.yazi"
    done
else
    ok "plugins dir not yet created — run 'chezmoi apply' then re-test"
fi
if [[ -d $FLAV ]]; then
    check "flavor catppuccin-mocha installed"    "test -d $FLAV/catppuccin-mocha.yazi"
else
    ok "flavors dir not yet created — run 'chezmoi apply' then re-test"
fi

echo
echo "── Terminal image protocol ──────────────────────────"
# Yazi auto-picks a protocol based on \$TERM/\$TERM_PROGRAM. Ghostty =
# Kitty graphics protocol. If tests run from Apple Terminal or a tmux
# session without passthrough, previews silently fall back to chafa/none.
if [[ ${TERM_PROGRAM:-} == "ghostty" ]] || [[ ${TERM:-} == "xterm-ghostty" ]]; then
    ok "running in Ghostty (TERM=$TERM) — image preview will use Kitty protocol"
else
    ok "not in Ghostty (TERM=${TERM:-?}) — image preview untested; run 'y' in Ghostty"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual fidelity (image preview, rounded borders, git gutter"
    echo "  glyphs) is NOT covered here — run 'y' in a real Ghostty tab"
    echo "  and walk the Manual checklist in docs/yazi.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + plugin logic OK. Visual still needs a real TTY —"
echo "  see docs/yazi.md → Health check → Manual."
