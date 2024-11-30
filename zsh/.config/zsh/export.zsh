# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# pipx
export PATH="$PATH:$HOME/.local/bin"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# fzf
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

# bat
export BAT_THEME="Catppuccin Frappe"

# HF-ENDPOINT
export HF_ENDPOINT=https://hf-mirror.com

# vpn
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
