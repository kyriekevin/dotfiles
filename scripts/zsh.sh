#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

# Install dependencies
step "Installing eza if not already installed"
install eza

step "Installing fzf if not already installed"
install fzf

step "Installing zoxide if not already installed"
install zoxide

step "Installing starship if not already installed"
install starship

# Install zsh if not already installed
# (Add your distribution-specific installation command here)

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed"
fi

# Install plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
SYNTAX_HIGHLIGHTING_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
else
    echo "zsh-autosuggestions is already installed"
fi

if [ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
    echo "zsh-syntax-highlighting is already installed"
fi
