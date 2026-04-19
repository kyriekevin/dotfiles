#!/usr/bin/env bash
# Non-interactive karabiner health check. ~1s. Covers binary presence, JSON
# parseability, Karabiner's own linter, and regression guards on the key
# mappings that back the ghostty chord prefix + system sublayers. Runtime
# effect (actually press caps and see escape fire) is Manual-only — see
# docs/karabiner.md → Health check → Manual.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

CFG_DIR="$HOME/.config/karabiner/assets/complex_modifications"
CAPS="$CFG_DIR/caps.json"
SUBL="$CFG_DIR/sublayers.json"

echo "── Binary + app ─────────────────────────────────────"
check "Karabiner-Elements.app installed"        "test -d /Applications/Karabiner-Elements.app"
check "karabiner_cli on PATH"                   "command -v karabiner_cli >/dev/null"

echo
echo "── Config presence + syntax ─────────────────────────"
check "caps.json present"                       "test -r $CAPS"
check "sublayers.json present"                  "test -r $SUBL"
check "caps.json parses (jq)"                   "jq . $CAPS >/dev/null"
check "sublayers.json parses (jq)"              "jq . $SUBL >/dev/null"
# karabiner_cli is the authoritative linter — catches schema violations
# (unknown keys, bad key_code values, malformed conditions) that jq misses.
check "caps.json karabiner_cli lint"            "karabiner_cli --lint-complex-modifications $CAPS"
check "sublayers.json karabiner_cli lint"       "karabiner_cli --lint-complex-modifications $SUBL"

echo
echo "── Base layer (caps.json) regression guards ─────────"
# Each line backs a visible claim in docs/karabiner.md — if someone deletes
# or renames during refactor, the docs start lying.
check "caps_lock → left_control (hold)"         "jq -e '.rules[0].manipulators[0].to[0].key_code==\"left_control\"' $CAPS >/dev/null"
check "caps_lock → escape (tap)"                "jq -e '.rules[0].manipulators[0].to_if_alone[0].key_code==\"escape\"' $CAPS >/dev/null"
check "left_control → escape (tap)"             "jq -e '.rules[1].manipulators[0].to_if_alone[0].key_code==\"escape\"' $CAPS >/dev/null"
check "ctrl+h → left_arrow"                     "jq -e '.rules[2].manipulators[] | select(.from.key_code==\"h\") | .to[0].key_code==\"left_arrow\"' $CAPS >/dev/null"
check "ctrl+j → down_arrow"                     "jq -e '.rules[2].manipulators[] | select(.from.key_code==\"j\") | .to[0].key_code==\"down_arrow\"' $CAPS >/dev/null"
check "ctrl+k → up_arrow"                       "jq -e '.rules[2].manipulators[] | select(.from.key_code==\"k\") | .to[0].key_code==\"up_arrow\"' $CAPS >/dev/null"
check "ctrl+l → right_arrow"                    "jq -e '.rules[2].manipulators[] | select(.from.key_code==\"l\") | .to[0].key_code==\"right_arrow\"' $CAPS >/dev/null"

echo
echo "── Sublayer leaders (ctrl+w / ctrl+r / ctrl+x) ──────"
# Leaders set layer_{w,r,x}=1 with 500ms delayed_action to clear.
# If anyone changes the prefix letter, docs/key-muscle-memory break.
check "ctrl+w → sets layer_w=1"                 "jq -e '.rules[] | select(.description | test(\"ctrl\\\\+w →\")) | .manipulators[0] | .from.key_code==\"w\" and .from.modifiers.mandatory[0]==\"left_control\" and .to[0].set_variable.name==\"layer_w\"' $SUBL >/dev/null"
check "ctrl+r → sets layer_r=1"                 "jq -e '.rules[] | select(.description | test(\"ctrl\\\\+r →\")) | .manipulators[0] | .from.key_code==\"r\" and .to[0].set_variable.name==\"layer_r\"' $SUBL >/dev/null"
check "ctrl+x → sets layer_x=1"                 "jq -e '.rules[] | select(.description | test(\"ctrl\\\\+x →\")) | .manipulators[0] | .from.key_code==\"x\" and .to[0].set_variable.name==\"layer_x\"' $SUBL >/dev/null"

