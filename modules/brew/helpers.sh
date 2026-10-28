#!/usr/bin/env bash

brew_install() {
  if brew list "$@" >/dev/null 2>&1; then
    display_success "$* already installed"
  else
    display_info "installing $*"
    brew install "$@"
  fi
}

brew_cask_install() {
  if brew list --cask "$@" >/dev/null 2>&1; then
    display_success "$* already installed"
  else
    display_info "installing $*"
    # --adopt lets brew take over an app already in /Applications instead of failing
    brew install --cask --adopt "$@"
  fi
}
