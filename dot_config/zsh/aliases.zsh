# ─── Shell basics ────────────────────────────────────────────────────
alias c='clear'
alias p='pwd'
alias e='exit'

# ─── Git (lightweight wrappers — use `lg` / lazygit for interactive) ──
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias ga='git add'
alias gaa='git add --all'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'

# ─── Apps ────────────────────────────────────────────────────────────
alias lg='lazygit'
alias nv='nvim'
alias s='fastfetch'

# ─── File tools (override POSIX defaults with eza/bat) ───────────────
alias cat='bat'
alias ls='eza'
alias l='eza -l'
alias ll='eza -lah'
