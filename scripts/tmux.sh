#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing tmux if not already installed"
install tmux

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
