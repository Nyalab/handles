#!/usr/bin/env bash

# settings are grouped by topic, uncomment a line to enable it

# finder
defaults write com.apple.finder AppleShowAllFiles -bool true # show hidden files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true # show file extensions
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # search the current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true # open a window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 # sidebar icons: medium
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true # save panels expanded
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# keyboard and cursor
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true # natural scrolling, already the default
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # repeat keys instead of the accent popup
defaults write NSGlobalDomain KeyRepeat -int 1 # 1 => 15ms
defaults write NSGlobalDomain InitialKeyRepeat -int 12
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock mru-spaces -bool false
# defaults write com.apple.dock persistent-apps -array # removes every app pinned to the dock

# security
# defaults write com.apple.screensaver askForPassword -int 1 # require the password after sleep or screen saver
# defaults write com.apple.screensaver askForPasswordDelay -int 0 # ...immediately

# safari (writing to com.apple.Safari needs Full Disk Access for the terminal)
defaults write com.apple.Safari IncludeDevelopMenu -bool true || display_warning "safari: needs Full Disk Access, skipped"
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true || display_warning "safari: needs Full Disk Access, skipped"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true # inspect element in every web view

# screenshots (macOS 27 reads the per-type location-* keys, the old `location` key is ignored)
mkdir -p "$HOME/screenshots"
defaults write com.apple.screencapture location-screenshot -string "~/screenshots"
defaults write com.apple.screencapture location-screenrecording -string "~/screenshots"
defaults write com.apple.screencapture show-thumbnail -bool true

# terminal: new windows and tabs open in the home folder, not in the current one (restart Terminal.app to apply)
defaults write com.apple.Terminal NewWindowWorkingDirectoryBehavior -bool false
defaults write com.apple.Terminal NewTabWorkingDirectoryBehavior -bool false

# other
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
