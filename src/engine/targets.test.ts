import { describe, expect, it } from 'vitest';
import { calorieBand, computeTargets, referenceWeightKg, roundTo } from './targets.ts';
import { specProfile } from './__fixtures__/index.ts';
import type { Profile } from '../types/profile.ts';

const p = (over: Partial<Profile>): Profile => ({ ...specProfile, ...over });

describe('computeTargets — ví dụ spec', () => {
  it('nam 30t, 177.8 cm, 81.6 kg, vừa, giảm mỡ → 2.200 kcal / 175 g', () => {
    const t = computeTargets(specProfile);
    expect(t.kcal_target).toBe(2200);
    expect(t.protein_g).toBe(175);
    expect(t.steps!.bmr).toBeCloseTo(1782.25, 2);
    expect(t.steps!.tdee).toBeCloseTo(2762.5, 1); // spec ghi 2.763 (làm tròn BMR 1.783 trước)
    expect(t.steps!.reference_weight_kg).toBeCloseTo(79.03, 1);
    expect(t.steps!.protein_cap_g).toBe(190); // floor5(0.35×2200/4 = 192.5)
    expect(t.steps!.protein_floor_g).toBe(139);
    expect(t.steps!.protein_limited_by).toBe('none');
  });

  it('dải calo mặc định ±5%: mục tiêu 1.800 → 1.710–1.890', () => {
    expect(calorieBand(1800)).toEqual({ kcal_min: 1710, kcal_max: 1890 });
    const t = computeTargets(specProfile);
    expect([t.kcal_min, t.kcal_max]).toEqual([2090, 2310]);
    expect(t.kcal_target).toBe(2200);
  });

  it('có thể về dải cũ −5%/0% bằng tùy chọn', () => {
    expect(calorieBand(1800, { bandAbovePct: 0 })).toEqual({ kcal_min: 1710, kcal_max: 1800 });
  });

  it('dải calo cấu hình được', () => {
    expect(calorieBand(2000, { bandBelowPct: 0.1, bandAbovePct: 0.05 })).toEqual({ kcal_min: 1800, kcal_max: 2100 });
  });
});

describe('cân nặng tham chiếu', () => {
  it('giảm mỡ: min(cân nặng, 25×m²)', () => {
    expect(referenceWeightKg({ goal: 'lose', height_cm: 170, weight_kg: 90 })).toBeCloseTo(72.25, 5);
    expect(referenceWeightKg({ goal: 'lose', height_cm: 180, weight_kg: 70 })).toBe(70);
  });
  it('giữ cân/tăng cơ: cân thật', () => {
    expect(referenceWeightKg({ goal: 'hold', height_cm: 170, weight_kg: 90 })).toBe(90);
    expect(referenceWeightKg({ goal: 'build', height_cm: 170, weight_kg: 90 })).toBe(90);
  });
});

describe('protein: trần 35% và sàn thắng trần', () => {
  it('nữ nhỏ cân giảm mỡ: trần cắt mục tiêu', () => {
    // nữ 45t, 155 cm, 50 kg, ít vận động: BMR=500+968.75-225-161=1082.75; ×1.2×0.8=1039.4 → 1050 kcal
    const t = computeTargets(p({ sex: 'female', age: 45, height_cm: 155, weight_kg: 50, activity: 'sedentary' }));
    expect(t.kcal_target).toBe(1050);
    const s = t.steps!;
    expect(s.protein_raw_g).toBe(110); // 2.2 × 50 = 110
    expect(s.protein_cap_g).toBe(90); // floor5(0.35×1050/4 = 91.9)
    expect(s.protein_floor_g).toBe(88); // 1.76 × 50
    expect(t.protein_g).toBe(90);
    expect(s.protein_limited_by).toBe('cap');
  });

  it('sàn thắng trần: kcal rất thấp, sàn > trần → lấy sàn', () => {
    const t = computeTargets(p({ sex: 'female', age: 90, height_cm: 150, weight_kg: 60, activity: 'sedentary' }));
    const s = t.steps!;
    expect(s.protein_floor_g).toBeGreaterThan(s.protein_cap_g);
    expect(t.protein_g).toBe(s.protein_floor_g);
    expect(s.protein_limited_by).toBe('floor');
  });

  it('giữ cân: 1.8 g/kg cân thật, sàn 1.2 g/kg', () => {
    const t = computeTargets(p({ goal: 'hold' }));
    expect(t.steps!.protein_g_per_kg).toBe(1.8);
    expect(t.steps!.protein_raw_g).toBe(145); // 1.8×81.6=146.9 → 145
    expect(t.steps!.protein_floor_g).toBe(98); // 1.2×81.6=97.92
    expect(t.kcal_target).toBe(2750); // 2763×1.0 = 2763 → 2750
  });

  it('tăng cơ: 2.0 g/kg, ×1.1 calo', () => {
    const t = computeTargets(p({ goal: 'build' }));
    expect(t.steps!.protein_raw_g).toBe(165); // 163.2 → 165
    expect(t.kcal_target).toBe(3050); // 2763×1.1 = 3039 → 3050
  });
});

describe('làm tròn biên', () => {
  it('50 kcal: nửa bước làm tròn lên', () => {
    expect(roundTo(2224.9, 50)).toBe(2200);
    expect(roundTo(2225, 50)).toBe(2250);
    expect(roundTo(2275, 50)).toBe(2300);
  });
  it('5 g protein', () => {
    expect(roundTo(172.4, 5)).toBe(170);
    expect(roundTo(172.5, 5)).toBe(175);
  });
});

describe('chế độ tự nhập', () => {
  it('bỏ qua công thức, không có steps', () => {
    const t = computeTargets(p({ target_mode: 'manual', manual_kcal: 1350, manual_protein_g: 110 }));
    expect(t).toMatchObject({ mode: 'manual', kcal_target: 1350, protein_g: 110, steps: null, kcal_min: 1283, kcal_max: 1418 });
  });
  it('thiếu số tự nhập → lỗi', () => {
    expect(() => computeTargets(p({ target_mode: 'manual' }))).toThrow();
  });
});
