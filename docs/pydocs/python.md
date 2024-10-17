# Python

- [Python](#python)
  - [Instructions](#instructions)
    - [System Info](#system-info)
    - [Python version management](#python-version-management)
    - [Python Packages management](#python-packages-management)
      - [pipx](#pipx)
      - [poetry](#poetry)
  - [IDE](#ide)

## Instructions

### System Info

```plaintext
System: macOS Sequoia Version 15.0.1
Chip: Apple M2 Max
Memory: 32 GB
Python: pyenv 3.9.18
```

### Python version management

It is recommended to use pyenv to manage multiple Python versions on macOS and Linux systems, and miniconda to manage multiple Python versions on Windows.

More information can be found in the [pyenv doc](./pyenv.md)

### Python Packages management

#### pipx
For global or development-required Python libraries, it is recommended to use pipx installation. As a result, the global Python libraries are isolated from each other and the global Python libraries can be used in multiple projects.

More information can be found in the [pipx doc](./pipx.md)

#### poetry

For each independent project, it is recommended to use poetry to manage it. Create an independent .venv environment under each project, use pyenv to select the python version, and use the libraries installed by pipx (such as black, isort, etc.) for development.

More information can be found in the [poetry doc](./poetry.md)

## IDE

For Python development, I often use it in AI model training and data science analysis. Therefore, I mainly use ipynb for data processing and analysis, and py for model training and general function writing.

Vscode and Neovim are my commonly used IDEs.
- For vscode, it is convenient to run in ipynb, but its support for vim is not friendly enough.
- For neovim, you can have a smooth coding experience through configuration, but I have not found a perfect way to run ipynb.

I recommend using vscode with simple plug-ins, which can give you a better experience without having to adapt and test every plug-in.

For more information about IDE, please refer to the subsequent IDE configuration documents.
