# quickly edit and source .zshrc
alias vz="nvim ~/.dotfiles/zsh/.zshrc"
alias sz="source ~/.zshrc; echo '~/.zshrc sourced'"

# run other app
alias ra=ranger
alias t=tmux
alias n=neofetch
alias j=joshuto
alias lg=lazygit
alias du=dust

# other useful alias
alias pw=poweroff
alias rb=reboot

alias p=pwd
alias c=clear
alias cd=z

alias l="exa --icons -lah"
alias ls="exa --icons"

alias av="conda activate"
alias dv="conda deactivate"

alias cat=bat

alias nv=nvim
alias ne=neovide

alias top=btm

# IP alias and functions
alias ip="ifconfig -a | egrep -A 7 '^en0' | grep inet | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | head -n 1"
alias myip="curl -s http://checkip.dyndns.org/ | sed 's/[a-zA-Z<>/ :]//g'"

