#!/usr/bin/env zsh

. $HANDLES_PATH/src/helpers.sh

echo "Methods available:"
echo "    preset - use an already defined preset (for instance: minimal, work, home, ...)"
echo "    manual - pick manually what to install (useful for forcing a specific clean instal)"
echo -n "🤖 “Method choice required” > "
read method
echo ""

if [ $method = "preset" ]; then
  # echo "Configurations available:"
  # echo "    minimal - coming soon - just the bare minimum, useful for ad hoc work"
  # echo "    home - h"
  # echo "    work - w"
  # echo -n "🤖 “Configuration choice required” > "
  display_warning "Configurations coming soon, full installation for now"
  keep_sudo_alive
  $HANDLES_PATH/scripts/setups/work.zsh
else
  echo ""
fi
