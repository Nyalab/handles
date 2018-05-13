#!/usr/bin/env bash

# download submodules in case you forgot to clone with recursive
if [[ -z $(git submodule status) ]]; then
  git submodule update --init --recursive;
fi

export HANDLES_PATH=$PWD

# we need to install the bare minimum
. $HANDLES_PATH/modules/brew/install.sh
. $HANDLES_PATH/modules/zsh/install.sh

# execute handles
. $HANDLES_PATH/bin/handles
