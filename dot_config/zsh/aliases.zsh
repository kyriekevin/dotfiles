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
alias cc='claude'
alias cx='codex'
alias cm='cmux'
alias am='agentmux'
alias ad='agentdesk'
alias oc='ttadk code -t opencode'

# ─── File tools (override POSIX defaults with eza/bat) ───────────────
alias cat='bat'
alias ls='eza'
alias l='eza -l'
alias ll='eza -lah'

# ─── Stay awake (system only — display still sleeps & locks) ─────────
# -ims = block idle/disk/system sleep, but NO -d/-u so the screen still
# turns off & locks (公司息屏合规). Old habit `-dimsu` kept the screen ON.
#   cafe        ad-hoc, Ctrl-C to release
#   cafe <cmd>  run <cmd>, release when it exits
alias cafe='caffeinate -ims'
