// npm run engine-report [-- --data data --profiles data/test-profiles.json|tmp --seed 1 --legacy --only <tên hồ sơ> --json]
import { existsSync } from 'node:fs';
import { loadDataset } from '../data/load.ts';
import { readRawDataset, readTestProfiles } from '../data/loadFs.ts';
import { parseTestProfiles } from '../data/testProfiles.ts';
import { coverageMatrix, formatReport, priceCoverage, proteinDensity, runProfile, summarize, LEGACY_OPTIONS } from './engineReport.ts';
import { REPORT_PROFILES } from './profiles.ts';

const args = process.argv.slice(2);
const opt = (name: string, def: string) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1]! : def;
};
const ds = loadDataset(readRawDataset(opt('data', 'data')));
const seed = Number(opt('seed', '1'));
const only = opt('only', '');
const profFile = opt('profiles', 'data/test-profiles.json');
const all = profFile !== 'tmp' && existsSync(profFile) ? parseTestProfiles(readTestProfiles(profFile)) : REPORT_PROFILES;
const profiles = all.filter((p) => !only || p.name.includes(only));
const results = profiles.map((p) => runProfile(p, ds, seed, '2026-11-09', args.includes('--legacy') ? LEGACY_OPTIONS : undefined));

if (args.includes('--json')) console.log(JSON.stringify({ summary: summarize(results), results }, null, 2));
else {
  console.log(formatReport(results));
  console.log('\n' + coverageMatrix(ds, all[0]!.prefs));
  console.log('\n' + proteinDensity(ds));
  console.log('\n' + priceCoverage(ds));
}

const s = summarize(results);
process.exit(s.hard_violations > 0 ? 1 : 0);
