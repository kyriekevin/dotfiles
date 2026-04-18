#!/usr/bin/env bash
# Non-interactive zsh health check. ~2s. Covers everything testable without
# a real TTY — visual features (autosuggest / syntax-highlight / fzf-tab /
# vi-mode indicator) live in docs/zsh.md → Health check → Manual.
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
check "~/.zshenv"                                   "test -r ~/.zshenv"
check "~/.zshrc"                                    "test -r ~/.zshrc"
for m in env plugins tools aliases; do
    check "~/.config/zsh/$m.zsh"                    "test -r ~/.config/zsh/$m.zsh"
done
check "~/.config/zsh/secrets.zsh (age-decrypted)"   "test -r ~/.config/zsh/secrets.zsh"

echo
echo "── Syntax (zsh -n) ──────────────────────────────────"
check "zshenv parses"                               "zsh -n ~/.zshenv"
check "zshrc parses"                                "zsh -n ~/.zshrc"
for m in env plugins tools aliases; do
    check "$m.zsh parses"                           "zsh -n ~/.config/zsh/$m.zsh"
done

echo
echo "── Interactive shell probe ──────────────────────────"
ALIAS_LIST="c p e gst gco gcb gcm ga gaa gd gl gp lg nv s cat ls l ll"

# Pick the first exported name from secrets.zsh so the "secrets reached the
# shell" probe doesn't hardcode any specific variable — rotating or renaming
# a secret doesn't break the test.
SECRETS_FIRST_NAME=$(awk '/^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=/ {
    sub(/^[[:space:]]*export[[:space:]]+/, "")
    sub(/=.*/, "")
    print; exit
}' ~/.config/zsh/secrets.zsh 2>/dev/null)
export SECRETS_FIRST_NAME

probe=$(zsh -ic '
echo "K_EDITOR=$EDITOR"
echo "K_BAT_THEME=$BAT_THEME"
echo "K_HF_ENDPOINT=$HF_ENDPOINT"
echo "K_COLUMNS=$COLUMNS"
if [[ -n "$SECRETS_FIRST_NAME" ]]; then
    echo "K_SECRET_VAL=${(P)SECRETS_FIRST_NAME:-__unset__}"
fi
command -v brew >/dev/null && echo "K_HAS_BREW=1" || echo "K_HAS_BREW=0"
for a in '"$ALIAS_LIST"'; do
    v=$(alias "$a" 2>/dev/null)
    echo "K_ALIAS_$a=$v"
done
' 2>/dev/null)

get() { awk -F= -v k="$1" '$1==k { sub(/^[^=]+=/, ""); print; exit }' <<<"$probe"; }
export -f get
export probe

check "EDITOR=nvim"                                 '[[ "$(get K_EDITOR)" == nvim ]]'
check "BAT_THEME set"                               '[[ -n "$(get K_BAT_THEME)" ]]'
check "HF_ENDPOINT is hf-mirror"                    '[[ "$(get K_HF_ENDPOINT)" == *hf-mirror.com* ]]'
check "COLUMNS > 0"                                 '(( $(get K_COLUMNS) > 0 ))'
if [[ -n "$SECRETS_FIRST_NAME" ]]; then
    check "secrets.zsh exports reach shell (\$$SECRETS_FIRST_NAME)" \
        '[[ "$(get K_SECRET_VAL)" != __unset__ && -n "$(get K_SECRET_VAL)" ]]'
else
    ok "secrets.zsh has no exports (nothing to verify)"
fi
check "brew on PATH (shellenv worked)"              '[[ "$(get K_HAS_BREW)" == 1 ]]'

echo
echo "── Aliases (${ALIAS_LIST// /, }) ──"
for a in $ALIAS_LIST; do
    check "alias $a"                                "[[ -n \"\$(get K_ALIAS_$a)\" ]]"
done

echo
echo "── zinit + plugin caches ────────────────────────────"
check "zinit cloned"                                "test -d ~/.local/share/zinit/zinit.git/.git"
for p in zsh-completions zsh-autosuggestions zsh-syntax-highlighting; do
    check "$p downloaded"                           "test -d ~/.local/share/zinit/plugins/zsh-users---$p"
done
check "fzf-tab downloaded"                          "test -d ~/.local/share/zinit/plugins/Aloxaf---fzf-tab"

echo
echo "── CLI tools on PATH ────────────────────────────────"
for t in fzf zoxide bat eza lazygit nvim; do
    check "$t"                                      "command -v $t >/dev/null"
done

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Visual features (autosuggestions / syntax highlighting /"
    echo "  fzf-tab menu / vi-mode indicator) are NOT covered here — open"
    echo "  a real terminal and run the Manual checklist in docs/zsh.md."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Automated checks OK. Visual features still need a real TTY —"
echo "  see docs/zsh.md → Health check → Manual."
