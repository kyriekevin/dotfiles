# Pyenv

- [Pyenv](#pyenv)
  - [Introduction](#introduction)
  - [Setup](#setup)
    - [Installation](#installation)
    - [Usage](#usage)
      - [Install additional Python versions](#install-additional-python-versions)
      - [Uninstall Python versions](#uninstall-python-versions)
      - [Switch between Python versions](#switch-between-python-versions)

## Introduction

[website](https://github.com/pyenv/pyenv)

Pyenv is a simple Python version management tool. It allows you to easily switch between multiple Python versions on your system.

## Setup

### Installation

We can use the following command to install pyenv.

```bash
brew update
brew install pyenv
```

Then set up shell environment variables.

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

### Usage

#### Install additional Python versions

To install additional Python versions, we can use the following command.

```bash
pyenv install -l # list all available versions
pyenv install <version>
```

#### Uninstall Python versions

To remove a Python version, we can use the following command.

```bash
pyenv uninstall <version>
```

#### Switch between Python versions

To switch between Python versions, we can use the following command.

* `pyenv shell <version>` -- select for the current shell session
* `pyenv local <version>` -- select for the current directory
* `pyenv global <version>` -- select globally for your system
