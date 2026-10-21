#!/usr/bin/env bash

brew_install zsh
brew_install zsh-completions

zsh_path="$(brew --prefix)/bin/zsh"

if grep -qx "$zsh_path" /etc/shells; then
  display_success "$zsh_path is already an allowed shell"
else
  display_info "adding $zsh_path to /etc/shells (sudo)"
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi

if [[ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" == "$zsh_path" ]]; then
  display_success "homebrew zsh is already the login shell"
else
  display_info "setting homebrew zsh as the login shell"
  chsh -s "$zsh_path"
  display_warning "restart your terminal to use the new shell"
fi

# managed block: only these lines are owned by handles, the rest of ~/.zshrc is yours.
# It loads the private environment, shared zshrc and profile modules, and is rewritten
# when the profile changes.
begin="# >>> handles >>>"
end="# <<< handles <<<"
zshrc="$HOME/.zshrc"

profile_env="$HANDLES_PATH/private/env.$HANDLES_PROFILE.sh"
block="$begin"$'\n'"if [[ -f \"$profile_env\" ]]; then"$'\n'"  source \"$profile_env\""$'\n'"fi"
block="$block"$'\n'"source \"$HANDLES_PATH/modules/zsh/zshrc\""
for module in ${zshrc_modules[@]+"${zshrc_modules[@]}"}; do
  block="$block"$'\n'"source \"$HANDLES_PATH/modules/$module/zshrc\""
done
block="$block"$'\n'"$end"

if grep -qF "$begin" "$zshrc" 2>/dev/null; then
  if [[ "$(sed -n "/^$begin\$/,/^$end\$/p" "$zshrc")" == "$block" ]]; then
    display_success "~/.zshrc already sources handles ($HANDLES_PROFILE)"
  else
    # replace the old block in place, so its position in the file is kept
    tmp="$(mktemp)"
    # the block goes through the environment because macOS awk rejects newlines in -v
    if BLOCK="$block" awk -v begin="$begin" -v end="$end" '
      $0 == begin { print ENVIRON["BLOCK"]; skip = 1; next }
      skip && $0 == end { skip = 0; next }
      !skip { print }
    ' "$zshrc" >"$tmp"; then
      cat "$tmp" >"$zshrc"
    else
      display_error "could not rewrite ~/.zshrc, it is untouched"
    fi
    rm -f "$tmp"
    display_success "~/.zshrc sources handles for the $HANDLES_PROFILE profile"
  fi
else
  printf '\n%s\n' "$block" >>"$zshrc"
  display_success "~/.zshrc now sources handles ($HANDLES_PROFILE)"
fi
