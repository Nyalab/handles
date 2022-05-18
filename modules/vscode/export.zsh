#!/usr/bin/env zsh
. $(pwd)/../../src/helpers.sh

display_info "exporting vscode extensions"

code --list-extensions | sed -e 's/^/code --install-extension /' > ./my-extensions.zsh

if [ $? -eq 0 ]; then
    display_success "exported vscode extensions"
else
    display_error "failed to export vscode extensions"
fi

display_info "extensions file content: "
bat ./my-extensions.zsh
