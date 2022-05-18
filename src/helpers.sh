#!/usr/bin/env sh

# . $(cd "$(dirname "$0")"; pwd)/spinner.sh

display_info() {
  print -P "%F{blue}> info:%f 🤖 ${@}"
}
display_warning() {
  print -P "%F{yellow}> warning:%f 🤖 ${@}"
}
display_error() {
  print -P "%F{red}> error:%f 🤖 ${@}"
}
display_success() {
  print -P "%F{green}> success:%f 🤖 ${@}"
}

command_exists() {
  which $1
}

keep_sudo_alive() {
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}
