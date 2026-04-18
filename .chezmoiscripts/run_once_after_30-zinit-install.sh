#!/usr/bin/env bash
# Clone zinit on first apply if it's not already present.
#
# zinit's own docs recommend a self-install snippet inside .zshrc, but running
# it here instead:
#   - keeps the first interactive `zsh` fast (no clone-on-startup pause)
#   - lets bootstrap / CI assume zinit exists before smoke-testing plugins
set -euo pipefail

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ -d "$ZINIT_HOME/.git" ]]; then
    exit 0
fi

echo "==> Cloning zinit to $ZINIT_HOME"
mkdir -p "$(dirname "$ZINIT_HOME")"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
