import { describe, expect, it } from 'vitest';
import { buildShoppingList, defaultPantryIds, otherEatersFactor, recipeServingCostVnd, servingCostVnd } from './shopping.ts';
import { fixtureDataset } from './__fixtures__/index.ts';

const ds = fixtureDataset();
const meal = (id: string, grams: number, std = grams) => ({ ingredients: [{ ingredient_id: id, grams, standard_grams: std }] });
const solo = { adults: 1, children: 0 };
const item = (l: ReturnType<typeof buildShoppingList>, id: string) => l.items.find((i) => i.ingredient_id === id)!;

describe('buildShoppingList', () => {
  it('410 g ức gà → 1 khay 500 g, dư 90 g', () => {
    const l = buildShoppingList([meal('uc_ga_khong_da', 410)], solo, ds, { store_id: 'winmart' });
    const it = item(l, 'uc_ga_khong_da');
    expect(it).toMatchObject({ packs: 1, pack_g: 500, pack_label: 'khay 500 g', price_fallback: false });
    expect(it.leftover_g).toBeCloseTo(90, 6);
    expect(it.leftover_days).toBe(3);
  });

  it('vượt 1 gói → làm tròn lên', () => {
    const l = buildShoppingList([meal('uc_ga_khong_da', 510)], solo, ds, { store_id: 'winmart' });
    expect(item(l, 'uc_ga_khong_da')).toMatchObject({ packs: 2 });
    expect(item(l, 'uc_ga_khong_da').leftover_g).toBeCloseTo(490, 6);
  });

  it('đúng bằng 1 gói thì không mua thêm', () => {
    const l = buildShoppingList([meal('uc_ga_khong_da', 500)], solo, ds, { store_id: 'winmart' });
    expect(item(l, 'uc_ga_khong_da').packs).toBe(1);
  });

  it('cửa hàng thiếu giá → fallback cho_khac, có cờ', () => {
    const l = buildShoppingList([meal('uc_ga_khong_da', 410)], solo, ds, { store_id: 'coopmart' });
    const it = item(l, 'uc_ga_khong_da');
    expect(it).toMatchObject({ price_fallback: true, price_store_id: 'cho_khac', pack_g: 100, packs: 5 });
    expect(it.till_cost_vnd).toBe(55000);
  });

  it('nhân hộ: bạn = gram scale; người lớn khác = chuẩn; trẻ em = 0,6', () => {
    expect(otherEatersFactor({ adults: 2, children: 1 })).toBeCloseTo(1.6, 6);
    const l = buildShoppingList([meal('uc_ga_khong_da', 200, 150)], { adults: 2, children: 1 }, ds, { store_id: 'winmart' });
    expect(item(l, 'uc_ga_khong_da').need_g).toBeCloseTo(200 + 150 * 1.6, 6); // 440
  });

  it('gộp nhiều bữa, nhóm theo quầy theo thứ tự cố định', () => {
    const meals = [meal('rau_muong', 100), meal('uc_ga_khong_da', 100), meal('rau_muong', 100), meal('dau_an', 10)];
    const l = buildShoppingList(meals, solo, ds, { store_id: 'winmart' });
    expect(l.byAisle.map((g) => g.aisle)).toEqual(['thit', 'rau_cu', 'gia_vi_dau']);
    expect(item(l, 'rau_muong').need_g).toBeCloseTo(200 / 0.7, 6); // tính phần bỏ đi
  });

  it('edible_portion: cần mua nhiều hơn lượng ăn', () => {
    const l = buildShoppingList([meal('sup_lo_xanh', 150)], solo, ds, { store_id: 'winmart' });
    expect(item(l, 'sup_lo_xanh').need_g).toBeCloseTo(187.5, 6);
  });

  it('nhà có sẵn → bỏ qua, không tính tiền', () => {
    const meals = [meal('dau_an', 10), meal('com_trang', 150), meal('uc_ga_khong_da', 100)];
    const pantry = defaultPantryIds(ds.ingredients);
    expect(pantry.sort()).toEqual(['com_trang', 'dau_an']);
    const l = buildShoppingList(meals, solo, ds, { store_id: 'winmart', pantry_ids: pantry });
    expect(l.items.map((i) => i.ingredient_id)).toEqual(['uc_ga_khong_da']);
    expect(l.skipped_pantry).toEqual(['com_trang', 'dau_an']);
    const all = buildShoppingList(meals, solo, ds, { store_id: 'winmart' });
    expect(all.till_cost).toBeGreaterThan(l.till_cost);
  });

  it('hai loại chi phí: theo gram dùng ≤ theo gói; cả hai làm tròn 1.000 ₫', () => {
    const l = buildShoppingList(
      [meal('uc_ga_khong_da', 410), meal('trung_ga', 200), meal('dau_phu', 120)], solo, ds, { store_id: 'winmart' },
    );
    expect(l.week_food_cost % 1000).toBe(0);
    expect(l.till_cost % 1000).toBe(0);
    expect(l.week_food_cost).toBeLessThanOrEqual(l.till_cost);
    // tay: 410/500×62000=50840 ; trứng 200/.88/550×32000=13223 ; đậu 120/300×12000=4800 ; tổng≈68863 → 69.000
    expect(l.week_food_cost).toBe(69000);
    // gói: 62000 + 32000 (1 vỉ) + 12000 = 106000
    expect(l.till_cost).toBe(106000);
  });

  it('không có giá ở cả hai nơi → lỗi rõ ràng', () => {
    const book = { ...ds, pricesByIngredient: new Map() };
    expect(() => buildShoppingList([meal('dau_an', 10)], solo, book, { store_id: 'winmart' })).toThrow(/dau_an/);
  });

  it('bỏ qua dòng 0 gram', () => {
    const l = buildShoppingList([meal('com_trang', 0)], solo, ds, { store_id: 'winmart' });
    expect(l.items).toEqual([]);
    expect(l.till_cost).toBe(0);
  });
});

describe('chi phí suất', () => {
  it('servingCostVnd theo gram dùng', () => {
    const c = servingCostVnd([{ ingredient_id: 'uc_ga_khong_da', grams: 150 }], ds, 'winmart');
    expect(c).toBeCloseTo(18600, 6);
  });
  it('recipeServingCostVnd cộng mọi dòng', () => {
    const c = recipeServingCostVnd(ds.recipesById.get('uc_ga_xao_sup_lo_toi')!, ds, 'winmart');
    // 18600 + 150/100×1500=2250 + 150/.8/400×24000=11250 + 10/1000×58000=580 = 32680
    expect(c).toBeCloseTo(32680, 4);
  });
});
