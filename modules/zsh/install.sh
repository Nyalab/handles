#!/usr/bin/env bash

. $HANDLES_PATH/src/helpers.sh

if [ $(brew list zsh &> /dev/null; printf $?) -eq 1 ]; then
  display_info "installing zsh"
  brew install zsh
  echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
  chsh -s $(brew --prefix)/bin/zsh
  display_warning "you must restart the shell session to finish the zsh installation"
fi

brew install zsh-completions
# brew install zsh-syntax-highlighting

ln -sfn $HANDLES_PATH/modules/zsh/zshrc $HOME/.zshrc
