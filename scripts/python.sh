#! /bin/bash

step() {
    final=$(echo "$@")
    plus=$(expr ${#final} + 6)

    printhashtags() {
        for i in $(seq $plus); do
            printf "#"
        done
        echo
    }

    echo
    printhashtags
    printf "## %s ##\n" "$@"
    printhashtags
    echo
}

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

install() {
    if ! command -v "$@" &>/dev/null; then
        brew install "$@"
    else
        echo "'$@' is already installed, you're set."
        sleep 1
    fi
}

step "Installing pipx if not already installed"
install pipx
pipx ensurepath
pipx install pre-commit
pipx install black
pipx install isort
pipx install commitizen
