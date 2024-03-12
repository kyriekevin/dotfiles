# quickly edit and source .zshrc
alias vz="nvim ~/.dotfiles/zsh/.zshrc"
alias sz="source ~/.zshrc; echo '~/.zshrc sourced'"
alias vn="nvim ~/.dotfiles/nvim/.config/nvim/init.lua"

# tmux
alias tl="tmux ls"
alias ta="tmux attach -t"
alias ts="tmux new -s"
alias tkss="tmux kill-session -t"

# run other app
alias ra=ranger
alias jo=joshuto
alias t=tmux
alias s=neofetch
alias lg=lazygit
alias go="git open"

# other useful alias
alias rmm="trash" # brew install trash

alias pw="sudo poweroff"
alias rb="sudo reboot"

alias p=pwd
# https://askubuntu.com/a/473770
alias c="clear && printf '\e[3J'"
alias cpwd="pwd | pbcopy && echo Current path has been copied to clipboard!"
alias e=exit
alias cat=bat
alias cp="cp -i"

alias ll="exa --icons -lah"
alias l="exa --icons"
alias ls="exa --icons"

alias av="conda activate"
alias dv="conda deactivate"

alias nv=nvim
alias ne=neovide

alias top=btm

alias dir="create_and_cd"

# IP alias and functions
alias ip="get_ip"
alias ipl="get_ip_local"
