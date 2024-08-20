#!/usr/bin/env bash

# update apt
sudo apt update && sudo apt upgrade -y

# download submodules in case you forgot to clone with recursive
if [[ -z $(git submodule status) ]]; then
  git submodule update --init --recursive;
fi