echo
echo "── Window layer (ctrl+w) deeplinks ──────────────────"
# Each window action = Raycast deeplink via `open -g` (the -g is required —
# without it Raycast steals focus and the wrong window gets resized).
for k in h l k j m n p; do
    case $k in
        h) target="left-half"     ;;
        l) target="right-half"    ;;
        k) target="top-half"      ;;
        j) target="bottom-half"   ;;
        m) target="maximize"      ;;
        n) target="next-display"  ;;
        p) target="previous-display" ;;
    esac
    check "w-layer: $k → window-management/$target" \
        "grep -qE 'open -g .*window-management/$target' $SUBL"
done
check "w-layer uses open -g (no bare open)"     "! grep -qE 'shell_command.*\"open raycast' $SUBL"

echo
echo "── Raycast layer (ctrl+r) deeplinks ─────────────────"
# AI Chat intentionally NOT in this layer — user keeps direct hyper+space.
check "r-layer: s → clipboard-history"          "grep -qE 'open -g .*clipboard-history' $SUBL"
check "r-layer: f → navigation/search-files"    "grep -qE 'open -g .*navigation/search-files' $SUBL"
check "r-layer: ; → translator/translate"       "grep -qE 'open -g .*translator/translate' $SUBL"
check "r-layer: e → emoji-symbols"              "grep -qE 'open -g .*emoji-symbols/search-emoji-symbols' $SUBL"
check "r-layer: AI Chat NOT in layer (direct)"  "! grep -qE 'raycast-ai/ai-chat' $SUBL"

echo
echo "── System layer (ctrl+x) native actions ─────────────"
# No Raycast / no brew install dependency — osascript is built into macOS.
check "x-layer: m → toggle mute (osascript)"    "grep -qE 'osascript.*output muted not' $SUBL"
check "x-layer: = → volume up (osascript)"      "jq -e '.rules[].manipulators[] | select(.from.key_code==\"equal_sign\") | .to[0].shell_command | test(\"output volume.*\\\\+ 10\")' $SUBL >/dev/null"
check "x-layer: - → volume down (osascript)"    "jq -e '.rules[].manipulators[] | select(.from.key_code==\"hyphen\") | .to[0].shell_command | test(\"output volume.*- 10\")' $SUBL >/dev/null"

echo
echo "── Timeout + delayed_action parameters ──────────────"
# All three leaders should have delayed_action to auto-clear the layer
# variable if user presses nothing within the timeout. Without this, a
# stray prefix press leaves the layer stuck.
check "all 3 leaders have to_delayed_action"    "jq -e '[.rules[].manipulators[] | select((.to[0].set_variable.name // \"\") | startswith(\"layer_\")) | .to_delayed_action] | length == 3' $SUBL >/dev/null"
check "timeout = 500ms"                         "jq -e '[.rules[].manipulators[] | select((.to[0].set_variable.name // \"\") | startswith(\"layer_\")) | .parameters[\"basic.to_delayed_action_delay_milliseconds\"]] | unique == [500]' $SUBL >/dev/null"

echo
echo "── Runtime context ──────────────────────────────────"
# Informational — helps debug when tests run without Karabiner active.
if pgrep -f karabiner_console_user_server >/dev/null 2>&1; then
    ok "Karabiner-Elements daemon running — live mapping possible"
else
    ok "Karabiner-Elements daemon NOT running — start app + walk docs Manual checklist"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    echo
    echo "  Runtime effect (caps tap → esc, ctrl+hjkl → arrows, ctrl+w+h →"
    echo "  left half) is NOT covered here — the rules must be imported via"
    echo "  Karabiner GUI first. See docs/karabiner.md → Health check → Manual."
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" $PASS $FAIL
echo
echo "  Config + lint OK. Runtime still needs Karabiner GUI import —"
echo "  see docs/karabiner.md → Health check → Manual."
