#!/usr/bin/env zsh

# can be upgraded with https://gist.github.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb

alias d='docker'
alias dc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcex='docker compose exec'
alias dcs='docker compose stop'
alias dins='docker inspect'
alias dim='docker images'
alias dps='docker ps'
alias dpsf='docker ps --format "table {{ .ID }}\t{{.Image}}\t{{.Status}}\t{{ .Names }}"'
alias dpsa='docker ps -a'
alias dpsaf='docker ps -a --format "table {{ .ID }}\t{{.Image}}\t{{.Status}}\t{{ .Names }}"'
