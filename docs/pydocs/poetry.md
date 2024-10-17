# Poetry

- [Poetry](#poetry)
  - [Introduction](#introduction)
  - [Setup](#setup)
    - [System Requirements](#system-requirements)
    - [Installation](#installation)
    - [Usage](#usage)
      - [Project Setup](#project-setup)
      - [Virtual Environment](#virtual-environment)
      - [Install Python Packages](#install-python-packages)
    - [Recommend Configuration](#recommend-configuration)

## Introduction

[website](https://python-poetry.org/)

Poetry is a tool for dependency management and packaging in Python. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you.

## Setup

### System Requirements

Poetry requires Python 3.8+

So we recommend to use pyenv to create a virtual environment with Python 3.8+.

### Installation

After we create a virtual env with Python 3.8+ and install pipx, we can use the following command to install poetry.

```bash
pipx install poetry
```

### Usage

#### Project Setup

To create a new project, we can use the following command.

```bash
poetry new <project_name>
```

Also, we can use the following command to init a pre-existing project.

```bash
poetry init
```

#### Virtual Environment

Before we create a virtual environment, we can point out the version of Python we want to use.

```bash
poetry env use <python_version>
```

We can `poetry shell` to enter the virtual environment or use `poetry run <command>` to run a command in the virtual environment.

#### Install Python Packages

To install Python packages, we can use the following command.

```bash
poetry add <package>
```

For existing projects (with pyproject.toml), you can use the following command to install the Python package.

```bash
poetry install
```

### Recommend Configuration

We can use the following configuration to improve the development experience.

```bash
poetry config virtualenvs.in-project true
poetry config virtualenvs.options.no-pip true
poetry config virtualenvs.options.no-setuptools true
```
