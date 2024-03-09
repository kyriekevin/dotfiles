export zsh_config="$HOME/.config/zsh"

source $zsh_config/exports.zsh
source $zsh_config/envs.zsh
source $zsh_config/aliases.zsh
source $zsh_config/funcs.zsh
source $zsh_config/tmux.zsh
source $zsh_config/cursor.zsh
source $zsh_config/fzf.zsh

eval "$(starship init zsh)"
