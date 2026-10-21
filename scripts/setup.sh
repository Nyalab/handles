#!/usr/bin/env bash

profiles=(work personal custom)

echo "🤖 which profile?"
select profile in "${profiles[@]}"; do
  case "$profile" in
    work | personal)
      # modules read it to load their profile specific files
      export HANDLES_PROFILE="$profile"
      . "$HANDLES_PATH/profiles/$profile.sh"
      ;;
    custom) display_warning "$profile profile is not implemented yet" ;;
    *) display_error "invalid choice, try again"; continue ;;
  esac
  break
done
