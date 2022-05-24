#!/usr/bin/env zsh

osascript -e 'tell application "System Preferences" to quit'


brew install mas

# mas signin --dialog
mas install 992076693 #MindNode
mas install 409183694 #Keynote
mas install 1470584107 #Dato
mas install 957810159 #Raindrop.io for Safari
mas install 1480882940 #Aerate
mas install 1448916662 #Step Two
mas install 1575588022 #MenuBarX
mas install 1607635845 #Velja
mas install 517914548 #Dashlane

# set computer name
sudo scutil --set ComputerName "Nyalab's Macbook"
sudo scutil --set HostName "Nyalab's Macbook"
sudo scutil --set LocalHostName "nyalab-macbook"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "Nyalab's Macbook"

### FINDER
# show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles -bool true
# show filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# show path bar
defaults write com.apple.finder ShowPathbar -bool true
# keep folders on top when you sort by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# when you search, search in folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# disable warning when you change file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# allow quitting finder
defaults write com.apple.finder QuitMenuItem -bool true
# open finder when you mount a volume
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
# set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
# save panel expanding by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# list view by default (other modes: `icnv`, `clmv`, `Flwv`)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# show ~/Library folder
chflags nohidden ~/Library
# show /Volumes folder
sudo chflags nohidden /Volumes


### KEYBOARD / CURSOR
# disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# disable automatic period
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# enable keyboard repeat when holding
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# keyboard repeat rate (1 => 15ms)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12

defaults write -globalDomain NSAutomaticCapitalizationEnabled -int 0
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -int 0
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -int 0

### DOCK
# auto hide, short animation duration, no delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock autohide-delay -float 0
# icon size
defaults write com.apple.dock tilesize -int 36
# don't switch to the most recent used space (keep order)
defaults write com.apple.dock mru-spaces -bool false
# remove dock items
defaults write com.apple.dock persistent-apps -array

### SECURITY
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0


### SAFARI
# enable develop menu & inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# context menu on web views for web inspector
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

### SCREENSHOTS
# create directory and assign it
mkdir -p ~/screenshots
defaults write com.apple.screencapture location -string "~/screenshots"
# show thumbnail after screenshot
defaults write com.apple.screencapture show-thumbnail -bool true

### OTHER
# show main view when opening activity monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true


#restart all aps
for app in "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Safari" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done
