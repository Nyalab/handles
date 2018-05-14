#!/usr/bin/env zsh

brew cask install iterm2

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HANDLES_PATH/modules/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
