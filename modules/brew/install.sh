#!/usr/bin/env bash

. "$HANDLES_PATH/modules/brew/helpers.sh"

if ! command_exists brew; then
  display_info "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # the installer does not add brew to the PATH of the current shell
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$brew_bin" ]] && eval "$("$brew_bin" shellenv)" && break
  done
fi

if ! command_exists brew; then
  display_error "homebrew installation failed"
  exit 1
fi
display_success "homebrew is installed"

. "$HANDLES_PATH/modules/brew/common.sh"
[[ -f "$HANDLES_PATH/modules/brew/$HANDLES_PROFILE.sh" ]] && . "$HANDLES_PATH/modules/brew/$HANDLES_PROFILE.sh"
