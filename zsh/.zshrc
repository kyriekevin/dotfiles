# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
export zsh_config="$HOME/.config/zsh"

source $zsh_config/theme.zsh
source $zsh_config/exports.zsh
source $zsh_config/envs.zsh
source $zsh_config/aliases.zsh
source $zsh_config/funcs.zsh
source $zsh_config/tmux.zsh
source $zsh_config/plugins.zsh
source $zsh_config/cursor.zsh
source $zsh_config/fzf.zsh
source $zsh_config/brew_source.zsh

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
