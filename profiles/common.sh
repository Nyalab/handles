#!/usr/bin/env bash

display_info "starting the machine setup"

if [[ "$(uname -s)" != "Darwin" ]]; then
  display_error "only macOS is supported for now"
  exit 1
fi
display_success "macOS $(sw_vers -productVersion)"

profile_env="$HANDLES_PATH/private/env.$HANDLES_PROFILE.sh"
if [[ -f "$profile_env" ]]; then
  . "$profile_env"
fi

. "$HANDLES_PATH/modules/brew/install.sh"

. "$HANDLES_PATH/modules/node/install.sh"
. "$HANDLES_PATH/modules/docker/install.sh"
. "$HANDLES_PATH/modules/git/install.sh"
. "$HANDLES_PATH/modules/zsh/install.sh"
. "$HANDLES_PATH/modules/vscode/install.sh"
. "$HANDLES_PATH/modules/macos/install.sh"
