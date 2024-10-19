# zsh

## Introduction

[website](http://www.zsh.org/)

Zsh is a shell designed for interactive use, although it is also a powerful scripting language. Many of the useful features of bash, ksh, and tcsh were incorporated into zsh; many original features were added.

We use oh-my-zsh to manage zsh configuration.

## Setup

### Install Oh My Zsh

Oh My Zsh is an open-source, community-driven framework for managing your Zsh configuration. It comes bundled with a ton of helpful functions, helpers, plugins, themes, and a few things that make you shout...

| Method    | Command                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |

### Install starship

Starship is the minimal, blazing-fast, and infinitely customizable prompt for any shell!

```bash
brew install starship
```

### Install plugins

We use the following plugins:

- zsh-autosuggestions
- zsh-syntax-highlighting

```bash
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
SYNTAX_HIGHLIGHTING_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
else
    echo "zsh-autosuggestions is already installed"
fi

if [ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
    echo "zsh-syntax-highlighting is already installed"
fi
```

And more plugins can be found in zsh plugins [website](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins)

To see what we use, check the `zsh` folder in this repository.
