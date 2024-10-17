# Pipx

- [Pipx](#pipx)
  - [Introduction](#introduction)
    - [Difference between pipx and pip](#difference-between-pipx-and-pip)
  - [Setup](#setup)
    - [Installation](#installation)
    - [Install Python Packages](#install-python-packages)

## Introduction

[website](https://github.com/pypa/pipx)

Pipx is a Python package manager that allows you to install and manage Python packages globally or in a virtual environment. It is designed to be a one-stop solution for installing and managing Python packages, and provides a simple and consistent interface for installing, upgrading, and uninstalling packages.

### Difference between pipx and pip

- pip is a general-purpose package installer for both libraries and apps with no environment isolation.

- pipx is made specifically for application installation, as it adds isolation yet still makes the apps available in your shell: pipx creates an isolated environment for each application and its associated packages.

## Setup

### Installation

We can use the following command to install pipx.

```bash
brew install pipx
pipx ensurepath
```

### Install Python Packages

To install Python packages, we can use the following command.

```bash
pipx install <package>
```

We recommend using pipx to install only development-required or system-level repositories.
