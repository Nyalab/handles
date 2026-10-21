#!/usr/bin/env bash

echo "🤖 how do you want to apply the macOS settings?"
select style in "overwrite (fresh install, will erase what was before)" "backup (i have settings i would like to keep)" "just diff (print what is different)" "abort"; do
  case "$style" in
    overwrite*) install_style="overwrite" ;;
    backup* | just*) display_warning "this method is not implemented yet"; continue ;;
    abort) display_info "macOS setup aborted"; exit 1 ;;
    *) display_error "invalid choice, try again"; continue ;;
  esac
  break
done

# safari preferences are protected, the terminal needs Full Disk Access to write them
has_full_disk_access() {
  ls "$HOME/Library/Safari" >/dev/null 2>&1
}

if has_full_disk_access; then
  display_success "terminal has full disk access"
else
  display_warning "your terminal needs Full Disk Access (System Settings > Privacy & Security > Full Disk Access)"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

  select answer in "i did it" "i am not allowed to" "abort"; do
    case "$answer" in
      "i did it")
        # macOS only applies the permission to processes started after the change
        if ! has_full_disk_access; then
          display_error "still no access, quit and reopen your terminal, then run handles again"
          exit 1
        fi
        display_success "terminal has full disk access"
        ;;
      "i am not allowed to") display_warning "continuing without it, the safari settings will be skipped" ;;
      abort) display_info "setup aborted"; exit 1 ;;
      *) display_error "invalid choice, try again"; continue ;;
    esac
    break
  done
fi

. "$HANDLES_PATH/modules/macos/common.sh"
[[ -f "$HANDLES_PATH/modules/macos/$HANDLES_PROFILE.sh" ]] && . "$HANDLES_PATH/modules/macos/$HANDLES_PROFILE.sh"

# apps to restart so the settings above apply
for app in Dock Finder SystemUIServer; do
  killall "$app" &>/dev/null || true
done
display_success "macOS defaults applied"
display_warning "for some keyboard modifications to take effect, you need to reboot the machine completely"
