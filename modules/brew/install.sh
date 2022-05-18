#!/usr/bin/env bash

. $HANDLES_PATH/src/helpers.sh

if ! type "brew" >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval $(/opt/homebrew/bin/brew shellenv)
fi

brew update

brew tap homebrew/cask

