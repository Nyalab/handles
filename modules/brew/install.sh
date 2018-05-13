#!/usr/bin/env bash

. $HANDLES_PATH/src/helpers.sh

if ! type "brew" >/dev/null; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
