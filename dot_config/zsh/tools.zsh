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

# starship: prompt. Must init AFTER plugins.zsh so OMZP::vi-mode's
# KEYMAP hook is in place — otherwise `vimcmd_symbol` won't fire on Esc.
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

# yazi: `y` drops you into the TUI and, on quit, cd's the outer shell
# to wherever yazi last was. This is the canonical shell integration
# from https://yazi-rs.github.io/docs/quick-start — keeps yazi usable
# as a fuzzy cd tool, not just a viewer.
#
# `command cat` bypasses our `cat=bat` alias (see aliases.zsh) so the
# temp file is read raw, not prettified.
if (( $+commands[yazi] )); then
    y() {
        local tmp cwd
        tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [[ -n $cwd && $cwd != "$PWD" ]]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi
