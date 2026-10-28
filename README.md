# handles

A daily assistant to set up and maintain my machine.

## installation

```shell
git clone https://github.com/Nyalab/handles.git
# macOS will ask you to install some XCode stuff, just agree
cd handles && ./handles
```

## private configuration

VS Code points to `modules/vscode/settings.json`, a complete local file ignored by
Git. Only `modules/vscode/settings.public.json` is versioned.

Setup installs the Node dependency with `npm ci` and applies the public settings
before linking VS Code to the local file. Existing local private settings are kept;
a fresh machine starts without them, so enter those values locally.

After editing settings in VS Code:

```shell
./handles config export vscode
git diff -- modules/vscode/settings.public.json
```

Commit and push the public file yourself. After pulling changes on another machine:

```shell
./handles config apply vscode
```

Apply replaces all local public settings, including unexported edits, and preserves
only the excluded settings from the existing local file. Close VS Code before
applying: handles checks for concurrent edits and writes atomically, but cannot lock
out the editor. Export never writes the local file. Neither operation runs Git.

Run `npm ci` in the repository before using these commands if setup has not installed
the dependency yet. Run `npm test` for temporary-file tests; no machine setup runs.

### module declarations and adapters

`modules/vscode/config.sh` declares the adapter, live/public file pair and private
keys. Another module can use the same declaration shape with its own paths:

```bash
config_adapter=jsonc
config_live="$HANDLES_PATH/modules/example/settings.json"
config_public="$HANDLES_PATH/modules/example/settings.public.json"
config_private_keys=(
  company.setting
)
```

Declare regular files inside the repository, not symlinks; the application's
configuration symlink points to the live file. Add each new live path to
`.gitignore` before exporting. Ignore rules do not untrack already tracked files.

The shared Bash helper handles snapshots, change detection and atomic writes.
`src/adapters/jsonc.mjs` handles JSONC parsing and transformation. Its exclusions are
literal top-level property names: dots in VS Code keys do not indicate nesting.
It preserves comments and commented-out alternatives, but normalizes formatting.
Comments immediately above a private property, comments inside its value, and
same-line trailing comments are private too. Comments above the opening `{` and
standalone comments after the last property are not attached to a setting.

This is explicit filtering, not secret detection: new keys are public by default.
Review the exported file, including comments. Apply rejects public files containing
an excluded key, invalid JSONC and duplicate top-level keys rather than guessing.
Hooks, scheduling, nested exclusions and multiple file pairs per module are not
implemented.

## local-only files

`private/` holds local configuration that must not be published. Everything inside
is Git-ignored except the empty `.gitkeep`, so a clone includes the directory but
none of its private contents.

Usually, you will have some of these files, depending on the machine's profile:

| File | Purpose | Required |
|------|---------|----------|
| `private/gitconfig.work-identity` | Work Git name and email | Yes, for work setup |
| `private/gitconfig.personal-identity` | Personal Git identity | Yes, for personal setup; optional on work machines |
| `private/env.work.sh` | Work-only environment exports | Only when needed locally |
| `private/env.personal.sh` | Personal environment exports, including computer names | Only when needed locally |

Supply these files separately on a fresh machine. Setup loads the optional
`private/env.<profile>.sh` before running installers. The installed `~/.zshrc`
block loads the same file in new terminals; personal setup does not load
`env.work.sh`. These are trusted Bash/Zsh-compatible shell scripts, not parsed
data files. Keep private explanations in them too.

### Git identities

Each profile includes `private/gitconfig.<profile>-identity`. On work machines,
repositories under `~/dev/personal/` use the private personal identity when it
exists; otherwise, they keep the work identity.

Before setting up a fresh machine, create the selected profile's private identity:

```shell
profile=personal # use work for the work identity
identity="private/gitconfig.$profile-identity"
touch "$identity"
chmod 600 "$identity"
git config --file "$identity" user.name "Your Name"
git config --file "$identity" user.email "you@example.com"
```

The Git module stops before making changes if the selected profile's identity
file or either identity field is missing. It does not require the other profile's
identity. Moving the configuration into `private/` does not hide author names or
emails already stored in Git commits, or change the identity used for new commits.

### profile environment

Create `private/env.work.sh` with the exports your work machine needs, and restrict
its permissions with `chmod 600 private/env.work.sh`. No work-specific environment
values or tool-specific handling belong in the public scripts.

For personal machines, `private/env.personal.sh` can export `MACOS_COMPUTER_NAME`,
`MACOS_HOST_NAME`, `MACOS_LOCAL_HOST_NAME`, and `MACOS_NETBIOS_NAME`. Setup applies
only the names you supply; unset or empty values leave the existing names unchanged.
Keep this private file permission-restricted too (`chmod 600`).

## dev

```shell
git remote set-url origin git@github.com:Nyalab/handles.git
```

- The old version lives on the `legacy` branch (tag `legacy-v1`).
- Open items are in [docs/TODO.md](docs/TODO.md).
