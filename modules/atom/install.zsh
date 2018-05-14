#!/usr/bin/env zsh

brew cask install atom

ln -sfn $HANDLES_PATH/modules/atom/config $HOME/.atom

apm install package-sync
