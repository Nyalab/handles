#!/usr/bin/env bash

export HANDLES_PATH=$PWD

uname="$(uname -s)"
echo "$uname"
if [[ "$uname" == "Linux" ]]; then
  . $HANDLES_PATH/installs/wsl.sh
elif [[ "$uname" == "Darwin" ]]; then
  . $HANDLES_PATH/installs/macos.sh
fi

# execute handles
. $HANDLES_PATH/bin/handles
