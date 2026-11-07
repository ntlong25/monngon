import { describe, expect, it } from 'vitest';
import { coverageMatrix, diagnose, formatReport, priceCoverage, proteinDensity, runProfile, summarize } from './engineReport.ts';
import { REPORT_PROFILES, type ReportProfile } from './profiles.ts';
import { fixtureDataset } from '../engine/__fixtures__/index.ts';
import { computeTargets } from '../engine/targets.ts';

const ds = fixtureDataset();
const easy: ReportProfile = REPORT_PROFILES.find((p) => p.name === 'nu-giu-can')!;

describe('engine report (trên fixture)', () => {
  it('runProfile trả kết quả đầy đủ, không vi phạm ràng buộc cứng', () => {
    const r = runProfile(easy, ds, 1, '2026-11-09');
    expect(['ready', 'partial']).toContain(r.status);
    expect(r.hard_violations).toEqual([]);
    expect(r.days_ok).toBeLessThanOrEqual(7);
  });

  it('hồ sơ không có món cho 1 bữa → partial (không lỗi) kèm chẩn đoán', () => {
    const vegan = REPORT_PROFILES.find((p) => p.name === 'thuan-chay')!;
    const r = runProfile(vegan, ds, 1, '2026-11-09');
    expect(r.status).toBe('partial');
    expect(r.diagnosis.join(' ')).toMatch(/KHÔNG CÓ MÓN/);
  });

  it('diagnose chỉ ra thiếu món giàu đạm khi mục tiêu quá cao', () => {
    const hard: ReportProfile = { ...easy, profile: { ...easy.profile, target_mode: 'manual', manual_kcal: 1500, manual_protein_g: 300 } };
    const lines = diagnose(hard, ds, computeTargets(hard.profile), null);
    expect(lines.join(' ')).toMatch(/THIẾU MÓN GIÀU ĐẠM/);
  });

  it('summarize + formatReport + các bảng phụ chạy được', () => {
    const rs = REPORT_PROFILES.slice(0, 3).map((p) => runProfile(p, ds, 1, '2026-11-09'));
    const s = summarize(rs);
    expect(s.profiles).toBe(3);
    expect(formatReport(rs)).toContain('TỔNG HỢP');
    expect(coverageMatrix(ds, easy.prefs)).toContain('thuần chay');
    expect(priceCoverage(ds)).toContain('cho_khac');
    expect(proteinDensity(ds)).toContain('MẬT ĐỘ PROTEIN');
  });
});
