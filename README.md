# Dotfiles

- [Dotfiles](#dotfiles)
  - [Quick start](#quick-start)
  - [Apps](#apps)
  - [Change log](#change-log)

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

## Apps

| Apps | Desc | Script | Docs| Website |
| --- | --- | --- | --- | --- |
| Homebrew | The missing package manager for macOS | [homebrew.sh](./scripts/homebrew.sh) | [Docs](./docs/homebrew.md) | [Website](https://brew.sh/) |
| Python | Python is a programming language that lets you work quickly and integrate systems more effectively. | [python.sh](./scripts/python.sh) | [Docs](./docs//pydocs/python.md) | [Website](https://www.python.org/) |
| Wezterm | A GPU-accelerated terminal emulator that runs on Linux, macOS and Windows. | [wezterm.sh](./scripts/wezterm.sh) | [Docs](./docs/wezterm.md) | [Website](https://wezfurlong.org/wezterm/index.html) |
| Zsh | Zsh is a shell designed for interactive use, although it is also a powerful scripting language. | [zsh.sh](./scripts/zsh.sh) | [Docs](./docs/zsh.md) | [Website](http://www.zsh.org/) |

## Change log

Please refer to the [CHANGELOG.md](CHANGELOG.md) file for more information.
