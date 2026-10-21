# AGENTS.md

## context

- This is a rewrite (v2) of my machine setup assistant. The old version is in `../handles-legacy` (a git worktree of the `legacy` branch). Read it before building anything new, and port its ideas instead of inventing.
- Open items live in `docs/TODO.md`. Add new ones there and delete them when done (only open work stays in the file).

## structure

- `./handles` is the entry point, `scripts/` has the actions (setup, ...), `modules/<name>/install.sh` installs one tool.
- Profiles (`work`, `personal`) live in `profiles/`. A shared part goes in `common.sh`, a profile specific part in `<profile>.sh`. The chosen profile is in `$HANDLES_PROFILE`.
- Keep it simple, concise bash that works with macOS bash 3.2.

## how to work with me

- Ask before any technical decision (dependencies, tools, formats, mechanisms). Never choose alone: I want to know how things work underneath.
- Porting legacy files, one group at a time (a group is a set of related settings, extensions, keybindings...):
  1. Read the legacy file and group related items.
  2. Explain each item line by line: what it does, its default, and why I probably set it (git history helps). Flag what is outdated, redundant or dead.
  3. Ask me which to activate, then wait for my answer.
  4. Apply: picked items are active, the others stay commented (never deleted), except the ones I say to drop.
  5. Move on to the next group.
- Never commit, I do it myself. The repo is public, keep secrets and private values out.
- Known public environment constraints are in `docs/constraints.md`. Add new ones there; keep private details in `private/`.

## testing

- Check syntax with `bash -n <file>`.
- Real runs change my machine and ask for my password, so do not run `./handles` yourself. Test pieces with external commands stubbed (`defaults`, `sudo`, `code`, `open`, `killall`) or with a throwaway `HOME` (`mktemp -d`), and clean up after.
- Say what was tested and what was only syntax checked.
