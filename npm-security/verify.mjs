import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const root = process.argv[2] || '/usr/local/lib/node_modules/npm/node_modules';
const expected = {
  'balanced-match': '4.0.4',
  'brace-expansion': '5.0.12',
  'http-cache-semantics': '4.3.0',
  'ip-address': '10.7.4',
  tar: '7.5.22',
  undici: '6.29.1',
};

for (const [name, version] of Object.entries(expected)) {
  const { version: actual } = JSON.parse(readFileSync(join(root, name, 'package.json'), 'utf8'));
  if (actual !== version) throw new Error(`${name}@${actual} in npm, expected ${version}`);
  console.log(`${name}@${actual}`);
}
