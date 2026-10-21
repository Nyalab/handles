#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
  display_error "usage: ./handles config <export|apply> <module>"
  exit 1
fi

. "$HANDLES_PATH/src/config.sh"
config_run "$1" "$2"
