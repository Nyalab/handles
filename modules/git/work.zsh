#!/usr/bin/env zsh

echo "creating a separated professional .gitconfig"
echo -n "🤖 “Enter your professional email” > "
read email
echo ""

echo "[user]
  email = $email" > "$HOME/.gitconfig-pro"
echo "$HOME/.gitconfig-pro has been created, edit it with the custom directives you want"
