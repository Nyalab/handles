import assert from 'node:assert/strict';
import {
  copyFileSync,
  existsSync,
  lstatSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  readlinkSync,
  rmSync,
  statSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import { parse } from 'jsonc-parser';
import { transform } from '../src/adapters/jsonc.mjs';

const repository = fileURLToPath(new URL('../', import.meta.url));
const privateKeys = ['github-enterprise.uris'];
const liveSettings = `{
  // editor
  "editor.fontSize": 14, // public inline
  // "editor.minimap.enabled": false,
  "public.object": { "nested": [1, 2,], /* public nested */ },
  // private company comment
  /* private block */
  "github-enterprise.uris": [
    /* private inner */ "https://private.invalid",
  ], // private trailing
  // font
  "editor.fontFamily": "Mono"
  // public footer
}`;

function values(text) {
  const errors = [];
  const result = parse(text, errors, { allowTrailingComma: true });
  assert.deepEqual(errors, []);
  return result;
}

function workspace(t) {
  const root = mkdtempSync(join(tmpdir(), 'handles config '));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  for (const directory of ['src/adapters', 'scripts', 'modules/vscode', 'home']) {
    mkdirSync(join(root, directory), { recursive: true });
  }
  for (const file of [
    'src/helpers.sh',
    'src/config.sh',
    'src/adapters/jsonc.mjs',
    'scripts/config.sh',
    'modules/vscode/config.sh',
    'modules/vscode/install.sh',
  ]) {
    copyFileSync(join(repository, file), join(root, file));
  }
  symlinkSync(join(repository, 'node_modules'), join(root, 'node_modules'));
  return {
    root,
    live: join(root, 'modules/vscode/settings.json'),
    shared: join(root, 'modules/vscode/settings.public.json'),
    home: join(root, 'home'),
  };
}

function shell(work, script, args = [], extraEnv = {}) {
  return spawnSync('/bin/bash', [
    '-c',
    `set -euo pipefail
    . "$HANDLES_PATH/src/helpers.sh"
    ${script}`,
    'config-test',
    ...args,
  ], {
    cwd: work.home,
    env: { ...process.env, HANDLES_PATH: work.root, HOME: work.home, ...extraEnv },
    encoding: 'utf8',
  });
}

function run(work, operation, module = 'vscode', extraEnv = {}) {
  return shell(work, '. "$HANDLES_PATH/scripts/config.sh"', [operation, module], extraEnv);
}

function succeeded(result) {
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
}

function failed(result, pattern) {
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, pattern);
}

function noSnapshots(work) {
  assert.deepEqual(
    readdirSync(dirname(work.live)).filter(name => name.startsWith('.handles-config.')),
    [],
  );
}

test('export removes a private property and its leading, inner and inline comments', () => {
  const result = transform('export', liveSettings, '', privateKeys);
  assert.deepEqual(values(result), {
    'editor.fontSize': 14,
    'public.object': { nested: [1, 2] },
    'editor.fontFamily': 'Mono',
  });
  assert.doesNotMatch(result, /github-enterprise|private company|private block|private inner|private trailing|private\.invalid/);
  for (const comment of ['// editor', '// public inline', '// "editor.minimap.enabled": false,', '/* public nested */', '// font', '// public footer']) {
    assert.ok(result.includes(comment), comment);
  }
});

test('apply replaces public settings and preserves only local private settings and comments', () => {
  const shared = '{ // upstream font\n "editor.fontSize": 20, "public.new": true }';
  const result = transform('apply', liveSettings, shared, privateKeys);
  assert.deepEqual(values(result), {
    'editor.fontSize': 20,
    'public.new': true,
    'github-enterprise.uris': ['https://private.invalid'],
  });
  for (const comment of ['// upstream font', '// private company comment', '/* private block */', '/* private inner */', '// private trailing']) {
    assert.ok(result.includes(comment), comment);
  }
  assert.doesNotMatch(result, /public nested|editor\.fontFamily/);
});

test('fresh apply needs no local private values', () => {
  assert.deepEqual(values(transform('apply', '{}', '{"editor.fontSize": 20}', privateKeys)), {
    'editor.fontSize': 20,
  });
});

test('export/apply are idempotent and preserve the public artifact through a round trip', () => {
  const shared = transform('export', liveSettings, '', privateKeys);
  const applied = transform('apply', liveSettings, shared, privateKeys);
  assert.equal(transform('export', shared, '', privateKeys), shared);
  assert.equal(transform('apply', applied, shared, privateKeys), applied);
  assert.equal(transform('export', applied, '', privateKeys), shared);
});

