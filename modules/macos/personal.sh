#!/usr/bin/env bash

# macOS settings that only apply to a personal machine, on top of common.sh

# computer names from private/env.personal.sh
if [[ -n "${MACOS_COMPUTER_NAME:-}" ]]; then
  sudo scutil --set ComputerName "$MACOS_COMPUTER_NAME"
fi
if [[ -n "${MACOS_HOST_NAME:-}" ]]; then
  sudo scutil --set HostName "$MACOS_HOST_NAME"
fi
if [[ -n "${MACOS_LOCAL_HOST_NAME:-}" ]]; then
  sudo scutil --set LocalHostName "$MACOS_LOCAL_HOST_NAME"
fi
if [[ -n "${MACOS_NETBIOS_NAME:-}" ]]; then
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$MACOS_NETBIOS_NAME"
fi

# app store apps to install, kept as a reference list (needs `brew install mas` and an App Store sign-in)
# mas install 409183694 # Keynote
# mas install 1470584107 # Dato
# mas install 957810159 # Raindrop.io for Safari
# mas install 1575588022 # MenuBarX
# mas install 1607635845 # Velja
# mas install 992076693 # MindNode (disabled in legacy)
# mas install 1480882940 # Aerate (disabled in legacy)

display_info "look at the end of modules/macos/personal.sh to remember installing these App Store apps"
