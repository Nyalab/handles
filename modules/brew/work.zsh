#!/usr/bin/env zsh

brew install node
brew install yarn
brew install pnpm
brew install n
sudo mkdir -p /usr/local/n
sudo chown -R $(whoami) /usr/local/n
sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share

brew install autojump # easy `j` command for dir jumping
brew install bat # better cat
brew install exa # better ls
brew install thefuck # correct and rerun last command
brew install croc # share file through cli
brew install btop # monitor computer ressources
brew install httpie # better curl
brew install rustup # rust
if ! type "rustup" >/dev/null; then
    rustup-init
fi
brew install ansible

brew install --cask visual-studio-code
brew install --cask insomnia # for testing apis
brew install --cask postbird # for exploring databases
brew install --cask sketch
brew install --cask sizzy
brew install --cask figma
brew install --cask kap # screen recorder
brew install --cask zeplin
brew install --cask fig

brew install --cask homebrew/cask-versions/firefox-developer-edition
brew install --cask google-chrome
brew install --cask safari-technology-preview
brew install --cask arc

brew install --cask discord
brew install --cask slack

brew tap homebrew/cask-fonts
brew install --cask font-fantasque-sans-mono
brew install --cask font-fira-code
brew install --cask font-lato
brew install --cask font-open-sans
brew install --cask font-open-sans-condensed
brew install --cask font-roboto
brew install --cask font-cascadia

# python issue https://holgr.com/python-3-in-macos-catalina-fixing-the-abort-trap/
