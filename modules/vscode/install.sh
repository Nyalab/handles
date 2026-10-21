#!/usr/bin/env bash

brew_cask_install visual-studio-code

user_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$user_dir"

. "$HANDLES_PATH/src/config.sh"
config_run apply vscode

# link a file or folder of this module into the vscode user dir, backing up what was there
link_config() {
  local source="$HANDLES_PATH/modules/vscode/$1"
  local target="$user_dir/$1"

  if [[ "$(readlink "$target")" == "$source" ]]; then
    display_success "$1 is already linked"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    mv "$target" "$target.bak"
    display_warning "existing $1 moved to $1.bak"
  fi

  ln -s "$source" "$target"
  display_success "$1 linked"
}

# git does not track empty folders, and snippets created from vscode must land in the repo
mkdir -p "$HANDLES_PATH/modules/vscode/snippets"

for config in settings.json keybindings.json snippets; do
  link_config "$config"
done

installed="$(code --list-extensions)"

while read -r extension; do
  [[ -z "$extension" || "$extension" == \#* ]] && continue

  # extension ids are case insensitive
  if grep -qix "$extension" <<<"$installed"; then
    display_success "$extension already installed"
  else
    display_info "installing $extension"
    if ! code --install-extension "$extension" >/dev/null; then
      display_error "failed to install $extension; check network access and the private environment for your profile"
      exit 1
    fi
  fi
done <"$HANDLES_PATH/modules/vscode/extensions.txt"
