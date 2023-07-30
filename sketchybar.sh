#!/bin/bash

# install sketchybar
brew tap FelixKratz/formulae
brew install sketchybar

# install dependencies
brew install --cask sf-symbols
brew install jq
brew install switchaudio-osx
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.4/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

brew tap homebrew/services

# fonts
brew tap homebrew/cask-fonts
brew install font-ubuntu
brew install font-fontawesome
brew install font-hack-nerd-font
brew install font-fira-code-nerd-font
brew install --cask font-monocraft

# start sketchybar
brew services start sketchybar
