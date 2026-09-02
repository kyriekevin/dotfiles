#!/usr/bin/env bash
# Aether Ledger package intent plus delegated live installation health.
set -uo pipefail

PASS=0
FAIL=0
ok()  { printf "  \033[32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31m✗\033[0m %s\n" "$1"; [[ -n ${2:-} ]] && printf "    %s\n" "$2"; FAIL=$((FAIL+1)); }

check() {
    local name=$1 cmd=$2 out
    if out=$(eval "$cmd" 2>&1); then ok "$name"; else bad "$name" "$out"; fi
}

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AETHER_REPO="${AETHER_LEDGER_REPO:-$HOME/github/Aether_Ledger}"

echo "── Package intent ───────────────────────────────────"
check "Brewfile includes uv"       "grep -qE '^brew \"uv\"' '$REPO_ROOT/Brewfile'"
check "Brewfile includes ccusage"  "grep -qE '^brew \"ccusage\"' '$REPO_ROOT/Brewfile'"
check "Brewfile includes zstd"     "grep -qE '^brew \"zstd\"' '$REPO_ROOT/Brewfile'"
check "node role template exists"  "test -r '$REPO_ROOT/dot_config/token-activity/node_name.tmpl'"

echo
echo "── Installed Aether Ledger ──────────────────────────"
if [[ -d "$AETHER_REPO/.git" || -f "$AETHER_REPO/.git" ]]; then
    ok "Aether Ledger checkout exists"
    check "Aether Ledger owns installation health" "make -C '$AETHER_REPO' health"
else
    bad "Aether Ledger checkout exists" "expected checkout is missing"
fi

echo
echo "─────────────────────────────────────────────────────"
if (( FAIL > 0 )); then
    printf "  \033[31m%d passed, %d failed\033[0m\n" "$PASS" "$FAIL"
    exit 1
fi
printf "  \033[32m%d passed, %d failed\033[0m\n" "$PASS" "$FAIL"
