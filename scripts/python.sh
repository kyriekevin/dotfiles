#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/common.sh"

step "Installing uv if not already installed"
install uv

uv tool install ruff
uv tool install pre-commit
uv tool install commitizen
