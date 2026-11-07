import { describe, expect, it } from 'vitest';
import { scaleRecipe } from './scale.ts';
import { computeMacros, recipeBaseLines } from './nutrition.ts';
import { fixtureDataset } from './__fixtures__/index.ts';

const ds = fixtureDataset();
const R = (id: string) => ds.recipesById.get(id)!;
const gramsOf = (res: ReturnType<typeof scaleRecipe>, id: string) => res.grams.find((g) => g.ingredient_id === id)!.grams;

describe('scaleRecipe', () => {
  it('mục tiêu khả thi → protein ≤ 3 g, kcal ≤ 5%', () => {
    // Mục tiêu lấy từ 1 khẩu phần hợp lệ: ức gà 180 g + cơm 100 g.
    const r = R('uc_ga_xao_sup_lo_toi');
    const wanted = computeMacros(
      [{ ingredient_id: 'uc_ga_khong_da', grams: 180 }, { ingredient_id: 'com_trang', grams: 100 },
       { ingredient_id: 'sup_lo_xanh', grams: 150 }, { ingredient_id: 'dau_an', grams: 10 }], ds.ingredientsById).total;
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: wanted.kcal, protein_g: wanted.protein_g });
    expect(Math.abs(res.deviation.protein_g)).toBeLessThanOrEqual(3);
    expect(Math.abs(res.deviation.kcal_pct)).toBeLessThanOrEqual(0.05);
    expect(res.infeasible).toBe(false);
  });

  it('nhiều mục tiêu khả thi khác nhau đều đạt dung sai', () => {
    const r = R('ca_basa_kho_rau_muong');
    for (const [pg, cg] of [[120, 80], [200, 200], [250, 60], [100, 250], [300, 300]] as const) {
      const w = computeMacros(
        [{ ingredient_id: 'ca_basa_phi_le', grams: pg }, { ingredient_id: 'com_trang', grams: cg },
         { ingredient_id: 'rau_muong', grams: 120 }, { ingredient_id: 'dau_an', grams: 8 }], ds.ingredientsById).total;
      const res = scaleRecipe(r, ds.ingredientsById, { kcal: w.kcal, protein_g: w.protein_g });
      expect(Math.abs(res.deviation.protein_g)).toBeLessThanOrEqual(3);
      expect(Math.abs(res.deviation.kcal_pct)).toBeLessThanOrEqual(0.05);
      expect(res.infeasible).toBe(false);
    }
  });

  it('gram nằm trong biên, bước 5 g; vai trò khác giữ nguyên', () => {
    const r = R('uc_ga_xao_sup_lo_toi');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 700, protein_g: 55 });
    for (const [i, li] of r.ingredients.entries()) {
      const g = res.grams[i]!.grams;
      expect(g).toBeGreaterThanOrEqual(li.min_g);
      expect(g).toBeLessThanOrEqual(li.max_g);
      if (li.role === 'protein' || li.role === 'carb') expect(g % 5).toBe(0);
      else expect(g).toBe(li.grams);
    }
  });

  it('macro trả về khớp computeMacros trên gram đã scale', () => {
    const r = R('thit_heo_rang_rau_muong');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 650, protein_g: 45 });
    const check = computeMacros(res.grams, ds.ingredientsById).total;
    expect(res.macros.kcal).toBeCloseTo(check.kcal, 6);
    expect(res.macros.protein_g).toBeCloseTo(check.protein_g, 6);
  });

  it('bất khả thi → nghiệm gần nhất + cờ infeasible (protein quá cao)', () => {
    const r = R('uc_ga_xao_sup_lo_toi');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 600, protein_g: 120 });
    expect(res.infeasible).toBe(true);
    expect(res.deviation.protein_g).toBeLessThan(-3);
    expect(gramsOf(res, 'uc_ga_khong_da')).toBe(250); // đẩy protein lên tối đa trong biên
  });

  it('bất khả thi → kcal quá thấp cho protein cần có', () => {
    const r = R('uc_ga_xao_sup_lo_toi');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 200, protein_g: 40 });
    expect(res.infeasible).toBe(true);
  });

  it('ưu tiên đạt protein trước khi phải đánh đổi', () => {
    const r = R('ca_basa_kho_rau_muong');
    // protein 60 g cần ≥ ~ 300 g cá nhưng kcal chỉ cho 450: giữ protein, chấp nhận kcal vượt.
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 450, protein_g: 50 });
    expect(res.deviation.protein_g).toBeGreaterThan(-3.01);
  });

  it('forceZeroCarb ép carb = 0 g', () => {
    const r = R('uc_ga_xao_sup_lo_toi');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 450, protein_g: 45 }, { forceZeroCarb: true });
    expect(gramsOf(res, 'com_trang')).toBe(0);
    expect(res.macros.carb_g).toBeLessThan(15); // chỉ còn carb của rau
  });

  it('tất định', () => {
    const r = R('dau_phu_sot_trung');
    const a = scaleRecipe(r, ds.ingredientsById, { kcal: 550, protein_g: 40 });
    const b = scaleRecipe(r, ds.ingredientsById, { kcal: 550, protein_g: 40 });
    expect(a).toEqual(b);
  });

  it('nhiều nguyên liệu vai trò protein (đậu phụ + trứng) cùng được scale', () => {
    const r = R('dau_phu_sot_trung');
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: 700, protein_g: 60 });
    expect(Math.abs(res.deviation.protein_g)).toBeLessThanOrEqual(3);
  });

  it('chạy < 2 ms mỗi công thức (trung bình, sau khởi động)', () => {
    const recs = ds.recipes.filter((x) => x.meal_types.includes('lunch'));
    for (const r of recs) scaleRecipe(r, ds.ingredientsById, { kcal: 700, protein_g: 45 }); // warm-up
    const N = 200;
    const t0 = performance.now();
    for (let i = 0; i < N; i++) for (const r of recs) scaleRecipe(r, ds.ingredientsById, { kcal: 700, protein_g: 45 });
    const avg = (performance.now() - t0) / (N * recs.length);
    expect(avg).toBeLessThan(2);
  });

  it('khẩu phần chuẩn gốc → gần mục tiêu chính nó', () => {
    const r = R('trung_chien_com');
    const base = computeMacros(recipeBaseLines(r), ds.ingredientsById).total;
    const res = scaleRecipe(r, ds.ingredientsById, { kcal: base.kcal, protein_g: base.protein_g });
    expect(res.infeasible).toBe(false);
  });
});
