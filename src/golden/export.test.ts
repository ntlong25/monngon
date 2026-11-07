import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { loadDataset } from '../data/load.ts';
import { readRawDataset, readTestProfiles } from '../data/loadFs.ts';
import { parseTestProfiles } from '../data/testProfiles.ts';
import { fixtureDataset } from '../engine/__fixtures__/index.ts';
import { buildGolden, dataVersion, stableStringify } from './export.ts';
import { REPORT_PROFILES } from '../report/profiles.ts';

describe('stableStringify', () => {
  it('sắp khóa tăng dần, bỏ undefined, kết thúc bằng xuống dòng', () => {
    expect(stableStringify({ b: 1, a: { d: undefined, c: [2, { z: 1, y: 2 }] } })).toBe(
      '{\n "a": {\n  "c": [\n   2,\n   {\n    "y": 2,\n    "z": 1\n   }\n  ]\n },\n "b": 1\n}\n',
    );
  });
  it('từ chối NaN', () => {
    expect(() => stableStringify({ a: NaN })).toThrow();
  });
});

describe('golden (fixture)', () => {
  const ds = fixtureDataset();
  const profiles = REPORT_PROFILES.slice(0, 2);
  const input = { ds, profiles, dataFiles: [{ name: 'a.json', content: '[]' }], date: '2026-11-06' };

  it('xuất hai lần ra cùng từng byte', () => {
    const a = buildGolden(input);
    const b = buildGolden(input);
    expect([...a.keys()]).toEqual([...b.keys()]);
    for (const [k, v] of a) expect(b.get(k)).toBe(v);
  }, 60_000);

  it('có đủ vector và ca; rng seed 1 có 1.000 giá trị', () => {
    const g = buildGolden(input);
    expect(g.has('README.md') && g.has('manifest.json')).toBe(true);
    expect([...g.keys()].filter((k) => k.startsWith('cases/'))).toHaveLength(2 * 3);
    const rng = JSON.parse(g.get('vectors/rng.json')!);
    expect(rng.seeds['1']).toHaveLength(1000);
    expect(rng.seeds['42']).toHaveLength(1000);
  });

  it('dataVersion không phụ thuộc thứ tự truyền vào, đổi nội dung thì đổi', () => {
    const x = { name: 'x.json', content: '1' };
    const y = { name: 'y.json', content: '2' };
    expect(dataVersion([x, y]).version).toBe(dataVersion([y, x]).version);
    expect(dataVersion([x, y]).version).not.toBe(dataVersion([x, { ...y, content: '3' }]).version);
  });
});

// Chốt "đóng băng": golden/ trên đĩa phải đúng bằng đầu ra engine hiện tại (chỉ kiểm khi dữ liệu data/ chưa đổi so với manifest).
describe('golden/ trên đĩa', () => {
  const manifestPath = 'golden/manifest.json';
  const have = existsSync(manifestPath) && existsSync('data/recipes.json') && existsSync('data/test-profiles.json');
  it.skipIf(!have)('khớp từng byte với engine TS hiện tại (và đúng phiên bản dữ liệu)', () => {
    const files = readdirSync('data').filter((f) => f.endsWith('.json')).sort().map((name) => ({ name, content: readFileSync(join('data', name), 'utf8') }));
    const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
    expect(
      dataVersion(files).version,
      'data/*.json đã đổi so với golden/ → chạy `npm run export-golden` (rồi báo PM/DEV để cập nhật bản port)',
    ).toBe(manifest.data_version_sha256);
    const ds = loadDataset(readRawDataset('data'));
    const profiles = parseTestProfiles(readTestProfiles('data/test-profiles.json'));
    const fresh = buildGolden({ ds, profiles, dataFiles: files, date: '2026-11-06' });
    for (const [rel, content] of fresh) {
      if (rel === 'README.md') continue; // ngày xuất có thể do người chạy đặt
      expect(readFileSync(join('golden', rel), 'utf8'), rel).toBe(content);
    }
  }, 60_000);
});
