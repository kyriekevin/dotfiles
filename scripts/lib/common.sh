#!/bin/bash

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
    local app_name="$1"

    if brew info --cask "$app_name" &>/dev/null; then
        if brew list --cask | grep -q "^${app_name}$"; then
            echo "'$app_name' is already installed, you're set."
            sleep 1
        else
            echo "Installing $app_name using brew cask..."
            brew install --cask "$app_name"
        fi
    elif brew info "$app_name" &>/dev/null; then
        if command -v "$app_name" &>/dev/null; then
            echo "'$app_name' is already installed, you're set."
            sleep 1
        else
            echo "Installing $app_name using brew..."
            brew install "$app_name"
        fi
    else
        echo "Error: $app_name not found in brew or brew cask"
        return 1
    fi
}
