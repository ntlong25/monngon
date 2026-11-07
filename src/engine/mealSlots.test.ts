import { describe, expect, it } from 'vitest';
import { allocateSlots, NoMainMealError } from './mealSlots.ts';

const T = { kcal_target: 2200, protein_g: 175 };
const cfg = (o: Partial<Record<'breakfast' | 'lunch' | 'dinner' | 'snack_am' | 'snack_pm', 'on' | 'self' | 'skip'>>) => ({
  breakfast: 'on', lunch: 'on', dinner: 'on', snack_am: 'on', snack_pm: 'on', ...o,
} as const);
const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);
const by = (r: ReturnType<typeof allocateSlots>) => Object.fromEntries(r.map((s) => [s.slot, s]));

describe('allocateSlots', () => {
  it('cả 5 bữa: đúng tỉ lệ mặc định, tổng = chỉ tiêu ngày', () => {
    const r = allocateSlots(T, cfg({}));
    const m = by(r);
    expect(m.lunch!.kcal).toBeCloseTo(770, 5);
    expect(m.breakfast!.kcal).toBeCloseTo(440, 5);
    expect(m.snack_am!.protein_g).toBeCloseTo(8.75, 5);
    expect(sum(r.map((s) => s.kcal))).toBeCloseTo(2200, 5);
    expect(sum(r.map((s) => s.protein_g))).toBeCloseTo(175, 5);
  });

  it('chỉ trưa + tối: chia lại 50/50', () => {
    const r = allocateSlots(T, cfg({ breakfast: 'skip', snack_am: 'skip', snack_pm: 'skip' }));
    const m = by(r);
    expect(m.lunch!.kcal).toBeCloseTo(1100, 5);
    expect(m.dinner!.protein_g).toBeCloseTo(87.5, 5);
    expect(m.breakfast!.kcal).toBe(0);
    expect(m.breakfast!.planned).toBe(false);
  });

  it('có phụ chiều (sáng + trưa + tối + phụ chiều)', () => {
    const r = allocateSlots(T, cfg({ snack_am: 'skip' }));
    const m = by(r);
    expect(m.snack_pm!.share).toBeCloseTo(0.05 / 0.95, 6);
    expect(sum(r.map((s) => s.kcal))).toBeCloseTo(2200, 5);
  });

  it('sáng tự lo: giữ phần chỉ tiêu nhưng không lên món; tổng on+self = chỉ tiêu', () => {
    const r = allocateSlots(T, cfg({ breakfast: 'self', snack_am: 'skip', snack_pm: 'skip' }));
    const m = by(r);
    expect(m.breakfast).toMatchObject({ mode: 'self', planned: false });
    expect(m.breakfast!.kcal).toBeCloseTo(2200 * 0.2 / 0.9, 5);
    expect(sum(r.filter((s) => s.mode !== 'skip').map((s) => s.kcal))).toBeCloseTo(2200, 5);
    expect(sum(r.filter((s) => s.planned).map((s) => s.kcal))).toBeLessThan(2200);
  });

  it('bỏ bữa (skip) chia lại cho các bữa còn lại', () => {
    const all = by(allocateSlots(T, cfg({})));
    const noBf = by(allocateSlots(T, cfg({ breakfast: 'skip' })));
    expect(noBf.lunch!.kcal).toBeGreaterThan(all.lunch!.kcal);
  });

  it('lỗi khi không còn bữa chính nào ở chế độ on', () => {
    expect(() => allocateSlots(T, cfg({ breakfast: 'skip', lunch: 'self', dinner: 'skip' }))).toThrow(NoMainMealError);
    expect(() => allocateSlots(T, cfg({ breakfast: 'skip', lunch: 'skip', dinner: 'skip' }))).toThrow(NoMainMealError);
  });

  it('chỉ có bữa phụ on thì vẫn lỗi (bữa phụ không phải bữa chính)', () => {
    expect(() => allocateSlots(T, cfg({ breakfast: 'skip', lunch: 'skip', dinner: 'skip' }))).toThrow();
  });
});
