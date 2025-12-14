# Dotfiles

![GitHub last commit](https://img.shields.io/github/last-commit/kyriekevin/dotfiles)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/kyriekevin/dotfiles)

- [Dotfiles](#dotfiles)
  - [🚀 Quick start](#-quick-start)

This repository records the configuration and installation scripts of various apps on my macOS computer. And I use homebrew to install these apps and use stow to manage the corresponding configuration files.

## 🚀 Quick start

1. Clone this repository to your home directory.

    ```bash
    git clone https://github.com/kyriekevin/dotfiles.git
    mv dotfiles .dotfiles
    ```

2. Install homebrew and stow.

    ```bash
    chmod +x scripts/*.sh
    sh scripts/homebrew.sh
    ```

3. Install apps and configurations.

    ```bash
    sh scripts/<apps>.sh
    stow <apps>
    ```

> [!NOTE]
> `scripts/app.sh` is a shell script that installs the specified app and we don't need to run `stow` to install the configuration files because we use default configuration files.
