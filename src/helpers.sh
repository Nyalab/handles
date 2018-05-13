#!/usr/bin/env bash

display_info() {
  echo "info: ${@}"
}
display_warning() {
  echo "warning: ${@}"
}
display_error() {
  echo "error: ${@}"
}
command_exists() {
  which $1
}

keep_sudo_alive() {
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}
