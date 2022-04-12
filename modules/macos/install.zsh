#!/usr/bin/env zsh

brew install mas

# mas signin --dialog
mas install 557168941 #Tweetbot
mas install 992076693 #MindNode
mas install 441258766 #Magnet
mas install 409183694 #Keynote
mas install 1470584107 #Dato
mas install 957810159 #Raindrop.io for Safari
mas install 1480882940 #Aerate
mas install 1475897096 #Jira
mas install 1448916662 #Step Two
mas install 1611378436 #Pure Paste

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
