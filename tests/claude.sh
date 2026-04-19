#!/usr/bin/env bash
# Non-interactive Claude Code config health check. ~1s. Covers binary
# presence, target-file presence, JSON validity, and a regression guard
# on every field we intentionally pin in dot_claude/settings.json.
# Runtime directories under ~/.claude (sessions/, cache/, plugins/, …)
# are machine-local and ignored on purpose — see .chezmoiignore for the
# full exclusion list. Manual launch + UI checks are in docs/claude.md →
# Health check → Manual.
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
SRC="$REPO_ROOT/dot_claude/settings.json"
TGT="$HOME/.claude/settings.json"
IGN="$REPO_ROOT/.chezmoiignore"

echo "── Binary ───────────────────────────────────────────"
check "claude on PATH"                          "command -v claude >/dev/null"
check "bun on PATH (statusLine)"                "command -v bun >/dev/null"
check "npx on PATH (PreToolUse hook)"           "command -v npx >/dev/null"
check "node on PATH (plugin .mjs hooks)"        "command -v node >/dev/null"
check "ccusage on PATH (usage reports)"          "command -v ccusage >/dev/null"

echo
echo "── Source file ──────────────────────────────────────"
check "dot_claude/settings.json present"        "test -r $SRC"
check "dot_claude/settings.json is valid JSON"  "python3 -c 'import json,sys; json.load(open(sys.argv[1]))' $SRC"

echo
echo "── Target file ──────────────────────────────────────"
check "~/.claude/settings.json present"         "test -r $TGT"
check "~/.claude/settings.json is valid JSON"   "python3 -c 'import json,sys; json.load(open(sys.argv[1]))' $TGT"

echo
echo "── Pinned settings fields (source-of-truth grep) ────"
# Regression guards: these values must survive a source→target render.
# Grep source only so the check reflects intent, not whatever chezmoi last
# applied. If chezmoi hasn't been applied yet the target check above will
# already have failed — this section isolates the source contract.
check "PreToolUse Bash matcher present"         "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"hooks\"][\"PreToolUse\"][0][\"matcher\"]==\"Bash\"' $SRC"
check "PreToolUse uses npx block-no-verify"     "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"hooks\"][\"PreToolUse\"][0][\"hooks\"][0][\"command\"]==\"npx block-no-verify@1.1.2\"' $SRC"
check "statusLine type = command"               "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"statusLine\"][\"type\"]==\"command\"' $SRC"
check "statusLine shells to bun (Apple Silicon)" "grep -q '/opt/homebrew/bin/bun' $SRC"
check "claude-hud plugin enabled"               "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"enabledPlugins\"][\"claude-hud@claude-hud\"] is True' $SRC"
check "openai-codex plugin enabled"             "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"enabledPlugins\"][\"codex@openai-codex\"] is True' $SRC"
check "karpathy-skills plugin enabled"          "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"enabledPlugins\"][\"andrej-karpathy-skills@karpathy-skills\"] is True' $SRC"
check "chrome-devtools-mcp plugin enabled"      "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"enabledPlugins\"][\"chrome-devtools-mcp@claude-plugins-official\"] is True' $SRC"
check "claude-hud marketplace registered"       "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"extraKnownMarketplaces\"][\"claude-hud\"][\"source\"][\"repo\"]==\"jarrodwatts/claude-hud\"' $SRC"
check "openai-codex marketplace registered"     "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"extraKnownMarketplaces\"][\"openai-codex\"][\"source\"][\"repo\"]==\"openai/codex-plugin-cc\"' $SRC"
check "karpathy-skills marketplace registered"  "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"extraKnownMarketplaces\"][\"karpathy-skills\"][\"source\"][\"repo\"]==\"forrestchang/andrej-karpathy-skills\"' $SRC"
check "claude-plugins-official registered"      "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"extraKnownMarketplaces\"][\"claude-plugins-official\"][\"source\"][\"repo\"]==\"anthropics/claude-plugins-official\"' $SRC"
check "syntaxHighlightingDisabled = true"       "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"syntaxHighlightingDisabled\"] is True' $SRC"
check "effortLevel = xhigh"                     "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d[\"effortLevel\"]==\"xhigh\"' $SRC"

echo
echo "── Runtime exclusions (.chezmoiignore) ──────────────"
# Every entry here has a rationale in docs/claude.md → Runtime exclusions.
# If one disappears from .chezmoiignore, machine-local state can leak
# into the repo on a future `chezmoi add` — break loud, fix fast.
for path in \
    "dot_claude/settings.local.json" \
    "dot_claude/sessions/**" \
    "dot_claude/projects/**" \
    "dot_claude/plans/**" \
    "dot_claude/plugins/**" \
    "dot_claude/cache/**" \
    "dot_claude/file-history/**" \
    "dot_claude/shell-snapshots/**" \
    "dot_claude/telemetry/**" \
    "dot_claude/tasks/**" \
    "dot_claude/*.jsonl" \
    "dot_claude/*.log" \
    "dot_claude/*-cache.json" \
    "dot_claude.json"
do
    check "ignored: $path"                       "grep -qF '$path' $IGN"
done

echo
echo "── Plugin cache (depends on claude plugin install) ──"
# statusLine hard-depends on claude-hud being installed. If the cache
# tree is missing, the spawned bash oneliner silently exec's on nothing
# and the status line quietly breaks — most users only notice after a
# few sessions. Catch it here.
if ls -d "$HOME/.claude/plugins/cache/claude-hud/claude-hud"/*/ >/dev/null 2>&1; then
    ok "claude-hud plugin cache populated"
else
    bad "claude-hud plugin cache populated" "run: claude plugin install claude-hud@claude-hud"
fi
check "codex plugin cache populated"             "ls -d $HOME/.claude/plugins/cache/openai-codex/codex/*/ >/dev/null 2>&1"
check "karpathy-skills plugin cache populated"   "ls -d $HOME/.claude/plugins/cache/karpathy-skills/andrej-karpathy-skills/*/ >/dev/null 2>&1"
# chrome-devtools-mcp is fetched from a `url` source (not a versioned GitHub
# release), so its cache folder is literally named `latest/` rather than a
# semver directory like the other three plugins above. Match that exact shape.
check "chrome-devtools-mcp cache populated"      "test -d $HOME/.claude/plugins/cache/claude-plugins-official/chrome-devtools-mcp/latest"

echo
echo "── Smoke ────────────────────────────────────────────"
check "claude --version runs"                    "claude --version >/dev/null"
# PreToolUse hook: block-no-verify must be resolvable by npx. Pure
# readonly check — `--no-install` fails fast if the package isn't in
# npx's cache yet, no network, no side effects. On a fresh Mac this
# check will red until the first Claude Bash call primes the cache via
# the hook itself (npx auto-installs on first actual invocation). That's
# a correct signal, not a bug: it says "the hook hasn't been exercised
# yet on this machine."
check "npx block-no-verify cached"               "npx --no-install block-no-verify@1.1.2 --help >/dev/null 2>&1"

echo
if [ $FAIL -eq 0 ]; then
    printf "\n  \033[32m%d passed, 0 failed\033[0m\n" $PASS
    exit 0
else
    printf "\n  \033[31m%d passed, %d failed\033[0m\n" $PASS $FAIL
    exit 1
fi
