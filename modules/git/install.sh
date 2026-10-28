#!/usr/bin/env bash

git_dir="$HANDLES_PATH/modules/git"

profile_identity="$HANDLES_PATH/private/gitconfig.$HANDLES_PROFILE-identity"
if [[ ! -f "$profile_identity" ]]; then
  display_error "$HANDLES_PROFILE Git identity is missing: $profile_identity (see README.md)"
  exit 1
fi
for key in user.name user.email; do
  if ! git config --file "$profile_identity" --get "$key" '.' >/dev/null; then
    display_error "$HANDLES_PROFILE Git identity must define a non-empty $key: $profile_identity (see README.md)"
    exit 1
  fi
done

brew_install git
# pager for git diffs, configured in gitconfig (core.pager)
brew_install git-delta
# GitHub CLI, also handles authentication (gh auth login)
brew_install gh

# managed block: only these lines are owned by handles, the rest of ~/.gitconfig is yours
# (identity, work values, anything `git config --global` writes). The block is appended at the
# end, so the versioned config wins over the same keys set above it. It includes the profile
# gitconfig, which itself includes the shared one first, and is rewritten when the profile changes.
begin="# >>> handles >>>"
end="# <<< handles <<<"
gitconfig="$HOME/.gitconfig"

block="$(printf '%s\n[include]\n\tpath = %s/gitconfig.%s\n%s' "$begin" "$git_dir" "$HANDLES_PROFILE" "$end")"

if grep -qF "$begin" "$gitconfig" 2>/dev/null; then
  if [[ "$(sed -n "/^$begin\$/,/^$end\$/p" "$gitconfig")" == "$block" ]]; then
    display_success "~/.gitconfig already includes handles ($HANDLES_PROFILE)"
  else
    # drop the old block, then append the new one
    tmp="$(mktemp)"
    sed "/^$begin\$/,/^$end\$/d" "$gitconfig" >"$tmp"
    printf '%s\n' "$block" >>"$tmp"
    cat "$tmp" >"$gitconfig"
    rm -f "$tmp"
    display_success "~/.gitconfig include updated to the $HANDLES_PROFILE profile"
  fi
else
  printf '\n%s\n' "$block" >>"$gitconfig"
  display_success "~/.gitconfig now includes handles ($HANDLES_PROFILE)"
fi

# git reads ~/.config/git/ignore as the global ignore file when core.excludesfile is not set,
# so the link works wherever the repo lives
ignore_source="$git_dir/gitignore_global"
ignore_target="$HOME/.config/git/ignore"
mkdir -p "$(dirname "$ignore_target")"

if [[ "$(readlink "$ignore_target")" == "$ignore_source" ]]; then
  display_success "global gitignore is already linked"
else
  if [[ -e "$ignore_target" || -L "$ignore_target" ]]; then
    mv "$ignore_target" "$ignore_target.bak"
    display_warning "existing global gitignore moved to ignore.bak"
  fi
  ln -s "$ignore_source" "$ignore_target"
  display_success "global gitignore linked"
fi
