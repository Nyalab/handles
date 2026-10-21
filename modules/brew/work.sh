#!/usr/bin/env bash

# software for the work profile

# cli tools
brew_install zoxide # easy `z` command for dir jumping
brew_install bat # better cat
brew_install eza # better ls
brew_install thefuck # correct and rerun last command
brew_install croc # share file through cli
brew_install btop # monitor computer ressources
brew_install httpie # better curl

# brew_install autojump # replaced by zoxide
# brew_install exa # replaced by eza (exa is unmaintained)
# brew_install rustup # rust
# if ! command_exists rustup; then rustup-init; fi
# brew_install ansible

# node package managers, probably replaced by fnm (modules/node) and corepack
# brew_install yarn
# brew_install pnpm
# brew_install n
# sudo mkdir -p /usr/local/n
# sudo chown -R "$(whoami)" /usr/local/n
# sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
# sudo chown -R "$(whoami)" /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share

# apps
# brew_cask_install warp # terminal
# brew_cask_install visual-studio-code # already installed by modules/vscode
# brew_cask_install insomnia # for testing apis (needs an account now)
# brew_cask_install figma
# brew_cask_install kap # screen recorder (barely maintained)
# brew_cask_install fig # dead, shut down after the AWS acquisition
# brew_cask_install postbird # for exploring databases (abandoned)
# brew_cask_install firefox@developer-edition # was homebrew/cask-versions/firefox-developer-edition
# brew_cask_install safari-technology-preview
# brew_cask_install arc # browser (maintenance mode)
# brew_cask_install linear-linear
# brew_cask_install discord
# brew_cask_install slack

# fonts (no tap needed anymore, homebrew/cask-fonts is deprecated)
brew_cask_install font-fantasque-sans-mono
brew_cask_install font-fira-code
brew_cask_install font-lato
brew_cask_install font-open-sans
brew_cask_install font-roboto
brew_cask_install font-cascadia-code # was font-cascadia
# brew_cask_install font-open-sans-condensed # does not exist anymore
