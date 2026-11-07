// npm run export-golden [-- --data data --profiles data/test-profiles.json --out golden --date 2026-11-06]
import { mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { loadDataset } from '../data/load.ts';
import { readRawDataset, readTestProfiles } from '../data/loadFs.ts';
import { parseTestProfiles } from '../data/testProfiles.ts';
import { buildGolden } from './export.ts';

const args = process.argv.slice(2);
const opt = (name: string, def: string) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1]! : def;
};
const dataDir = opt('data', 'data');
const outDir = opt('out', 'golden');
const files = readdirSync(dataDir).filter((f) => f.endsWith('.json')).sort()
  .map((name) => ({ name, content: readFileSync(join(dataDir, name), 'utf8') }));
const ds = loadDataset(readRawDataset(dataDir));
const profiles = parseTestProfiles(readTestProfiles(opt('profiles', join(dataDir, 'test-profiles.json'))));
const golden = buildGolden({ ds, profiles, dataFiles: files, date: opt('date', '2026-11-06') });

rmSync(outDir, { recursive: true, force: true });
let bytes = 0;
for (const [rel, content] of golden) {
  const p = join(outDir, rel);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, content, 'utf8');
  bytes += Buffer.byteLength(content);
}
console.log(`golden: ${golden.size} file, ${(bytes / 1024 / 1024).toFixed(2)} MB → ${outDir}/`);
