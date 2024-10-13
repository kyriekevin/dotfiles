# Dotfiles

- [Dotfiles](#dotfiles)
  - [Quick start](#quick-start)

This repository records the configuration and installation scripts of various apps on my macOS computer. And I use homebrew to install these apps and use stow to manage the corresponding configuration files.

## Quick start

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
