#! /bin/sh

step () {
    final=$(echo "$@")
    plus=$(expr ${#final} + 6)

    printhashtags () {
    for i in $(seq $plus); do
        printf "#"
    done

    }

    echo
    printhashtags
    echo "\n## $@ ##"
    printhashtags
    echo
}

step "Installing xcode command line tools if not already installed"
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "Xcode CLI tools not found. Installing them..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    head -n 1 | awk -F"*" '{print $2}' |
    sed -e 's/^ *//' |
    tr -d '\n')
  softwareupdate -i "$PROD" -v;
else
  echo "'xcode command line tools' is already installed, you're set."
fi

step "Installing brew if not already installed"
if ! command -v brew &> /dev/null
then
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
else
   echo "brew is already installed, you're set."
   sleep 1
fi

install () {
    if ! command -v "$@" &> /dev/null; then
       brew install "$@"
    else
       echo "'$@' is already installed, you're set."
       sleep 1
    fi
}

step "Tapping koekeishiya repo"
brew tap koekeishiya/formulae

# sketchybar
## install sketchybar
step "Installing sketchybar if not already installed"
brew tap FelixKratz/formulae
install sketchybar
install borders

## install sketchybar dependencies
step "Installing sketchybar dependencies if not already installed"
brew install --cask sf-symbols
install jq
brew install switchaudio-osx
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.4/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

## install sketchybar fonts
step "Installing sketchybar fonts if not already installed"
brew tap homebrew/cask-fonts
install font-ubuntu
install font-fontawesome
install font-hack-nerd-font
install font-fira-code-nerd-font
install --cask font-monocraft

# skhd
step "Installing skhd if not already installed"
install skhd

# yabai
step "Installing yabai if not already installed"
install yabai

# tmux
## install tmux
step "Installing tmux if not already installed"
install tmux

## install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# zsh
## ohmyzsh
mkdir -p $HOME/.config/zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ${ZSH_CUSTOM:-$HOME/.config/zsh/.oh-my-zsh}

## zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.config/zsh/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.config/zsh/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

## fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.config/zsh/.oh-my-zsh/custom}/plugins/fzf-tab

## git-open
git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-$HOME/.config/zsh/.oh-my-zsh/custom}/plugins/git-open

# install alacritty fonts
step "Installing alacritty fonts if not already installed"
install homebrew/cask-fonts/font-jetbrains-mono-nerd-font

# starship
step "Installing starship if not already installed"
install starship

# tools
step "Installing fzf if not already installed"
install fzf

step "Installing wget if not already installed"
install wget

step "Installing git if not already installed"
install git

step "Installing ranger if not already installed"
install ranger

step "Installing neovim if not already installed"
install neovim

step "Installing node if not already installed"
install node

step "Installing neofetch if not already installed"
install neofetch

step "Installing stow if not already installed"
install stow

step "Installing lazygit if not already installed"
install lazygit

step "Installing ripgrep if not already installed"
install ripgrep

step "Installing fd if not already installed"
install fd

step "Installing joshuto if not already installed"
install joshuto 

# step "Installing exa if not already installed"
# install exa

step "Installing bat if not already installed"
install bat 

step "Installing bottom if not already installed"
install bottom 

step "Installing dust if not already installed"
install dust 

step "Installing duf if not already installed"
install duf 

step "Installing tldr if not already installed"
install tldr 

step "Installing git-delta if not already installed"
install git-delta 

step "Installing trash if not already installed"
install trash

step "Installing eza if not already installed"
install eza

step "Installing blueutil if not already installed"
install blueutil 

step "Installing ifstat if not already installed"
install  ifstat

brew install --cask --no-quarantine google-chrome iterm2 qq wechat mos anaconda neovide spotify raycast fig alacritty

# start services
brew tap homebrew/services
brew services start sketchybar
yabai --start-service
skhd --start-service
