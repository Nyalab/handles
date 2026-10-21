# TODO

## Security

- [ ] Confirm revocation of the legacy OpenAI API key on platform.openai.com.
  - It was exposed in historical commit `c403436` (`modules/zsh/zshrc`).
  - Published branches and local branches/tag have been scrubbed, but this does not revoke the key or erase other copies.
- [ ] Decide whether to expire local Git reflogs and prune unreachable objects retained for recovery after the history cleanup.
- [ ] Check whether other clones or GitHub-retained references/caches need cleanup; other clones must be re-cloned or carefully migrated before pushing.

## git

- [ ] Check the status of GitLight (notifications for GitHub and GitLab, cask `gitlight`): it did not support GitLab years ago, see if it does now and if it can be used with self-hosted GitLab.
- [ ] Find a more modern tool than `git-standup` (summary of recent commits for a daily standup).
- [ ] Revisit the commented `rerere`, `color.status` and `color.diff-highlight` in `modules/git/gitconfig`.
- [ ] Move the `handles` folder to `~/dev/personal/handles` so the personal identity applies on a work machine (`includeIf` in `modules/git/gitconfig.work`).

## vscode

- [ ] Add a pre-commit guard for staged public settings; export/apply are currently explicit commands.
- [ ] Add scheduled config export/apply when the maintenance workflow is defined.
- [ ] Try the commented settings and keybindings in `modules/vscode/` and decide whether to keep them.

## zsh

- [ ] Test the `~/.zshrc` block rewrite (`modules/zsh/install.sh`) on a real run, on both profiles.
- [ ] Understand zsh completions: check in a real shell that Tab completes `git`/`docker`/`brew`, and that `modules/zsh/zshrc` finds `zsh-completions` and brew's `site-functions`.
- [ ] Move `bat`, `eza`, `btop`, `zoxide` out of `modules/brew/work.sh`: `modules/zsh/zshrc` needs them on every profile (an alias or `eval` on a missing command errors at shell start).
- [ ] Try the commented lines in `modules/zsh/zshrc` (cargo/yarn/python PATH, pnpm, thefuck, tabtab, `GITHUB_TOKEN`) and decide whether to keep them.

## brew

- [ ] Check whether you still have licenses for `airbuddy` and `cleanmymac` (commented in `modules/brew/common.sh`), then re-enable or drop them.
- [ ] Decide on a `brew update` step (legacy ran it on every setup).

## docker

- [ ] Test `modules/docker/install.sh` on a real run (colima start, `docker compose version`, with local environment configuration).

## setup

- [ ] Prompt the user for computer names during setup (for example, "Nyalab Macbook Pro") and save the answers in `private/env.personal.sh`.
- [ ] Implement the two other macOS install styles in `modules/macos/install.sh`: "backup" (keep existing settings) and "just diff" (print what is different).

- [ ] Find a better way to install App Store apps (the `mas` list is commented in `modules/macos/personal.sh`), to look into.
- [ ] Search for extra macOS screenshot settings (format, filename, shadow, ...) in `modules/macos/common.sh`.
- [ ] Test a fresh work setup with `private/env.work.sh` populated, without restarting the terminal first.
