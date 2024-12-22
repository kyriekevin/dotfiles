#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing yazi if not already installed"
install yazi

step "Installing ffmpeg if not already installed"
install ffmpeg

step "Installing sevenzip if not already installed"
install sevenzip

step "Installing jq if not already installed"
install jq

step "Installing poppler if not already installed"
install poppler

step "Installing fd if not already installed"
install fd

step "Installing ripgrep if not already installed"
install ripgrep

step "Installing fzf if not already installed"
install fzf

step "Installing zoxide if not already installed"
install zoxide

step "Installing imagemagick if not already installed"
install imagemagick

step "Installing font-symbols-only-nerd-font if not already installed"
install font-symbols-only-nerd-font
