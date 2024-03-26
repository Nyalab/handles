#!/usr/bin/env bash

export HANDLES_PATH=$PWD

# check macOS version before everything else
. $HANDLES_PATH/modules/macos/check.sh

# download submodules in case you forgot to clone with recursive
if [[ -z $(git submodule status) ]]; then
  git submodule update --init --recursive;
fi

# we need to install the bare minimum
. $HANDLES_PATH/modules/brew/install.sh
. $HANDLES_PATH/modules/zsh/install.sh

# execute handles
. $HANDLES_PATH/bin/handles
