import { describe, expect, it } from 'vitest';
import { formatIssue, validateDataset, kcalDeviation } from './validate.ts';
import { buildDataset, findPrice, loadDataset } from './load.ts';
import { rawFixture } from '../engine/__fixtures__/index.ts';

const clone = <T>(x: T): T => structuredClone(x);
type Raw = { ingredients: any[]; recipes: any[]; stores: any[]; prices: any[] };
const raw = (): Raw => clone(rawFixture) as unknown as Raw;
const errors = (r: Raw) => validateDataset(r).filter((i) => i.severity === 'error');

describe('validateDataset', () => {
  it('fixture hợp lệ: 0 lỗi', () => {
    expect(errors(raw())).toEqual([]);
  });

  it('lỗi schema chỉ rõ file + id + trường', () => {
    const r = raw();
    r.ingredients[0].aisle = 'khong_co';
    const [e] = errors(r);
    expect(e).toMatchObject({ file: 'ingredients', id: 'uc_ga_khong_da', field: 'aisle' });
    expect(formatIssue(e!)).toContain('ingredients.json · uc_ga_khong_da · aisle');
  });

  it('id sai định dạng bị báo', () => {
    const r = raw();
    r.recipes[0].id = 'Ức gà';
    expect(errors(r).some((e) => e.file === 'recipes' && e.field === 'id')).toBe(true);
  });

  it('id trùng', () => {
    const r = raw();
    r.ingredients.push(clone(r.ingredients[0]));
    expect(errors(r).some((e) => e.message.includes('trùng') && e.id === 'uc_ga_khong_da')).toBe(true);
  });

  it('tham chiếu ingredient_id không tồn tại (recipe)', () => {
    const r = raw();
    r.recipes[0].ingredients[0].ingredient_id = 'ma_ghe';
    expect(errors(r)).toContainEqual(
      expect.objectContaining({ file: 'recipes', id: 'uc_ga_xao_sup_lo_toi', field: 'ingredients[0].ingredient_id' }),
    );
  });

  it('tham chiếu store_id / ingredient_id không tồn tại (price)', () => {
    const r = raw();
    r.prices.push({ ingredient_id: 'ma_ghe', store_id: 'cho_ao', pack_g: 100, pack_label: 'x', price_vnd: 1, shelf_life_days: 1 });
    const fields = errors(r).filter((e) => e.file === 'prices').map((e) => e.field);
    expect(fields).toEqual(expect.arrayContaining(['ingredient_id', 'store_id']));
  });

  it('min_g ≤ grams ≤ max_g', () => {
    const r = raw();
    r.recipes[0].ingredients[0].min_g = 200;
    expect(errors(r).some((e) => e.field === 'ingredients[0].grams')).toBe(true);
  });

  it('vai trò không phải protein/carb phải cố định', () => {
    const r = raw();
    r.recipes[0].ingredients[2].max_g = 300;
    expect(errors(r).some((e) => e.field === 'ingredients[2].min_g/max_g')).toBe(true);
  });

  it('is_low_carb yêu cầu carb min_g = 0', () => {
    const r = raw();
    r.recipes[0].ingredients[1].min_g = 50;
    expect(errors(r).some((e) => e.field === 'is_low_carb')).toBe(true);
  });

  it('mọi nguyên liệu phải có giá cho_khac', () => {
    const r = raw();
    r.prices = r.prices.filter((p) => !(p.ingredient_id === 'dau_phu' && p.store_id === 'cho_khac'));
    expect(errors(r)).toContainEqual(expect.objectContaining({ file: 'prices', id: 'dau_phu@cho_khac' }));
  });

  describe('purchase_as (D-SHP-02)', () => {
    // dựng: dau_phu quy đổi sang uc_ga_khong_da (cả hai có trong fixture); bỏ giá cho_khac của dau_phu
    const withPurchaseAs = (): Raw => {
      const r = raw();
      r.ingredients.find((i) => i.id === 'dau_phu').purchase_as = { ingredient_id: 'uc_ga_khong_da', factor: 0.5 };
      r.prices = r.prices.filter((p) => !(p.ingredient_id === 'dau_phu' && p.store_id === 'cho_khac'));
      return r;
    };

    it('nguyên liệu có purchase_as không cần giá cho_khac riêng', () => {
      expect(errors(withPurchaseAs())).toEqual([]);
    });

    it('đích không có giá cho_khac, không tồn tại, tự trỏ hoặc nối chuỗi đều là lỗi', () => {
      const noPrice = withPurchaseAs();
      noPrice.prices = noPrice.prices.filter((p) => !(p.ingredient_id === 'uc_ga_khong_da' && p.store_id === 'cho_khac'));
      expect(errors(noPrice)).toContainEqual(expect.objectContaining({ id: 'dau_phu', field: 'purchase_as.ingredient_id' }));

      const missing = withPurchaseAs();
      missing.ingredients.find((i) => i.id === 'dau_phu').purchase_as.ingredient_id = 'khong_co_gao';
      expect(errors(missing)).toContainEqual(expect.objectContaining({ id: 'dau_phu', field: 'purchase_as.ingredient_id' }));

      const self = withPurchaseAs();
      self.ingredients.find((i) => i.id === 'dau_phu').purchase_as.ingredient_id = 'dau_phu';
      expect(errors(self)).toContainEqual(expect.objectContaining({ id: 'dau_phu', field: 'purchase_as.ingredient_id' }));

      const chain = withPurchaseAs();
      chain.ingredients.find((i) => i.id === 'uc_ga_khong_da').purchase_as = { ingredient_id: 'dau_phu', factor: 1 };
      expect(errors(chain).some((e) => e.field === 'purchase_as.ingredient_id')).toBe(true);
    });

    it('factor ngoài (0, 1] là lỗi schema', () => {
      const r = withPurchaseAs();
      r.ingredients.find((i) => i.id === 'dau_phu').purchase_as.factor = 1.5;
      expect(errors(r).some((e) => e.field.includes('factor'))).toBe(true);
    });
  });

  it('kcal lệch 4/4/9 > 15% là cảnh báo, không phải lỗi', () => {
    const r = raw();
    r.ingredients[0].per_100g.kcal = 300;
    const all = validateDataset(r);
    expect(all.some((i) => i.severity === 'warning' && i.id === 'uc_ga_khong_da')).toBe(true);
    expect(all.some((i) => i.severity === 'error')).toBe(false);
  });

  it('không phải mảng → lỗi (root)', () => {
    const r = raw();
    (r as any).stores = { a: 1 };
    expect(errors(r).some((e) => e.file === 'stores' && e.field === '(root)')).toBe(true);
  });

  it('kcalDeviation: rau ít kcal vẫn đạt nhờ xơ', () => {
    expect(kcalDeviation({ kcal: 34, protein_g: 2.8, carb_g: 6.6, fat_g: 0.4, fiber_g: 2.6 })).toBeLessThan(0.15);
  });
});

describe('load', () => {
  it('index theo id và giá fallback', () => {
    const ds = loadDataset(rawFixture);
    expect(ds.ingredientsById.get('com_trang')?.name).toBe('Cơm trắng');
    expect(ds.recipesById.size).toBe(7);
    expect(findPrice(ds, 'uc_ga_khong_da', 'winmart')).toMatchObject({ fallback: false });
    expect(findPrice(ds, 'uc_ga_khong_da', 'coopmart')).toMatchObject({ fallback: true });
    expect(findPrice(ds, 'khong_co', 'winmart')).toBeUndefined();
  });

  it('loadDataset throw khi sai schema', () => {
    const r = raw();
    r.ingredients[0].aisle = 'x';
    expect(() => loadDataset(r)).toThrow();
  });

  it('buildDataset dùng được trực tiếp', () => {
    const ds = buildDataset({ ingredients: [], recipes: [], stores: [], prices: [] });
    expect(ds.pricesByIngredient.size).toBe(0);
  });
});
