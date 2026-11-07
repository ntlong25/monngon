import { describe, expect, it } from 'vitest';
import { bannedIngredients, filterRecipes, recipesForSlot } from './filter.ts';
import { basePrefs, fixtureDataset } from './__fixtures__/index.ts';
import type { Preferences } from '../types/profile.ts';

const ds = fixtureDataset();
const run = (over: Partial<Preferences>) => {
  const prefs = basePrefs(over);
  return { prefs, ...filterRecipes(ds.recipes, ds.ingredientsById, prefs) };
};
const ids = (r: { valid: { recipe: { id: string } }[] }) => r.valid.map((v) => v.recipe.id).sort();

describe('filterRecipes', () => {
  it('không ràng buộc: giữ mọi công thức đủ dụng cụ', () => {
    const r = run({});
    expect(ids(r)).toHaveLength(7);
    expect(r.excluded.size).toBe(0);
  });

  it('Không lợn loại món thịt heo, ghi lý do', () => {
    const r = run({ exclusions: ['no_pork'] });
    expect(ids(r)).not.toContain('thit_heo_rang_rau_muong');
    expect(r.excluded.get('thit_heo_rang_rau_muong')![0]).toContain('thit_nac_heo(no_pork)');
  });

  it('Không thịt đỏ / không cá / không trứng / không sữa / không đậu nành', () => {
    expect(run({ exclusions: ['no_red_meat'] }).excluded.has('thit_heo_rang_rau_muong')).toBe(true);
    expect(run({ exclusions: ['no_fish'] }).excluded.has('ca_basa_kho_rau_muong')).toBe(true);
    const egg = run({ exclusions: ['no_egg'] });
    expect(egg.excluded.has('trung_chien_com')).toBe(true);
    expect(egg.excluded.has('dau_phu_sot_trung')).toBe(true);
    expect(run({ exclusions: ['no_soy'] }).excluded.has('dau_phu_sot_trung')).toBe(true);
    expect(run({ exclusions: ['no_dairy'] }).excluded.size).toBe(0);
  });

  it('Không lạc loại lạc; không loại hạt điều/hướng dương', () => {
    const r = run({ exclusions: ['no_peanut'] });
    expect(r.excluded.has('lac_rang_muoi')).toBe(true);
    expect(r.excluded.has('hat_dieu_huong_duong')).toBe(false);
  });

  it('Không hạt cây không loại lạc/hạt hướng dương, chỉ loại hạt điều', () => {
    const banned = bannedIngredients(ds.ingredients, basePrefs({ exclusions: ['no_tree_nut'] }));
    expect([...banned.keys()]).toEqual(['hat_dieu']);
    const r = run({ exclusions: ['no_tree_nut'] });
    expect(r.excluded.has('lac_rang_muoi')).toBe(false);
    expect(r.excluded.has('hat_dieu_huong_duong')).toBe(true); // vì chứa hạt điều
  });

  it('Không hạt giống chỉ loại hướng dương; không loại lạc', () => {
    const banned = bannedIngredients(ds.ingredients, basePrefs({ exclusions: ['no_seed'] }));
    expect([...banned.keys()]).toEqual(['hat_huong_duong']);
  });

  it('chế độ chay: loại thịt/cá nhưng giữ trứng; thuần chay loại luôn trứng', () => {
    const veg = run({ diet: 'vegetarian' });
    expect(ids(veg)).toEqual(['dau_phu_sot_trung', 'hat_dieu_huong_duong', 'lac_rang_muoi', 'trung_chien_com']);
    const vegan = run({ diet: 'vegan' });
    expect(ids(vegan)).toEqual(['hat_dieu_huong_duong', 'lac_rang_muoi']);
    expect(vegan.excluded.get('trung_chien_com')![0]).toContain('diet:vegan');
  });

  it('chay có cá (pescatarian) giữ cá', () => {
    const r = run({ diet: 'pescatarian' });
    expect(ids(r)).toContain('ca_basa_kho_rau_muong');
    expect(ids(r)).not.toContain('uc_ga_xao_sup_lo_toi');
  });

  it('nguyên liệu không muốn thấy (ghét)', () => {
    const r = run({ disliked_ingredient_ids: ['rau_muong'] });
    expect(r.excluded.has('ca_basa_kho_rau_muong')).toBe(true);
    expect(r.excluded.get('thit_heo_rang_rau_muong')![0]).toContain('disliked');
  });

  it('công thức bị chặn', () => {
    expect(run({ blocked_recipe_ids: ['trung_chien_com'] }).excluded.get('trung_chien_com')).toEqual(['blocked']);
  });

  it('thiếu dụng cụ', () => {
    const r = run({ equipment: ['noi_com_dien'] });
    expect(r.excluded.get('uc_ga_xao_sup_lo_toi')).toEqual(['equipment:bep']);
    expect(ids(r)).toEqual(['hat_dieu_huong_duong', 'lac_rang_muoi']); // không cần dụng cụ
    expect(run({ equipment: ['bep'] }).excluded.get('dau_phu_sot_trung')).toEqual(['equipment:lo_vi_song']);
  });

  it('nhiều ràng buộc cộng dồn lý do', () => {
    const r = run({ exclusions: ['no_pork', 'no_red_meat'] });
    expect(r.excluded.get('thit_heo_rang_rau_muong')![0]).toContain('no_pork+no_red_meat');
  });

  it('tham chiếu ingredient lạ → loại với lý do', () => {
    const bad = { ...ds.recipes[0]!, id: 'mon_loi', ingredients: [{ ...ds.recipes[0]!.ingredients[0]!, ingredient_id: 'ma_ghe' }] };
    const r = filterRecipes([bad], ds.ingredientsById, basePrefs({}));
    expect(r.excluded.get('mon_loi')![0]).toContain('unknown_ingredient');
  });
});

