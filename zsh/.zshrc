export ZSH="$HOME/.oh-my-zsh"
export ZSH_CONFIG="$HOME/.config/zsh"

source $ZSH_CONFIG/plugins.zsh
source $ZSH_CONFIG/export.zsh
source $ZSH_CONFIG/func.zsh

if [[ -f "$ZSH_CONFIG/private.zsh" ]]; then
    source $ZSH_CONFIG/private.zsh
fi

source $ZSH/oh-my-zsh.sh

source $ZSH_CONFIG/alias.zsh

eval "$(starship init zsh)"
