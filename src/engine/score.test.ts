import { describe, expect, it } from 'vitest';
import { DEFAULT_SCORE_WEIGHTS, mainProteinId, rankRecipes, scoreRecipe, type ScoreContext } from './score.ts';
import { fixtureDataset } from './__fixtures__/index.ts';
import { recipeServingCostVnd } from './shopping.ts';

const ds = fixtureDataset();
const R = (id: string) => ds.recipesById.get(id)!;
const ctx = (over: Partial<ScoreContext> = {}): ScoreContext => ({
  cuisine_likes: [], cuisine_less: [], health_leanings: [], cost_vnd: 30000, cost_reference_vnd: 30000,
  uses_this_week: 0, same_day_recipe_ids: [], recent_main_proteins: [], ...over,
});
const total = (id: string, c: Partial<ScoreContext> = {}) => scoreRecipe(R(id), ctx(c)).total;

describe('scoreRecipe', () => {
  it('trung tính → 0', () => {
    expect(total('uc_ga_xao_sup_lo_toi')).toBe(0);
  });

  it('thích > trung tính > ít hơn', () => {
    const like = total('ca_basa_kho_rau_muong', { cuisine_likes: ['kho'] });
    const neutral = total('ca_basa_kho_rau_muong');
    const less = total('ca_basa_kho_rau_muong', { cuisine_less: ['kho'] });
    expect(like).toBeGreaterThan(neutral);
    expect(neutral).toBeGreaterThan(less);
  });

  it('xu hướng sức khỏe cộng điểm', () => {
    expect(total('uc_ga_xao_sup_lo_toi', { health_leanings: ['nhieu_xo'] })).toBeGreaterThan(total('uc_ga_xao_sup_lo_toi'));
    expect(total('ca_basa_kho_rau_muong', { health_leanings: ['nhieu_xo'] })).toBe(0); // món không có thẻ này
  });

  it('rẻ hơn tham chiếu được điểm cao hơn; đắt bị trừ; có chặn trên', () => {
    const cheap = total('uc_ga_xao_sup_lo_toi', { cost_vnd: 20000 });
    const dear = total('uc_ga_xao_sup_lo_toi', { cost_vnd: 45000 });
    expect(cheap).toBeGreaterThan(0);
    expect(dear).toBeLessThan(0);
    expect(total('uc_ga_xao_sup_lo_toi', { cost_vnd: 1e9 })).toBe(-DEFAULT_SCORE_WEIGHTS.cost);
  });

  it('dùng chi phí thật từ bảng giá', () => {
    const cost = (id: string) => recipeServingCostVnd(R(id), ds, 'cho_khac');
    expect(cost('uc_ga_xao_sup_lo_toi')).toBeGreaterThan(cost('dau_phu_sot_trung'));
  });

  it('nấu 1 lần ăn 2 bữa không bị phạt; lần thứ 3 trở đi bị phạt', () => {
    expect(total('uc_ga_xao_sup_lo_toi', { uses_this_week: 1 })).toBe(0);
    expect(total('uc_ga_xao_sup_lo_toi', { uses_this_week: 2 })).toBe(0);
    expect(total('uc_ga_xao_sup_lo_toi', { uses_this_week: 3 })).toBeLessThan(0);
    expect(total('uc_ga_xao_sup_lo_toi', { uses_this_week: 5 })).toBeLessThan(total('uc_ga_xao_sup_lo_toi', { uses_this_week: 3 }));
  });

  it('trùng món trong cùng ngày bị phạt nặng', () => {
    expect(total('uc_ga_xao_sup_lo_toi', { same_day_recipe_ids: ['uc_ga_xao_sup_lo_toi'] })).toBe(-DEFAULT_SCORE_WEIGHTS.sameDay);
    expect(total('uc_ga_xao_sup_lo_toi', { same_day_recipe_ids: ['trung_chien_com'] })).toBe(0);
  });

  it('đơn điệu: cùng protein chính nhiều bữa gần đây bị phạt, chỉ tính trong cửa sổ', () => {
    expect(mainProteinId(R('uc_ga_xao_sup_lo_toi'))).toBe('uc_ga_khong_da');
    const one = total('uc_ga_xao_sup_lo_toi', { recent_main_proteins: ['uc_ga_khong_da'] });
    const two = total('uc_ga_xao_sup_lo_toi', { recent_main_proteins: ['uc_ga_khong_da', 'uc_ga_khong_da'] });
    expect(two).toBeLessThan(one);
    expect(one).toBeLessThan(0);
    expect(total('uc_ga_xao_sup_lo_toi', { recent_main_proteins: ['uc_ga_khong_da', 'thit_nac_heo', 'trung_ga', 'dau_phu'] })).toBe(0);
    expect(total('uc_ga_xao_sup_lo_toi', { recent_main_proteins: ['thit_nac_heo', 'trung_ga'] })).toBe(0);
  });

  it('thành phần cộng đúng vào tổng', () => {
    const b = scoreRecipe(R('ca_basa_kho_rau_muong'), ctx({ cuisine_likes: ['kho'], cost_vnd: 20000, uses_this_week: 4 }));
    expect(b.total).toBeCloseTo(b.likes + b.less + b.health + b.cost + b.repeat + b.sameDay + b.monotony, 9);
  });

  it('trọng số cấu hình được', () => {
    const w = { ...DEFAULT_SCORE_WEIGHTS, cuisineLike: 100 };
    expect(scoreRecipe(R('ca_basa_kho_rau_muong'), ctx({ cuisine_likes: ['kho'] }), w).total).toBe(100);
  });
});

describe('rankRecipes', () => {
  const items = ds.recipes.filter((r) => r.meal_types.includes('lunch')).map((recipe) => ({ recipe, forceZeroCarb: false }));

  it('thứ tự đúng theo sở thích, tất định', () => {
    const rank = (c: Partial<ScoreContext>) => rankRecipes(items, () => ctx(c)).map((x) => x.recipe.id);
    expect(rank({ cuisine_likes: ['kho'] })[0]).toBe('ca_basa_kho_rau_muong');
    expect(rank({ cuisine_less: ['xao'] }).slice(-2)).toEqual(expect.arrayContaining(['uc_ga_xao_sup_lo_toi', 'thit_heo_rang_rau_muong']));
    expect(rank({})).toEqual(rank({})); // hòa điểm → xếp theo id
    expect(rank({})).toEqual([...rank({})].sort());
  });

  it('tuần có sở thích: món "thích" lên đầu hơn so với không có sở thích (US-2.4 AC2)', () => {
    const pos = (list: string[], id: string) => list.indexOf(id);
    const without = rankRecipes(items, () => ctx()).map((x) => x.recipe.id);
    const withLike = rankRecipes(items, () => ctx({ cuisine_likes: ['chay_mem'] })).map((x) => x.recipe.id);
    expect(pos(withLike, 'dau_phu_sot_trung')).toBeLessThan(pos(without, 'dau_phu_sot_trung'));
  });
});