describe('recipesForSlot', () => {
  const valid = run({}).valid;
  const cfg = { lunch_style: 'hot', snack_pm_style: 'savory' } as const;
  const idsOf = (x: { recipe: { id: string } }[]) => x.map((v) => v.recipe.id).sort();

  it('khớp meal_type', () => {
    expect(idsOf(recipesForSlot(valid, 'breakfast', cfg, false))).toEqual(['trung_chien_com']);
    expect(idsOf(recipesForSlot(valid, 'snack_pm', cfg, false))).toEqual(['hat_dieu_huong_duong', 'lac_rang_muoi']);
  });

  it('trưa mang đi chỉ nhận món packed', () => {
    const hot = idsOf(recipesForSlot(valid, 'lunch', cfg, false));
    const packed = idsOf(recipesForSlot(valid, 'lunch', { ...cfg, lunch_style: 'packed' }, false));
    expect(hot).toContain('ca_basa_kho_rau_muong');
    expect(packed).not.toContain('ca_basa_kho_rau_muong');
  });

  it('phụ chiều ngọt: không có món mặn', () => {
    expect(recipesForSlot(valid, 'snack_pm', { ...cfg, snack_pm_style: 'sweet' }, false)).toEqual([]);
  });

  it('Ít tinh bột: trưa/tối chỉ is_low_carb và ép carb = 0; sáng/phụ không bị ảnh hưởng', () => {
    const lunch = recipesForSlot(valid, 'lunch', cfg, true);
    expect(idsOf(lunch)).toEqual(['dau_phu_sot_trung', 'uc_ga_xao_sup_lo_toi']);
    expect(lunch.every((v) => v.forceZeroCarb)).toBe(true);
    const bf = recipesForSlot(valid, 'breakfast', cfg, true);
    expect(bf).toHaveLength(1);
    expect(bf[0]!.forceZeroCarb).toBe(false);
  });
});
