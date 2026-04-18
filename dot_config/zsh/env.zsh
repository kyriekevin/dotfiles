# Environment variables. Pure exports + brew shellenv — no tool init, no aliases.

# Homebrew: prepend brew bin + manpath + infopath.
# Defensive form mirrors .chezmoiscripts/run_onchange_after_20-brew-bundle.sh —
# Apple Silicon first, Intel fallback, silent if neither is present.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# bat color theme — matches starship palette (catppuccin_mocha) for repo-wide consistency.
export BAT_THEME="Catppuccin Mocha"

# Hugging Face mirror (大陆网络)
export HF_ENDPOINT="https://hf-mirror.com"

# claude-hud compact mode needs real TTY width in the statusLine subprocess.
# See https://github.com/jarrodwatts/claude-hud/issues/408
export COLUMNS=$(tput cols 2>/dev/null || echo 200)
