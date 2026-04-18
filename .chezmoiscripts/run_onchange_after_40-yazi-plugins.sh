#!/usr/bin/env bash
# Install yazi plugins via `ya pkg add`.
#
# run_onchange: the script body is content-hashed by chezmoi — adding or
# removing a plugin below changes the hash and triggers a re-run on the
# next `chezmoi apply`. `ya pkg` is idempotent: listing an already-added
# plugin in package.toml costs nothing; re-runs after the list stabilizes
# are skipped entirely by `ya pkg install`.
#
# Runs AFTER the Brewfile script (id 20) so `yazi`/`ya` are on PATH.
#
# Subcommand notes (yazi ≥26.x):
#   ya pkg add <repo:plugin>   — append to package.toml + install
#   ya pkg install             — install every plugin listed in package.toml
#   ya pkg list                — dump current package set for inspection
# Older yazi (≤0.4) shipped `ya pack -a` instead; fix here if you're
# pinning to an older brew.
set -euo pipefail

if ! command -v ya >/dev/null 2>&1; then
    echo "==> ya not on PATH — skipping yazi plugin install."
    echo "    (Brewfile installs it via 'brew install yazi'; run 'brew bundle' first.)"
    exit 0
fi

plugins=(
    "yazi-rs/plugins:git"
    "yazi-rs/plugins:smart-enter"
    "yazi-rs/plugins:full-border"
    # Flavors go through the same `ya pkg add` channel as plugins.
    # Landing dir differs (plugins/ vs flavors/) but the install
    # syntax is identical — yazi auto-routes by repo path.
    "yazi-rs/flavors:catppuccin-mocha"
)

# Detect the plugin set yazi already knows about to keep `ya pkg add`
# quiet when nothing changed. `ya pkg list` prints one line per plugin,
# repo:plugin formatted — grep-friendly.
existing=$(ya pkg list 2>/dev/null || true)

for p in "${plugins[@]}"; do
    if grep -qF "$p" <<<"$existing"; then
        echo "==> $p already registered — skipping"
        continue
    fi
    echo "==> ya pkg add $p"
    ya pkg add "$p"
done

# One final `install` reconciles state — if package.toml exists but the
# package/ dir was wiped, this re-fetches sources without re-adding.
echo "==> ya pkg install"
ya pkg install
