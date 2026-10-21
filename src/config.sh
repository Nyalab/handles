#!/usr/bin/env bash

config_unchanged() {
  if [[ -f "$2" ]]; then
    [[ -f "$1" && ! -L "$1" ]] && cmp -s "$1" "$2"
  else
    [[ ! -e "$1" && ! -L "$1" ]]
  fi
}

config_run() (
  set -euo pipefail
  umask 077

  if [[ $# -ne 2 || ( "$1" != export && "$1" != apply ) ]]; then
    display_error "usage: ./handles config <export|apply> <module>"
    exit 1
  fi

  operation="$1" module="$2"
  if [[ ! "$module" =~ ^[a-zA-Z0-9_-]+$ || ! -f "$HANDLES_PATH/modules/$module/config.sh" ]]; then
    display_error "unknown config module: $module"
    exit 1
  fi

  config_adapter="" config_live="" config_public=""
  config_private_keys=()
  . "$HANDLES_PATH/modules/$module/config.sh"

  if [[ -z "$config_live" || -z "$config_public" || "$config_live" == "$config_public" ]]; then
    display_error "$module must declare separate live and public config files"
    exit 1
  fi

  case "$config_adapter" in
    jsonc) adapter="$HANDLES_PATH/src/adapters/jsonc.mjs" ;;
    *)
      display_error "unknown config adapter: $config_adapter"
      exit 1
      ;;
  esac

  if ! command_exists node || [[ ! -d "$HANDLES_PATH/node_modules/jsonc-parser" ]]; then
    display_error "config commands need Node and handles dependencies; run npm ci in $HANDLES_PATH"
    exit 1
  fi

  for file in "$config_live" "$config_public"; do
    if [[ -L "$file" || ( -e "$file" && ! -f "$file" ) ]]; then
      display_error "declared config files must be regular files, not symlinks or directories: $file"
      exit 1
    fi
  done

  if [[ "$operation" == export && ! -f "$config_live" ]]; then
    display_error "live config is missing: $config_live"
    exit 1
  fi
  if [[ "$operation" == apply && ! -f "$config_public" ]]; then
    display_error "public config is missing: $config_public"
    exit 1
  fi

  destination="$config_public"
  [[ "$operation" == apply ]] && destination="$config_live"
  mkdir -p "$(dirname "$destination")"

  temporary="$(mktemp -d "$(dirname "$destination")/.handles-config.XXXXXX")"
  trap 'rm -f "$temporary/live" "$temporary/public" "$temporary/output"; rmdir "$temporary"' EXIT

  [[ ! -f "$config_live" ]] || cp "$config_live" "$temporary/live"
  [[ ! -f "$config_public" ]] || cp "$config_public" "$temporary/public"

  if ! node "$adapter" "$operation" "$temporary/live" "$temporary/public" \
    ${config_private_keys[@]+"${config_private_keys[@]}"} >"$temporary/output"; then
    display_error "$module config $operation failed; config files are unchanged"
    exit 1
  fi

  if ! config_unchanged "$config_live" "$temporary/live" ||
    ! config_unchanged "$config_public" "$temporary/public"; then
    display_error "$module config changed during $operation; nothing was written, retry when edits have stopped"
    exit 1
  fi

  if [[ -f "$destination" ]] && cmp -s "$temporary/output" "$destination"; then
    display_success "$module config is already current"
    exit 0
  fi

  mv -f "$temporary/output" "$destination"
  display_success "$module config $operation completed"
)
