import assert from 'node:assert/strict';
import {
  copyFileSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const repository = fileURLToPath(new URL('../', import.meta.url));
const modules = ['brew', 'node', 'docker', 'git', 'zsh', 'vscode', 'macos'];

function workspace(t) {
  const root = mkdtempSync(join(tmpdir(), 'handles env '));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  for (const directory of ['home', 'private', 'src', 'profiles']) {
    mkdirSync(join(root, directory));
  }
  for (const file of ['src/helpers.sh', 'profiles/common.sh']) {
    copyFileSync(join(repository, file), join(root, file));
  }
  for (const module of modules) {
    mkdirSync(join(root, 'modules', module), { recursive: true });
    writeFileSync(join(root, 'modules', module, 'install.sh'),
      `printf '%s\\n' "${module}:\${HANDLES_PRIVATE_TEST:-unset}" >>"$TEST_LOG"\n`);
  }
  writeFileSync(join(root, 'modules/zsh/zshrc'),
    'printf \'%s\\n\' "shared:${HANDLES_PRIVATE_TEST:-unset}" >>"$TEST_LOG"\n');
  writeFileSync(join(root, 'modules/docker/zshrc'),
    'printf \'%s\\n\' "docker:${HANDLES_PRIVATE_TEST:-unset}" >>"$TEST_LOG"\n');
  return {
    root,
    home: join(root, 'home'),
    log: join(root, 'environment.log'),
  };
}

function shell(work, script, profile = 'work', executable = '/bin/bash') {
  const env = {
    ...process.env,
    HOME: work.home,
    ZDOTDIR: work.home,
    HANDLES_PATH: work.root,
    HANDLES_PROFILE: profile,
    TEST_LOG: work.log,
  };
  delete env.HANDLES_PRIVATE_TEST;
  delete env.BASH_ENV;
  delete env.ENV;
  return spawnSync(executable, ['-f', '-c', script], {
    cwd: work.root,
    env,
    encoding: 'utf8',
  });
}

function setup(work, profile = 'work') {
  return shell(work, `
set -euo pipefail
. "$HANDLES_PATH/src/helpers.sh"
uname() { printf '%s\\n' Darwin; }
sw_vers() { printf '%s\\n' test; }
. "$HANDLES_PATH/profiles/common.sh"
`, profile);
}

function installZsh(work, profile = 'work') {
  copyFileSync(join(repository, 'modules/zsh/install.sh'), join(work.root, 'modules/zsh/install.sh'));
  return shell(work, `
set -euo pipefail
. "$HANDLES_PATH/src/helpers.sh"
brew_install() { :; }
brew() { [[ "$1" == --prefix ]] && printf '%s\\n' /opt/handles-test; }
dscl() { printf '%s\\n' 'UserShell: /opt/handles-test/bin/zsh'; }
sudo() {
  [[ "$*" == "tee -a /etc/shells" ]] || return 1
  cat >/dev/null
}
chsh() { printf '%s\\n' 'unexpected chsh call' >&2; return 1; }
zshrc_modules=()
if [[ "$HANDLES_PROFILE" == work ]]; then zshrc_modules=(docker); fi
. "$HANDLES_PATH/modules/zsh/install.sh"
`, profile);
}

function succeeded(result) {
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
}

test('work setup loads private exports before every installer in the same process', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/env.work.sh'), 'export HANDLES_PRIVATE_TEST=work\n');
  succeeded(setup(work));
  assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), modules.map(module => `${module}:work`));
});

test('personal setup never loads the work environment', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/env.work.sh'), 'export HANDLES_PRIVATE_TEST=work\n');
  succeeded(setup(work, 'personal'));
  assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), modules.map(module => `${module}:unset`));
});

test('personal setup loads its own environment when both profiles have private files', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/env.work.sh'), 'export HANDLES_PRIVATE_TEST=work\n');
  writeFileSync(join(work.root, 'private/env.personal.sh'), 'export HANDLES_PRIVATE_TEST=personal\n');
  succeeded(setup(work, 'personal'));
  assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), modules.map(module => `${module}:personal`));
});

test('an absent optional environment file does not prevent setup', t => {
  const work = workspace(t);
  succeeded(setup(work));
  assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), modules.map(module => `${module}:unset`));
});

test('private environment failure stops setup before any installer', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/env.work.sh'), 'return 17\n');
  const result = setup(work);
  assert.equal(result.status, 17);
  assert.equal(existsSync(work.log), false);
});

for (const executable of ['/bin/bash', '/bin/zsh']) {
  test(`managed work startup loads private exports before shared and module settings (${executable})`, t => {
    const work = workspace(t);
    writeFileSync(join(work.root, 'private/env.work.sh'), 'export HANDLES_PRIVATE_TEST=work\n');
    writeFileSync(join(work.home, '.zshrc'), '# existing user settings\n');
    succeeded(installZsh(work));
    const startup = readFileSync(join(work.home, '.zshrc'), 'utf8');
    assert.ok(startup.startsWith('# existing user settings\n'));
    assert.ok(startup.includes(join(work.root, 'private/env.work.sh')));
    succeeded(shell(work, '. "$HOME/.zshrc"', 'work', executable));
    assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), ['shared:work', 'docker:work']);
    succeeded(installZsh(work));
    assert.equal(readFileSync(join(work.home, '.zshrc'), 'utf8'), startup);
  });
}

test('switching installed shell profile removes work loading and preserves user content', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'private/env.work.sh'), 'export HANDLES_PRIVATE_TEST=work\n');
  writeFileSync(join(work.home, '.zshrc'), '# before managed block\n');
  succeeded(installZsh(work));
  const zshrc = join(work.home, '.zshrc');
  writeFileSync(zshrc, `${readFileSync(zshrc, 'utf8')}# after managed block\n`);
  succeeded(installZsh(work, 'personal'));
  const personal = readFileSync(zshrc, 'utf8');
  assert.ok(personal.startsWith('# before managed block\n'));
  assert.ok(personal.endsWith('# after managed block\n'));
  assert.ok(!personal.includes(join(work.root, 'private/env.work.sh')));
  assert.ok(personal.includes(join(work.root, 'private/env.personal.sh')));
  succeeded(shell(work, '. "$HOME/.zshrc"', 'personal', '/bin/zsh'));
  assert.equal(readFileSync(work.log, 'utf8').trim(), 'shared:unset');
});

test('work shell startup tolerates an absent optional environment file', t => {
  const work = workspace(t);
  succeeded(installZsh(work));
  succeeded(shell(work, '. "$HOME/.zshrc"', 'work', '/bin/zsh'));
  assert.deepEqual(readFileSync(work.log, 'utf8').trim().split('\n'), ['shared:unset', 'docker:unset']);
});

test('Git ignores private contents, including nested and hidden files, but keeps the marker', () => {
  for (const path of ['private/env.work.sh', 'private/gitconfig.work-identity', 'private/nested/settings.json', 'private/.hidden']) {
    const result = spawnSync('git', ['check-ignore', '--quiet', '--', path], { cwd: repository });
    assert.equal(result.status, 0, `${path} must be ignored`);
  }
  const marker = spawnSync('git', ['check-ignore', '--quiet', '--', 'private/.gitkeep'], { cwd: repository });
  assert.equal(marker.status, 1, 'private/.gitkeep must be versionable');
});
