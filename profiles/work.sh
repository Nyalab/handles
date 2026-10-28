#!/usr/bin/env bash

# modules whose zshrc is sourced from ~/.zshrc (see modules/zsh/install.sh), read when common.sh runs
zshrc_modules=(docker)

. "$HANDLES_PATH/profiles/common.sh"