test('JSONC punctuation and private positions do not affect stripping', () => {
  const sources = [
    '{"private": {"nested": [1,2]}, "public": true}',
    '{"public": true, "private": [1,2]}',
    '{"a": 1, "private": null, "b": 2,}',
    '{"private": false,}',
    '{"private": 1}',
    '{}',
    '{ /* keep empty object comment */ }',
    '// header\n{\r\n// remove\r\n"private": 1,\r\n"public": true,\r\n}\n// footer',
    '{"private": 1 /* remove */ // remove too\n, "public": true}',
    '{"private": 1, /* remove multiline\n comment */ "public": true}',
  ];
  for (const source of sources) {
    const result = transform('export', source, '', ['private']);
    const expected = values(source);
    delete expected.private;
    assert.deepEqual(values(result), expected);
    assert.doesNotMatch(result, /remove/);
  }
});

test('multiple exclusions are literal top-level keys, including escaped property names', () => {
  const source = '{"company.setting":1,"company":{"setting":2},"other":3,"company\\u002eescaped":4}';
  const result = transform('export', source, '', ['company.setting', 'company.escaped', 'other']);
  assert.deepEqual(values(result), { company: { setting: 2 } });
  assert.deepEqual(values(transform('export', source, '', [])), values(source));
});

test('appending private entries cannot swallow the next entry or closing brace in a line comment', () => {
  const source = '{"private.a":1, // a\n"private.b":2 // b\n}';
  const result = transform('apply', source, '{"public":true // upstream\n}', ['private.a', 'private.b']);
  assert.deepEqual(values(result), { public: true, 'private.a': 1, 'private.b': 2 });
  assert.match(result, /\/\/ upstream/);
  assert.match(result, /\/\/ a/);
  assert.match(result, /\/\/ b/);
});

test('prototype-like property names remain ordinary settings', () => {
  const result = transform('export', '{"__proto__":1,"constructor":2,"private":3}', '', ['private']);
  assert.match(result, /"__proto__": 1/);
  assert.match(result, /"constructor": 2/);
  assert.doesNotMatch(result, /private/);
});

test('invalid input, duplicate root keys and private upstream keys are explicit errors', () => {
  for (const source of ['{', '[]', 'null', '', '{"a": 1, "a": 2}']) {
    assert.throws(() => transform('export', source, '', privateKeys), /invalid JSONC|must be a JSONC object|duplicate setting/);
  }
  assert.throws(() => transform('apply', '{}', '{"private":1}', ['private']), /excluded setting/);
  assert.throws(() => transform('apply', '{', '{}', []), /invalid JSONC/);
  assert.throws(() => transform('apply', '{}', '{', []), /invalid JSONC/);
  assert.throws(() => transform('other', '{}', '{}', []), /unknown config operation/);
  assert.throws(
    () => transform('export', '{"private": "do-not-print-this-value"', '', ['private']),
    error => !error.message.includes('do-not-print-this-value'),
  );
});

test('shared helper exports without modifying the live file and cleans private snapshots', t => {
  const work = workspace(t);
  writeFileSync(work.live, liveSettings);
  succeeded(run(work, 'export'));
  assert.equal(readFileSync(work.live, 'utf8'), liveSettings);
  assert.doesNotMatch(readFileSync(work.shared, 'utf8'), /private\.invalid|github-enterprise/);
  noSnapshots(work);
  const before = statSync(work.shared).ino;
  succeeded(run(work, 'export'));
  assert.equal(statSync(work.shared).ino, before);
});

test('shared helper applies fresh and existing files while preserving the application symlink', t => {
  const work = workspace(t);
  writeFileSync(work.shared, '{"editor.fontSize":20}');
  succeeded(run(work, 'apply'));
  assert.deepEqual(values(readFileSync(work.live, 'utf8')), { 'editor.fontSize': 20 });
  assert.equal(statSync(work.live).mode & 0o777, 0o600);
  writeFileSync(work.live, liveSettings);
  const application = join(work.home, 'settings.json');
  symlinkSync(work.live, application);
  succeeded(run(work, 'apply'));
  assert.equal(readlinkSync(application), work.live);
  assert.deepEqual(values(readFileSync(application, 'utf8')), {
    'editor.fontSize': 20,
    'github-enterprise.uris': ['https://private.invalid'],
  });
  noSnapshots(work);
});

test('shared helper can reuse the JSONC adapter for another module', t => {
  const work = workspace(t);
  const module = join(work.root, 'modules/other');
  mkdirSync(module);
  writeFileSync(join(module, 'config.sh'), `
config_adapter=jsonc
config_live="$HANDLES_PATH/modules/other/live.json"
config_public="$HANDLES_PATH/modules/other/public.json"
config_private_keys=(private)
`);
  writeFileSync(join(module, 'live.json'), '{"private":1,"public":2}');
  succeeded(run(work, 'export', 'other'));
  assert.deepEqual(values(readFileSync(join(module, 'public.json'), 'utf8')), { public: 2 });
});

test('a module with no exclusions works with macOS Bash nounset', t => {
  const work = workspace(t);
  writeFileSync(join(work.root, 'modules/vscode/config.sh'), `
config_adapter=jsonc
config_live="$HANDLES_PATH/modules/vscode/settings.json"
config_public="$HANDLES_PATH/modules/vscode/settings.public.json"
config_private_keys=()
`);
  writeFileSync(work.live, '{"public":2}');
  succeeded(run(work, 'export'));
  assert.deepEqual(values(readFileSync(work.shared, 'utf8')), { public: 2 });
});

test('missing files, unknown modules and invalid operations fail without creating configs', t => {
  const work = workspace(t);
  failed(run(work, 'export'), /live config is missing/);
  failed(run(work, 'apply'), /public config is missing/);
  failed(run(work, 'apply', '../vscode'), /unknown config module/);
  failed(run(work, 'apply', 'absent'), /unknown config module/);
  failed(run(work, 'other'), /usage:/);
  failed(shell(work, '. "$HANDLES_PATH/scripts/config.sh"'), /usage:/);
  assert.equal(existsSync(work.live), false);
  assert.equal(existsSync(work.shared), false);
  noSnapshots(work);
});

test('parse failures preserve both originals and remove private snapshots', t => {
  const work = workspace(t);
  writeFileSync(work.live, '{"editor.fontSize":');
  writeFileSync(work.shared, '{"public":true}');
  failed(run(work, 'export'), /invalid JSONC/);
  failed(run(work, 'apply'), /invalid JSONC/);
  assert.equal(readFileSync(work.live, 'utf8'), '{"editor.fontSize":');
  assert.equal(readFileSync(work.shared, 'utf8'), '{"public":true}');
  noSnapshots(work);
});

test('apply rejects excluded public values without modifying local private values', t => {
  const work = workspace(t);
  writeFileSync(work.live, liveSettings);
  writeFileSync(work.shared, '{"github-enterprise.uris":["https://wrong.invalid"]}');
  failed(run(work, 'apply'), /excluded setting/);
  assert.equal(readFileSync(work.live, 'utf8'), liveSettings);
  noSnapshots(work);
});

test('declared symlinks are refused rather than replaced', t => {
  const work = workspace(t);
  const target = join(work.home, 'private.json');
  writeFileSync(target, liveSettings);
  symlinkSync(target, work.live);
  failed(run(work, 'export'), /must be regular files/);
  assert.equal(lstatSync(work.live).isSymbolicLink(), true);
  assert.equal(readFileSync(target, 'utf8'), liveSettings);
});

test('missing dependencies give an actionable error', t => {
  const work = workspace(t);
  rmSync(join(work.root, 'node_modules'));
  writeFileSync(work.live, liveSettings);
  failed(run(work, 'export'), /run npm ci/);
  assert.equal(existsSync(work.shared), false);
});

for (const operation of ['export', 'apply']) {
  for (const changed of ['live', 'shared']) {
    test(`${operation} refuses a concurrent change to ${changed}`, t => {
      const work = workspace(t);
      writeFileSync(work.live, liveSettings);
      writeFileSync(work.shared, '{"editor.fontSize":20}');
      const bin = join(work.root, 'bin');
      mkdirSync(bin);
      writeFileSync(join(bin, 'node'), `#!/bin/bash
"$TEST_REAL_NODE" "$@" || exit $?
printf '%s\\n' '{"concurrent":true}' >"$TEST_MUTATE"
`, { mode: 0o700 });
      failed(run(work, operation, 'vscode', {
        PATH: `${bin}:${process.env.PATH}`,
        TEST_REAL_NODE: process.execPath,
        TEST_MUTATE: work[changed],
      }), /changed during/);
      assert.deepEqual(values(readFileSync(work[changed], 'utf8')), { concurrent: true });
      const untouched = changed === 'live' ? 'shared' : 'live';
      assert.equal(readFileSync(work[untouched], 'utf8'), untouched === 'live' ? liveSettings : '{"editor.fontSize":20}');
      noSnapshots(work);
    });
  }
}

test('VS Code setup applies settings, backs up defaults and links files with external commands stubbed', t => {
  const work = workspace(t);
  writeFileSync(work.live, liveSettings);
  writeFileSync(work.shared, '{"editor.fontSize":20}');
  writeFileSync(join(work.root, 'modules/vscode/keybindings.json'), '[]');
  writeFileSync(join(work.root, 'modules/vscode/extensions.txt'), 'vendor.installed\n# skip\nvendor.new\n');
  const userDirectory = join(work.home, 'Library/Application Support/Code/User');
  mkdirSync(userDirectory, { recursive: true });
  const target = join(userDirectory, 'settings.json');
  writeFileSync(target, '{"default":true}');
  const log = join(work.root, 'commands.log');
  const script = `
brew_cask_install() { printf 'brew %s\\n' "$*" >>"$TEST_LOG"; }
code() {
  printf 'code %s\\n' "$*" >>"$TEST_LOG"
  case "$1" in
    --list-extensions) printf '%s\\n' vendor.installed ;;
    --install-extension) return 0 ;;
    *) return 1 ;;
  esac
}
. "$HANDLES_PATH/modules/vscode/install.sh"`;
  succeeded(shell(work, script, [], { TEST_LOG: log }));
  assert.equal(readlinkSync(target), work.live);
  assert.equal(readFileSync(`${target}.bak`, 'utf8'), '{"default":true}');
  assert.deepEqual(values(readFileSync(target, 'utf8')), {
    'editor.fontSize': 20,
    'github-enterprise.uris': ['https://private.invalid'],
  });
  assert.equal(readlinkSync(join(userDirectory, 'keybindings.json')), join(work.root, 'modules/vscode/keybindings.json'));
  assert.equal(readlinkSync(join(userDirectory, 'snippets')), join(work.root, 'modules/vscode/snippets'));
  assert.match(readFileSync(log, 'utf8'), /code --install-extension vendor\.new/);
  assert.doesNotMatch(readFileSync(log, 'utf8'), /code --install-extension vendor\.installed/);
  succeeded(shell(work, script, [], { TEST_LOG: log }));
  assert.equal(readFileSync(`${target}.bak`, 'utf8'), '{"default":true}');
});

test('VS Code extension failure points to network and private environment configuration', t => {
  const work = workspace(t);
  writeFileSync(work.shared, '{"editor.fontSize":20}');
  writeFileSync(join(work.root, 'modules/vscode/keybindings.json'), '[]');
  writeFileSync(join(work.root, 'modules/vscode/extensions.txt'), 'vendor.failed\n');
  const result = shell(work, `
brew_cask_install() { :; }
code() {
  case "$1" in
    --list-extensions) return 0 ;;
    --install-extension) return 1 ;;
    *) return 1 ;;
  esac
}
. "$HANDLES_PATH/modules/vscode/install.sh"`);
  failed(result, /failed to install vendor\.failed; check network access and the private environment/);
});

test('Node setup installs locked dependencies with npm stubbed', t => {
  const work = workspace(t);
  mkdirSync(join(work.root, 'modules/node'));
  copyFileSync(join(repository, 'modules/node/install.sh'), join(work.root, 'modules/node/install.sh'));
  const log = join(work.root, 'npm.log');
  succeeded(shell(work, `
brew_install() { :; }
fnm() {
  case "$1" in
    env) : ;;
    list) printf '%s\\n' lts ;;
    default) : ;;
    *) return 1 ;;
  esac
}
node() { printf '%s\\n' v26.0.0; }
npm() { printf '%s\\n' "$*" >"$TEST_LOG"; }
. "$HANDLES_PATH/modules/node/install.sh"`, [], { TEST_LOG: log }));
  assert.equal(readFileSync(log, 'utf8').trim(), `ci --prefix ${work.root} --ignore-scripts --no-audit --no-fund`);
});
