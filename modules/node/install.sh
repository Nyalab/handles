#!/usr/bin/env bash

# fnm is a version manager: one node per project (.node-version / .nvmrc)
brew_install fnm

eval "$(fnm env)"

if fnm list | grep -q lts; then
  display_success "node LTS already installed"
else
  display_info "installing node LTS"
  fnm install --lts
fi

fnm default lts-latest >/dev/null
display_success "node $(node -v) is the default"

display_info "installing handles dependencies"
if ! npm ci --prefix "$HANDLES_PATH" --ignore-scripts --no-audit --no-fund; then
  display_error "failed to install handles dependencies"
  exit 1
fi
