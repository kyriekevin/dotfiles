# Environment variables. Pure exports + brew shellenv — no tool init, no aliases.

# Homebrew: prepends brew bin + manpath + infopath. Apple Silicon path.
eval "$(/opt/homebrew/bin/brew shellenv)"

# bat color theme
export BAT_THEME="Catppuccin Frappe"

# Hugging Face mirror (大陆网络)
export HF_ENDPOINT="https://hf-mirror.com"

# claude-hud compact mode needs real TTY width in the statusLine subprocess.
# See https://github.com/jarrodwatts/claude-hud/issues/408
export COLUMNS=$(tput cols 2>/dev/null || echo 200)
