# Homebrew

- [Homebrew](#homebrew)
  - [Introduction](#introduction)
  - [Setup](#setup)
    - [Download and Install](#download-and-install)
    - [Check Installation](#check-installation)
    - [Install Apps](#install-apps)
    - [Uninstall Apps](#uninstall-apps)
    - [Update Apps](#update-apps)

## Introduction

website: [Homebrew](https://brew.sh/)

Homebrew is a package manager for macOS. It is a free and open-source software that simplifies the installation of software on Apple's macOS operating system.

## Setup

### Download and Install

- Official installation script:

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

    Then to add Homebrew to your shell profile, run:

    ```bash
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ```

- Recommended installation script:
    This script will install Homebrew and pre-dependencies, and set up the Homebrew environment.

    ```bash
    #! /bin/bash

    step () {
        final=$(echo "$@")
        plus=$(expr ${#final} + 6)

        printhashtags () {
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
    xcode-select -p &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Xcode CLI tools not found. Installing them..."
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(softwareupdate -l |
            grep "\*.*Command Line" |
            head -n 1 | awk -F"*" '{print $2}' |
            sed -e 's/^ *//' |
            tr -d '\n')
        softwareupdate -i "$PROD" -v;
    else
        echo "'xcode command line tools' is already installed, you're set."
    fi

    step "Installing brew if not already installed"
    if ! command -v brew &> /dev/null
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "brew is already installed, you're set."
        sleep 1
    fi
    ```

### Check Installation

Try to check the version of Homebrew:

```bash
brew --version
# Homebrew 4.4.0
```

### Install Apps

To install an app, use the following command:

```bash
brew install <app>
```

To install an app with GUI, use the following command:

```bash
brew install --cask <app>
```

To install an app only if it is not already installed, use the following function:

```bash
install () {
    if ! command -v "$@" &> /dev/null; then
       brew install "$@"
       # brew install --cask "$@"
    else
       echo "'$@' is already installed, you're set."
       sleep 1
    fi
}
```

### Uninstall Apps

To uninstall an app, use the following command:

```bash
brew uninstall <app>
```

To uninstall an app with GUI, use the following command:

```bash
brew uninstall --cask <app>
```

### Update Apps

To update Homebrew and all installed apps, use the following command:

```bash
brew update
brew upgrade
```
