export zsh_config="$HOME/.config/zsh"

source $zsh_config/exports.zsh
source $zsh_config/aliases.zsh
source $zsh_config/funcs.zsh
source $zsh_config/tmux.zsh
source $zsh_config/cursor.zsh
source $zsh_config/fzf.zsh
source $zsh_config/plugins.zsh
source $zsh_config/catppuccin_frappe-zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

