#!/usr/bin/env bash
# Bootstrap a new Mac with this dotfiles repo.
#
# Usage (after Homebrew is installed and the age private key is in place):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
#
# Prereqs on a fresh Mac:
#   1. Install Homebrew:                  https://brew.sh
#   2. Copy the age private key to        ~/.config/chezmoi/key.txt  (chmod 600)
#      (transferred via iCloud Drive / USB from an existing Mac)
#
set -euo pipefail

REPO_URL="git@github.com:kyriekevin/dotfiles.git"
SOURCE_DIR="${HOME}/.dotfiles"

command -v brew    >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
command -v chezmoi >/dev/null || brew install chezmoi
command -v age     >/dev/null || brew install age

chezmoi init --apply --source "${SOURCE_DIR}" "${REPO_URL}"
