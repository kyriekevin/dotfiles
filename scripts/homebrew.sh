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

step "Installing xcode command line tools if not already installed"
xcode-select -p &>/dev/null
if [ $? -ne 0 ]; then
    echo "Xcode CLI tools not found. Installing them..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l |
        grep "\*.*Command Line" |
        head -n 1 | awk -F"*" '{print $2}' |
        sed -e 's/^ *//' |
        tr -d '\n')
    softwareupdate -i "$PROD" -v
else
    echo "'xcode command line tools' is already installed, you're set."
fi

step "Installing brew if not already installed"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/$(whoami)/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "brew is already installed, you're set."
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

step "Installing stow if not already installed"
install stow
