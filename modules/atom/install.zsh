#!/usr/bin/env zsh

brew cask install atom

ln -s $HANDLES_PATH/atom/config $HOME/.atom

apminstall package-sync
