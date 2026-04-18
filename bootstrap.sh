#!/usr/bin/env bash
# Bootstrap a new Mac with this dotfiles repo.
#
# Usage (after the age private key is in place):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
#
# Prereqs on a fresh Mac:
#   1. (optional) Install Homebrew manually if you want to audit the install script;
#      otherwise this script will install it.
#   2. Copy the age private key to ~/.config/chezmoi/key.txt (chmod 600).
#      Transfer via iCloud Drive / USB from an existing Mac.
#
set -euo pipefail

REPO_URL="https://github.com/kyriekevin/dotfiles.git"
SOURCE_DIR="${HOME}/.dotfiles"

# --- Homebrew ------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "!! Homebrew install succeeded but brew binary not found in expected paths"
        exit 1
    fi
fi

# --- chezmoi + age -------------------------------------------------------
command -v chezmoi >/dev/null 2>&1 || brew install chezmoi
command -v age     >/dev/null 2>&1 || brew install age

# --- age identity sanity check ------------------------------------------
key="${HOME}/.config/chezmoi/key.txt"
if [[ ! -f "${key}" ]]; then
    echo "!! Missing age identity at ${key}"
    echo "   Copy it from another Mac (iCloud Drive / USB) and re-run."
    exit 1
fi

# --- Init -----------------------------------------------------------------
chezmoi init --apply --source "${SOURCE_DIR}" "${REPO_URL}"
