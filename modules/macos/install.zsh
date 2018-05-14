#!/usr/bin/env zsh

brew install mas

# mas signin --dialog
mas install 557168941 #Tweetdeck
mas install 992076693 #MindNode
mas install 441258766 #Magnet
mas install 409183694 #Keynote

# show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

defaults write com.apple.dock autohide 1 # auto hide the dock
defaults write com.apple.dock tilesize 40 # tile size
defaults write com.apple.dock mru-spaces 0 # don't switch spaces

mkdir ~/screenshots
defaults write com.apple.screencapture location ~/screenshots
killall SystemUIServer

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12

defaults write -globalDomain NSAutomaticCapitalizationEnabled -int 0
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -int 0
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -int 0
