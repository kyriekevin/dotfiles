# zinit Turbo-mode plugin loader.
#
# Turbo (`wait lucid`): plugins load AFTER the first prompt renders, async.
# Cold-start cost moves off the critical path → `time zsh -i -c exit` drops
# ~300-500ms vs oh-my-zsh-style synchronous loading.
#
# Ordering rules inside the `for` block:
#   1. completions registers its own fpath entries (blockf protects fpath)
#   2. atinit on fzf-tab triggers zicompinit — compinit then picks up
#      completions from step 1, and fzf-tab loads against a ready widget set
#   3. autosuggestions loads; atload starts the daemon
#   4. syntax-highlighting MUST be last — it wraps all preceding widgets,
#      so anything loaded after it gets left out of highlighting

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Defensive: the chezmoi hook clones zinit on apply, but support a cold
# `zsh` before first apply by self-installing here too.
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Synchronous — vi-mode must be live on the first keypress
zinit snippet OMZP::vi-mode

# Async — everything else
zinit wait lucid for \
    blockf \
        zsh-users/zsh-completions \
    atinit"zicompinit; zicdreplay" \
        Aloxaf/fzf-tab \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting
