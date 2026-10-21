# constraints

## Local environment

Machine-specific environment exports belong in `private/env.<profile>.sh`.
Setup loads this optional file before running installers, and the managed
`~/.zshrc` block loads the same file for new terminal sessions.

Keep private environment constraints and explanations in those ignored files,
not in versioned documentation. Public code consumes their exported environment
without knowing the machine-specific values.
