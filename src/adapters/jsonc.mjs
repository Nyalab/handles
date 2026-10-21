import { existsSync, readFileSync, realpathSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import {
  applyEdits,
  createScanner,
  format,
  parseTree,
  printParseErrorCode,
  SyntaxKind,
} from 'jsonc-parser';

function withoutCommas(text) {
  const scanner = createScanner(text);
  const edits = [];
  for (let token = scanner.scan(); token !== SyntaxKind.EOF; token = scanner.scan()) {
    if (token === SyntaxKind.CommaToken) {
      edits.push({ offset: scanner.getTokenOffset(), length: 1, content: '' });
    }
  }
  return applyEdits(text, edits);
}

function splitGap(text) {
  const scanner = createScanner(text);
  let trailingEnd = 0;
  for (let token = scanner.scan(); token !== SyntaxKind.EOF; token = scanner.scan()) {
    if (token === SyntaxKind.LineBreakTrivia) break;
    if (token === SyntaxKind.LineCommentTrivia || token === SyntaxKind.BlockCommentTrivia) {
      trailingEnd = scanner.getTokenOffset() + scanner.getTokenLength();
    }
  }
  return {
    trailing: withoutCommas(text.slice(0, trailingEnd)),
    leading: withoutCommas(text.slice(trailingEnd)),
  };
}

function readDocument(text, label) {
  const errors = [];
  const root = parseTree(text, errors, { allowTrailingComma: true });
  if (errors.length) {
    const error = errors[0];
    throw new Error(`${label}: invalid JSONC (${printParseErrorCode(error.error)} at offset ${error.offset})`);
  }
  if (!root || root.type !== 'object') {
    throw new Error(`${label}: config must be a JSONC object`);
  }

  const entries = [];
  const keys = new Set();
  let previousEnd = root.offset + 1;
  for (const property of root.children ?? []) {
    const key = property.children[0].value;
    if (keys.has(key)) throw new Error(`${label}: duplicate setting ${key}`);
    keys.add(key);

    const gap = text.slice(previousEnd, property.offset);
    const { leading, trailing } = entries.length
      ? splitGap(gap)
      : { leading: gap, trailing: '' };
    if (entries.length) entries[entries.length - 1].trailing = trailing;
    entries.push({
      key,
      leading,
      content: text.slice(property.offset, property.offset + property.length),
      trailing: '',
    });
    previousEnd = property.offset + property.length;
  }

  const closingOffset = root.offset + root.length - 1;
  const gap = text.slice(previousEnd, closingOffset);
  const { leading, trailing } = entries.length
    ? splitGap(gap)
    : { leading: gap, trailing: '' };
  if (entries.length) entries[entries.length - 1].trailing = trailing;
  return {
    prefix: text.slice(0, root.offset + 1),
    entries,
    footer: leading,
    suffix: text.slice(closingOffset),
  };
}

function writeDocument(document) {
  const blocks = document.entries.map((entry, index) => {
    const comma = index < document.entries.length - 1 ? ',' : '';
    return `${entry.leading}${entry.content}${comma}${entry.trailing}`.trim();
  });
  const text = `${document.prefix}\n${blocks.join('\n')}\n${document.footer.trim()}\n${document.suffix}`;
  const result = applyEdits(text, format(text, undefined, {
    insertSpaces: true,
    tabSize: 2,
    eol: '\n',
  }));
  readDocument(result, 'generated config');
  return result.endsWith('\n') ? result : `${result}\n`;
}

export function transform(operation, liveText, publicText, privateKeys) {
  const excluded = new Set(privateKeys);
  if (operation === 'export') {
    const live = readDocument(liveText, 'live config');
    live.entries = live.entries.filter(entry => !excluded.has(entry.key));
    return writeDocument(live);
  }
  if (operation === 'apply') {
    const shared = readDocument(publicText, 'public config');
    if (shared.entries.some(entry => excluded.has(entry.key))) {
      throw new Error('public config contains an excluded setting; remove it before applying');
    }
    const live = readDocument(liveText, 'live config');
    shared.entries.push(...live.entries.filter(entry => excluded.has(entry.key)));
    return writeDocument(shared);
  }
  throw new Error(`unknown config operation: ${operation}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(realpathSync(process.argv[1])).href) {
  try {
    const [operation, livePath, publicPath, ...privateKeys] = process.argv.slice(2);
    if (!livePath || !publicPath || !['export', 'apply'].includes(operation)) {
      throw new Error('usage: jsonc.mjs <export|apply> <live snapshot> <public snapshot> [private key ...]');
    }
    const live = operation === 'apply' && !existsSync(livePath)
      ? '{}'
      : readFileSync(livePath, 'utf8');
    const shared = operation === 'apply' ? readFileSync(publicPath, 'utf8') : '';
    process.stdout.write(transform(operation, live, shared, privateKeys));
  } catch (error) {
    console.error(`jsonc: ${error.message}`);
    process.exitCode = 1;
  }
}
