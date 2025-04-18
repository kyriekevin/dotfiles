# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fzf
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

# bat
export BAT_THEME="Catppuccin Frappe"

# HF-ENDPOINT
export HF_ENDPOINT=https://hf-mirror.com

export EDITOR="nvim"

export PATH=$HOME"/.local/bin:$PATH"
