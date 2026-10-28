#!/usr/bin/env bash

display_info() { printf '\033[34m> info:\033[0m 🤖 %s\n' "$*"; }
display_warning() { printf '\033[33m> warning:\033[0m 🤖 %s\n' "$*"; }
display_error() { printf '\033[31m> error:\033[0m 🤖 %s\n' "$*" >&2; }
display_success() { printf '\033[32m> success:\033[0m 🤖 %s\n' "$*"; }

command_exists() {
  command -v "$1" >/dev/null 2>&1
}
