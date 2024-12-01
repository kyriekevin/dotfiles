#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing yazi if not already installed"
install yazi

step "Installing jq if not already installed"
install jq

step "Installing fd if not already installed"
install fd

step "Installing ripgrep if not already installed"
install ripgrep

step "Installing fzf if not already installed"
install fzf

step "Installing zoxide if not already installed"
install zoxide
