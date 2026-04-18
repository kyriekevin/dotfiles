#!/usr/bin/env bash
# Install Homebrew if it's not already present.
#
# Defensive net: bootstrap.sh already installs Homebrew on a fresh Mac, so this
# hook is a no-op in the normal flow. It only fires when someone skips the
# bootstrap script and runs `chezmoi apply` directly.
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
    exit 0
fi
if [[ -x /opt/homebrew/bin/brew || -x /usr/local/bin/brew ]]; then
    exit 0
fi

echo "==> Installing Homebrew (chezmoi run_once_before hook)"
NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
