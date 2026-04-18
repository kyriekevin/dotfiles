# External CLI tool integrations. Loaded AFTER plugins.zsh so that fzf-tab
# sees fzf's keybinds before swapping the Tab completion widget.
#
# Guarded by `$+commands[...]` — these lines run at every shell startup, so
# a missing tool would emit "command not found" on every new shell. Alias
# overrides in aliases.zsh deliberately stay unguarded: they only fail when
# the user types `cat`/`ls`, where a loud error is useful signal.

# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd
if (( $+commands[fzf] )); then
    source <(fzf --zsh)
fi

# zoxide: `z foo` smart-cd, `zi` interactive
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi
