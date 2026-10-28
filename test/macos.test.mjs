import assert from 'node:assert/strict';
import {
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
const names = {
  MACOS_COMPUTER_NAME: ['My Computer', ['scutil', '--set', 'ComputerName']],
  MACOS_HOST_NAME: ['my-computer.example.invalid', ['scutil', '--set', 'HostName']],
  MACOS_LOCAL_HOST_NAME: ['my-computer', ['scutil', '--set', 'LocalHostName']],
  MACOS_NETBIOS_NAME: ['MYCOMPUTER', ['defaults', 'write', '/Library/Preferences/SystemConfiguration/com.apple.smb.server', 'NetBIOSName', '-string']],
};

function applyNames(t, values) {
  const home = mkdtempSync(join(tmpdir(), 'handles macos '));
  t.after(() => rmSync(home, { recursive: true, force: true }));
  mkdirSync(join(home, 'private'));
  const environment = join(home, 'private/env.personal.sh');
  writeFileSync(environment, Object.entries(values).map(([key, value]) => `export ${key}=${JSON.stringify(value)}`).join('\n'));
  const log = join(home, 'commands.log');
  const env = {
    ...process.env,
    HOME: home,
    HANDLES_PATH: repository,
    TEST_ENV: environment,
    TEST_LOG: log,
  };
  for (const key of Object.keys(names)) delete env[key];
  const result = spawnSync('/bin/bash', ['-c', `
set -euo pipefail
. "$HANDLES_PATH/src/helpers.sh"
. "$TEST_ENV"
sudo() {
  printf '%s\\n' "$#" >>"$TEST_LOG"
  printf '%s\\n' "$@" >>"$TEST_LOG"
}
. "$HANDLES_PATH/modules/macos/personal.sh"
`], { env, encoding: 'utf8' });
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  if (!existsSync(log)) return [];
  const lines = readFileSync(log, 'utf8').trimEnd().split('\n');
  const commands = [];
  while (lines.length) {
    const count = Number(lines.shift());
    commands.push(lines.splice(0, count));
  }
  return commands;
}

test('configured personal names are passed unchanged to stubbed system commands', t => {
  const values = Object.fromEntries(Object.entries(names).map(([key, [value]]) => [key, value]));
  assert.deepEqual(applyNames(t, values), Object.values(names).map(([value, command]) => [...command, value]));
});

test('unset personal names do not run any naming commands', t => {
  assert.deepEqual(applyNames(t, {}), []);
});

test('empty personal names leave the current names unchanged', t => {
  assert.deepEqual(applyNames(t, Object.fromEntries(Object.keys(names).map(key => [key, '']))), []);
});

for (const [key, [value, command]] of Object.entries(names)) {
  test(`configuring only ${key} changes only the corresponding name`, t => {
    assert.deepEqual(applyNames(t, { [key]: value }), [[...command, value]]);
  });
}
