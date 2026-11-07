import { describe, expect, it } from 'vitest';
import { addMacros, computeMacros, formatSource, recipeBaseLines, roundForDisplay, ZERO_MACROS } from './nutrition.ts';
import { toHouseholdUnit } from './units.ts';
import { fixtureDataset } from './__fixtures__/index.ts';

const ds = fixtureDataset();

describe('computeMacros', () => {
  it('khớp tính tay: ức gà xào súp lơ (150/150/150/10 g)', () => {
    const r = computeMacros(recipeBaseLines(ds.recipesById.get('uc_ga_xao_sup_lo_toi')!), ds.ingredientsById);
    // protein: 150×.225 + 150×.027 + 150×.028 = 33.75+4.05+4.2 = 42
    expect(r.total.protein_g).toBeCloseTo(42, 6);
    // kcal: 180 + 195 + 51 + 88.4 = 514.4
    expect(r.total.kcal).toBeCloseTo(514.4, 6);
    // carb: 0 + 42 + 9.9 + 0 = 51.9 ; fat: 3.9+0.45+0.6+10 = 14.95
    expect(r.total.carb_g).toBeCloseTo(51.9, 6);
    expect(r.total.fat_g).toBeCloseTo(14.95, 6);
  });

  it('tổng = Σ các dòng', () => {
    const r = computeMacros(recipeBaseLines(ds.recipesById.get('ca_basa_kho_rau_muong')!), ds.ingredientsById);
    const sum = r.lines.reduce((a, l) => addMacros(a, l.macros), ZERO_MACROS);
    expect(sum).toEqual(r.total);
  });

  it('mỗi dòng có đủ db + code nguồn', () => {
    const r = computeMacros([{ ingredient_id: 'uc_ga_khong_da', grams: 100 }, { ingredient_id: 'com_trang', grams: 100 }], ds.ingredientsById);
    expect(r.lines.map((l) => l.source.db)).toEqual(['VN_FCT_2007', 'USDA_FDC']);
    for (const l of r.lines) expect(l.source.code).toBeTruthy();
    expect(formatSource(r.lines[0]!.source)).toBe('Bảng TPDD VN 2007 · mã fixture-1');
    expect(formatSource(r.lines[1]!.source)).toBe('USDA FDC #fixture-2');
  });

  it('nguyên liệu lạ → lỗi', () => {
    expect(() => computeMacros([{ ingredient_id: 'ma_ghe', grams: 1 }], ds.ingredientsById)).toThrow(/ma_ghe/);
  });

  it('0 gram → 0 macro', () => {
    expect(computeMacros([{ ingredient_id: 'com_trang', grams: 0 }], ds.ingredientsById).total).toEqual(ZERO_MACROS);
  });
});

describe('roundForDisplay', () => {
  it('protein 1 g, kcal 5 kcal; không đổi giá trị gốc', () => {
    const m = { kcal: 514.4, protein_g: 42.4, carb_g: 51.9, fat_g: 14.95, fiber_g: 2.1 };
    const copy = { ...m };
    expect(roundForDisplay(m)).toEqual({ kcal: 515, protein_g: 42, carb_g: 52, fat_g: 15, fiber_g: 2 });
    expect(m).toEqual(copy);
    expect(roundForDisplay({ ...m, kcal: 512.4 }).kcal).toBe(510);
  });
});

describe('toHouseholdUnit', () => {
  const oil = ds.ingredientsById.get('dau_an')!.household_units; // thìa canh 10 g, thìa cà phê 4 g
  it('10 g dầu → ≈ 1 thìa canh', () => {
    expect(toHouseholdUnit(10, oil)).toMatchObject({ unit: 'thìa canh', count: 1, text: '≈ 1 thìa canh' });
  });
  it('chọn đơn vị gần nhất: 4 g → thìa cà phê', () => {
    expect(toHouseholdUnit(4, oil)?.unit).toBe('thìa cà phê');
  });
  it('15 g → 1 1/2 thìa canh', () => {
    expect(toHouseholdUnit(15, oil)?.text).toBe('≈ 1 1/2 thìa canh');
  });
  it('không đơn vị hoặc sai lệch lớn → null', () => {
    expect(toHouseholdUnit(100, [])).toBeNull();
    expect(toHouseholdUnit(7, [{ unit: 'bát', grams: 150 }])).toBeNull();
    expect(toHouseholdUnit(0, oil)).toBeNull();
  });
  it('bát cơm: 150 g → 1 bát; 75 g → 1/2 bát', () => {
    const rice = ds.ingredientsById.get('com_trang')!.household_units;
    expect(toHouseholdUnit(150, rice)?.text).toBe('≈ 1 bát');
    expect(toHouseholdUnit(75, rice)?.text).toBe('≈ 1/2 bát');
  });
});
