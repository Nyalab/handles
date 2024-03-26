#!/usr/bin/env bash

echo "checking macOS installed & latest versions"

macOS_installed_version=$(sw_vers -productVersion)
echo "installed macOS version: $macOS_installed_version"

# example `softwareupdate --list` output:
#
# Software Update Tool
#
# Finding available software
# Software Update found the following new or updated software:
# * Label: macOS Ventura 13.6-22G120
# 	Title: macOS Ventura 13.6, Version: 13.6, Size: 3502451K, Recommended: YES, Action: restart,
# * Label: macOS Sonoma 14.0-23A344
# 	Title: macOS Sonoma 14.0, Version: 14.0, Size: 6723051K, Recommended: YES, Action: restart,

macOS_latest_version=$(softwareupdate --list \
    | grep -Eo "Label: macOS([a-zA-Z[:space:]]+)([0-9A-Z.-]+)" `# only keep lines concerning macOS` \
    | tail -1  `# keep only the last occurence (we can be several versions behind, so multiple occurences in softwareupdate)` \
    | cut -c 7-) `# remove the "Label: " prefix`
macOS_latest_version=$(echo $macOS_latest_version_label | grep -Eo "([0-9.]+)" | head -1)
echo "latest macOS version: $macOS_latest_version"

if [[ ! -z $macOS_latest_version && $(echo "$macOS_latest_version > $macOS_installed_version" | bc) -eq 1 ]]; then
    echo "macOS version must be updated, downloading & updating now, dotfiles installation halted, you must do it again after macOS update"
    softwareupdate --install "$macOS_latest_version_label"
    echo -n "🤖 “Press <Enter> key when ready to reboot” > "
    read action
    echo ""
    if [ -z "$action" ]; then
        echo "in test, it does not reboot but will in the future"
        # reboot
    fi
    exit 1
else
    echo "macOS does not need an update, continuing"
fi
