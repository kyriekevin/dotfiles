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

install() {
    if ! command -v "$@" &>/dev/null; then
        brew install --cask "$@"
    else
        echo "'$@' is already installed, you're set."
        sleep 1
    fi
}

step "Installing wezterm if not already installed"
install wezterm
