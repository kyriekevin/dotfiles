# quickly edit and source .zshrc
alias sz="source ~/.zshrc; echo '~/.zshrc sourced'"

# tmux
alias tl="tmux ls"
alias ta="tmux attach -t"
alias ts="tmux new -s"
alias tkss="tmux kill-session -t"

# neovim
alias nv="NVIM_APPNAME=LazyVim nvim"
alias lc="NVIM_APPNAME=LazyVim nvim leetcode.nvim"
alias nv-lazy="NVIM_APPNAME=LazyVim nvim"
alias nv-nvchad="NVIM_APPNAME=NvChad nvim"
alias nv-astro="NVIM_APPNAME=Astro nvim"
alias nv-kickstart="NVIM_APPNAME=kickstart nvim"

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

alias ll="eza --icons -lah"
alias l="eza --icons"
alias ls="eza --icons"
 
alias av="conda activate"
alias dv="conda deactivate"

alias top=btm

alias dir="create_and_cd"

# IP alias and functions
alias ip="get_ip"
alias ipl="get_ip_local"
