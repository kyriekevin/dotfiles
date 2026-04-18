# External CLI tool integrations. Loaded AFTER plugins.zsh so that fzf-tab
# sees fzf's keybinds before swapping the Tab completion widget.

# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd
source <(fzf --zsh)

# zoxide: `z foo` smart-cd, `zi` interactive
eval "$(zoxide init zsh)"
