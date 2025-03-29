#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing wget if not already installed"
install wget

step "Installing mos if not already installed"
install mos

step "Installing font if not already installed"
install font-maple-mono-nf-cn
