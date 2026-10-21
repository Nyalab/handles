#!/usr/bin/env bash

# colima runs the linux VM and the docker daemon, instead of Docker Desktop (heavy, paid for companies)
brew_install colima

# cli only: no daemon, no Docker Desktop. colima exposes its socket through a docker context
brew_install docker

# `docker compose` is a plugin, not part of the docker formula
brew_install docker-compose

docker_config="$HOME/.docker/config.json"
plugins_dir="$(brew --prefix)/lib/docker/cli-plugins"

if grep -qF "cliPluginsExtraDirs" "$docker_config" 2>/dev/null; then
  display_success "$docker_config already lists extra cli plugin dirs"
elif [[ -e "$docker_config" ]]; then
  display_warning "$docker_config exists, add \"cliPluginsExtraDirs\": [\"$plugins_dir\"] to it for \`docker compose\`"
else
  display_info "pointing docker to the brew cli plugins ($plugins_dir)"
  mkdir -p "$(dirname "$docker_config")"
  printf '{\n  "cliPluginsExtraDirs": ["%s"]\n}\n' "$plugins_dir" >"$docker_config"
fi

# tools from the legacy docker module
brew_install dive # explore the layers of an image

if npm list -g --depth=0 dockly >/dev/null 2>&1; then
  display_success "dockly already installed"
else
  display_info "installing dockly"
  npm install -g dockly # terminal ui for containers
fi

display_info "colima is not started automatically: run \`colima start\` when you need docker"
