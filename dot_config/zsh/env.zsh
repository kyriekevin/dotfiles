# Environment variables. Pure exports + brew shellenv — no tool init, no aliases.

# Homebrew: prepend brew bin + manpath + infopath.
# Defensive form mirrors .chezmoiscripts/run_onchange_after_20-brew-bundle.sh —
# Apple Silicon first, Intel fallback, silent if neither is present.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Re-prepend ~/.local/bin so user shims win over brew.
# brew shellenv unconditionally puts /opt/homebrew/bin first, which demotes the
# ~/.local/bin entry that zshenv already added.
# typeset -U keeps PATH unique, so re-sourcing this file can't pile up duplicates.
typeset -U path PATH
export PATH="$HOME/.local/bin:$PATH"

# bat color theme — matches starship palette (catppuccin_mocha) for repo-wide consistency.
export BAT_THEME="Catppuccin Mocha"

# Hugging Face mirror (大陆网络)
export HF_ENDPOINT="https://hf-mirror.com"

# claude-hud compact mode needs real TTY width in the statusLine subprocess.
# See https://github.com/jarrodwatts/claude-hud/issues/408
export COLUMNS=$(tput cols 2>/dev/null || echo 200)
