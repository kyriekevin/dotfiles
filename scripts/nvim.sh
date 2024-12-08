#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing nvim if not already installed"
install nvim

step "Installing fzf if not already installed"
install fzf

step "Installing ripgrep if not already installed"
install ripgrep

step "Installing macism if not already installed"
brew tap laishulu/homebrew
install macism
