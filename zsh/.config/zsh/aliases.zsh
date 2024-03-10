# quickly edit and source .zshrc
alias vz="nvim ~/.dotfiles/zsh/.zshrc"
alias sz="source ~/.zshrc; echo '~/.zshrc sourced'"
alias vn="nvim ~/.dotfiles/nvim/.config/nvim/init.lua"

# git
alias ga="git add"
alias gaa="git add --all"
alias gst="git status"
alias gl="git pull"
alias gc="git commit"
alias gb="git branch"
alias gd="git diff"
alias gp="git push"

# run other app
alias ra=ranger
alias t=tmux
alias s=neofetch
alias lg=lazygit
alias tl=tldr

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
