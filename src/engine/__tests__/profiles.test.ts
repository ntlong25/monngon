// T-011 — Chạy toàn bộ data/test-profiles.json trên dữ liệu thật; in báo cáo và kiểm tiêu chí chấp nhận.
import { existsSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { loadDataset } from '../../data/load.ts';
import { readRawDataset, readTestProfiles } from '../../data/loadFs.ts';
import { parseTestProfiles } from '../../data/testProfiles.ts';
import { formatReport, runProfile, summarize } from '../../report/engineReport.ts';

const FILE = 'data/test-profiles.json';
const present = existsSync(FILE) && existsSync('data/recipes.json');
/** AC T-011: ≥ 90% hồ sơ có expect_all_days_pass đạt 7/7 (hạ bằng PASS_RATE_MIN khi cần chẩn đoán). */
const MIN_PASS_RATE = Number(process.env.PASS_RATE_MIN ?? '0.9');

describe.skipIf(!present)('T-011 · engine trên dữ liệu thật + test-profiles.json', () => {
  const ds = present ? loadDataset(readRawDataset('data')) : (null as never);
  const profiles = present ? parseTestProfiles(readTestProfiles(FILE)) : [];
  const results = profiles.map((p) => runProfile(p, ds, 1, '2026-11-09'));
  const summary = summarize(results);

  it('in báo cáo', () => {
    console.log('\n' + formatReport(results).split('MA TRẬN')[0]);
    expect(results.length).toBeGreaterThan(0);
  });

  it('ràng buộc cứng đúng ở 100% hồ sơ (dị ứng, chế độ ăn, dụng cụ, món chặn, ít tinh bột, nguyên liệu cấm của hồ sơ)', () => {
    for (const r of results) expect(r.hard_violations, `${r.name}: ${r.hard_violations.join(' | ')}`).toEqual([]);
  });

  it(`≥ ${MIN_PASS_RATE * 100}% hồ sơ kỳ vọng đạt thì đạt 7/7`, () => {
    const rate = summary.expected_pass_ready / Math.max(1, summary.expected_pass);
    const failed = results.filter((r) => r.expect_all_days_pass && r.status !== 'ready').map((r) => `${r.name}(${r.status})`);
    expect(rate, `không đạt: ${failed.join(', ')}`).toBeGreaterThanOrEqual(MIN_PASS_RATE);
  });

  it('lỗi "không có món" chỉ được phép ở hồ sơ vốn kỳ vọng chưa đạt', () => {
    for (const r of results.filter((x) => x.status === 'error')) expect(r.expect_all_days_pass, `${r.name}: ${r.error}`).toBe(false);
  });

  it('mỗi hồ sơ lập tuần dưới 2 giây', () => {
    for (const r of results) expect(r.ms, r.name).toBeLessThan(2000);
  });

  it('tất định theo seed', () => {
    const p = profiles[0]!;
    const a = runProfile(p, ds, 7, '2026-11-09');
    const b = runProfile(p, ds, 7, '2026-11-09');
    expect({ ...a, ms: 0 }).toEqual({ ...b, ms: 0 });
  });
});
