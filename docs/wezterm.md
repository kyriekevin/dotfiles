# Wezterm

## Introduction

[website](https://wezfurlong.org/wezterm/index.html)

Wezterm is a GPU-accelerated terminal emulator that runs on Linux, macOS and Windows. It includes features that are typically found in a terminal emulator, such as support for Unicode, TrueType fonts, and 24-bit color. It also includes features that are typically found in a terminal multiplexer, such as support for splitting the terminal into panes.

## Setup

### Installation

Wezterm can be installed using the package manager of your operating system. For example, on macOS, you can install Wezterm using Homebrew:

```bash
brew install --cask wezterm
```

### Configuration

Wezterm is configured using a configuration file that is written in the Lua programming language. The configuration file is located at `~/.wezterm.lua` or `~/.config/wezterm.lua`. Here is an example configuration file:

```lua
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration
local config = wezterm.config_builder()

-- This is where you can configure Wezterm

-- For example, you can set the font size
config.font_size = 12.0

return config
```

More information about configuring Wezterm can be found in the [documentation](https://wezfurlong.org/wezterm/config/files.html).
