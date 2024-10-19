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
        brew install "$@"
    else
        echo "'$@' is already installed, you're set."
        sleep 1
    fi
}

step "Installing bat if not already installed"
install bat

mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"

wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme

bat cache --build
