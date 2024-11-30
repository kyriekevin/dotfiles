#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing pyenv if not already installed"
if ! command -v pyenv &>/dev/null; then
    brew install pyenv
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
else
    echo "pyenv is already installed, you're set."
    sleep 1
fi

step "Installing pipx if not already installed"
install pipx
pipx ensurepath
pipx install pre-commit
pipx install black
pipx install isort
pipx install commitizen
