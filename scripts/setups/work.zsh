#!/usr/bin/env zsh

. $HANDLES_PATH/src/helpers.sh

$HANDLES_PATH/modules/brew/common.zsh
$HANDLES_PATH/modules/brew/work.zsh

$HANDLES_PATH/modules/docker/install.zsh
$HANDLES_PATH/modules/git/install.zsh
$HANDLES_PATH/modules/iterm2/install.zsh
$HANDLES_PATH/modules/macos/install.zsh
$HANDLES_PATH/modules/tldr/install.zsh
$HANDLES_PATH/modules/vim/install.zsh
$HANDLES_PATH/modules/vscode/install.zsh
