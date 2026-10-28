import assert from 'node:assert/strict';
import {
  copyFileSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readlinkSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const repository = fileURLToPath(new URL('../', import.meta.url));

function workspace(t) {
  const root = mkdtempSync(join(tmpdir(), 'handles git '));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const home = join(root, 'home');
  mkdirSync(home);
  mkdirSync(join(root, 'modules/git'), { recursive: true });
  mkdirSync(join(root, 'src'));
  mkdirSync(join(root, 'private'));
  for (const file of [
    'src/helpers.sh',
    'modules/git/install.sh',
    'modules/git/gitconfig',
    'modules/git/gitconfig.work',
    'modules/git/gitconfig.personal',
    'modules/git/gitignore_global',
  ]) {
    copyFileSync(join(repository, file), join(root, file));
  }
  writeFileSync(join(root, 'private/gitconfig.personal-identity'), `[user]
  name = Personal User
  email = personal@example.invalid
[github]
  user = personal-user
`);
  return {
    root,
    home,
    identity: join(root, 'private/gitconfig.work-identity'),
    global: join(home, '.gitconfig'),
    log: join(root, 'brew.log'),
  };
}

function environment(work) {
  return {
    ...process.env,
    HOME: work.home,
    XDG_CONFIG_HOME: join(work.home, '.config'),
    GIT_CONFIG_GLOBAL: work.global,
    GIT_CONFIG_NOSYSTEM: '1',
    GIT_CONFIG_COUNT: '0',
    HANDLES_PATH: work.root,
    TEST_LOG: work.log,
  };
}

function install(work, profile = 'work') {
  return spawnSync('/bin/bash', ['-c', `
set -euo pipefail
. "$HANDLES_PATH/src/helpers.sh"
brew_install() { printf '%s\\n' "$*" >>"$TEST_LOG"; }
. "$HANDLES_PATH/modules/git/install.sh"
`], {
    cwd: work.root,
    env: { ...environment(work), HANDLES_PROFILE: profile },
    encoding: 'utf8',
  });
}

function git(work, directory, ...args) {
  const result = spawnSync('git', ['-C', directory, ...args], {
    env: environment(work),
    encoding: 'utf8',
  });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}

function succeeded(result) {
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
}

test('work setup keeps identity local and preserves the personal-directory override', t => {
  const work = workspace(t);
  writeFileSync(work.identity, '[user]\n name = Work User\n email = work@company.example\n');
  writeFileSync(work.global, '[user]\n name = Existing User\n email = existing@example.invalid\n');
  const workProject = join(work.home, 'dev/work/project');
  const personalProject = join(work.home, 'dev/personal/project');
  for (const directory of [workProject, personalProject]) {
    mkdirSync(directory, { recursive: true });
    git(work, directory, 'init', '--quiet');
  }
  succeeded(install(work));
  assert.equal(git(work, workProject, 'config', 'user.name'), 'Work User');
  assert.equal(git(work, workProject, 'config', 'user.email'), 'work@company.example');
  assert.equal(git(work, workProject, 'config', 'core.autocrlf'), 'input');
  assert.equal(git(work, workProject, 'config', 'pull.rebase'), 'true');
  assert.equal(git(work, personalProject, 'config', 'user.name'), 'Personal User');
  assert.equal(git(work, personalProject, 'config', 'user.email'), 'personal@example.invalid');
  assert.equal(git(work, personalProject, 'config', 'github.user'), 'personal-user');
  assert.equal(readlinkSync(join(work.home, '.config/git/ignore')), join(work.root, 'modules/git/gitignore_global'));
  const global = readFileSync(work.global, 'utf8');
  succeeded(install(work));
  assert.equal(readFileSync(work.global, 'utf8'), global);
});

test('missing private work identity stops setup before any changes', t => {
  const work = workspace(t);
  const original = '[user]\n email = existing@example.invalid\n';
  writeFileSync(work.global, original);
  const result = install(work);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /work Git identity is missing/);
  assert.equal(existsSync(work.log), false);
  assert.equal(readFileSync(work.global, 'utf8'), original);
  assert.equal(existsSync(join(work.home, '.config/git/ignore')), false);
});

test('incomplete or invalid work identity stops setup without falling back', t => {
  const work = workspace(t);
  for (const content of [
    '',
    '[user]\n name = Work User\n',
    '[user]\n email = work@company.example\n',
    '[user]\n name = Work User\n email = ""\n',
    '[user',
  ]) {
    writeFileSync(work.identity, content);
    const result = install(work);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /work Git identity must define a non-empty user\.(name|email)/);
    assert.equal(existsSync(work.log), false);
    assert.equal(existsSync(work.global), false);
  }
});

test('personal setup works without any private work identity', t => {
  const work = workspace(t);
  succeeded(install(work, 'personal'));
  const project = join(work.home, 'project');
  mkdirSync(project);
  git(work, project, 'init', '--quiet');
  assert.equal(git(work, project, 'config', 'user.email'), 'personal@example.invalid');
  assert.equal(existsSync(work.identity), false);
});

test('missing private personal identity stops personal setup before any changes', t => {
  const work = workspace(t);
  rmSync(join(work.root, 'private/gitconfig.personal-identity'));
  const result = install(work, 'personal');
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /personal Git identity is missing/);
  assert.equal(existsSync(work.log), false);
  assert.equal(existsSync(work.global), false);
});

test('incomplete private personal identity stops personal setup', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/gitconfig.personal-identity'), '[user]\n name = Personal User\n');
  const result = install(work, 'personal');
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /personal Git identity must define a non-empty user\.email/);
  assert.equal(existsSync(work.log), false);
  assert.equal(existsSync(work.global), false);
});

test('work setup accepts a missing personal identity and retains work identity in personal repositories', t => {
  const work = workspace(t);
  rmSync(join(work.root, 'private/gitconfig.personal-identity'));
  writeFileSync(work.identity, '[user]\n name = Work User\n email = work@company.example\n');
  const project = join(work.home, 'dev/personal/project');
  mkdirSync(project, { recursive: true });
  git(work, project, 'init', '--quiet');
  succeeded(install(work));
  assert.equal(git(work, project, 'config', 'user.name'), 'Work User');
  assert.equal(git(work, project, 'config', 'user.email'), 'work@company.example');
});
