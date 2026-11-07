import { describe, expect, it } from 'vitest';
import { addDays, planWeek, type WeekPlan } from './planWeek.ts';
import { validateWeek } from './validate.ts';
import { computeTargets } from './targets.ts';
import { basePrefs, fixtureDataset } from './__fixtures__/index.ts';
import { computeMacros } from './nutrition.ts';
import { bannedIngredients } from './filter.ts';
import type { Preferences, Profile } from '../types/profile.ts';
import type { Targets } from './targets.ts';

const data = fixtureDataset();
const manual = (kcal: number, protein: number): Targets =>
  computeTargets({ goal: 'hold', sex: 'male', age: 30, height_cm: 175, weight_kg: 70, activity: 'moderate', target_mode: 'manual', manual_kcal: kcal, manual_protein_g: protein } as Profile);
const run = (targets: Targets, over: Partial<Preferences> = {}, seed = 1) =>
  planWeek({ targets, prefs: basePrefs({ weekly_budget_vnd: 1_000_000, ...over }), data, start_date: '2026-11-07', seed });
const mealsOf = (p: WeekPlan) => p.days.flatMap((d) => d.meals);

describe('validateWeek', () => {
  const T = { protein_g: 100, kcal_min: 1900, kcal_max: 2000 };
  const day = (date: string, protein_g: number, kcal: number, exempt = false) => ({ date, protein_g, kcal, exempt });

  it('đạt hết', () => {
    const v = validateWeek([day('a', 100, 1950), day('b', 120, 2000)], T, 500000, 400000);
    expect(v).toMatchObject({ ok: true, days_missing: 0, budget_over_vnd: 0, shortfalls: [] });
  });
  it('thiếu protein 1 ngày: báo đúng ngày và mức thiếu', () => {
    const v = validateWeek([day('thu5', 92, 1950), day('thu6', 100, 1950)], T, 1, 0);
    expect(v.ok).toBe(false);
    expect(v.days_missing).toBe(1);
    expect(v.shortfalls).toEqual([{ date: 'thu5', kind: 'protein_low', amount: 8 }]);
  });
  it('kcal dưới/trên dải', () => {
    const v = validateWeek([day('a', 100, 1800), day('b', 100, 2150)], T, 1, 0);
    expect(v.shortfalls).toEqual([
      { date: 'a', kind: 'kcal_low', amount: 100 },
      { date: 'b', kind: 'kcal_high', amount: 150 },
    ]);
  });
  it('nhiều lỗi cùng lúc trong một ngày', () => {
    const v = validateWeek([day('a', 80, 1700)], T, 1, 0);
    expect(v.shortfalls.map((s) => s.kind)).toEqual(['protein_low', 'kcal_low']);
    expect(v.days_missing).toBe(1);
  });
  it('vượt ngân sách', () => {
    const v = validateWeek([day('a', 100, 1950)], T, 500000, 530000);
    expect(v).toMatchObject({ ok: false, budget_over_vnd: 30000, days_missing: 0 });
  });
  it('ngày có bữa ăn ngoài (exempt) không tính là không đạt', () => {
    const v = validateWeek([day('a', 10, 100, true)], T, 1, 0);
    expect(v.ok).toBe(true);
    expect(v.shortfalls).toEqual([]);
  });
  it('không lấy trung bình tuần: 1 ngày thừa không bù ngày thiếu', () => {
    const v = validateWeek([day('a', 200, 1950), day('b', 90, 1950)], T, 1, 0);
    expect(v.days_missing).toBe(1);
  });
});

describe('planWeek — hồ sơ dễ', () => {
  const targets = manual(1800, 100);
  const plan = run(targets);

  it('7/7 ngày đạt, ready, trong ngân sách', () => {
    expect(plan.status).toBe('ready');
    expect(plan.validation.days_missing).toBe(0);
    expect(plan.days).toHaveLength(7);
    for (const d of plan.days) {
      expect(d.totals.protein_g).toBeGreaterThanOrEqual(targets.protein_g);
      expect(d.totals.kcal).toBeGreaterThanOrEqual(targets.kcal_min);
      expect(d.totals.kcal).toBeLessThanOrEqual(targets.kcal_max);
    }
    expect(plan.shopping.week_food_cost).toBeLessThanOrEqual(plan.budget_vnd);
    expect(plan.validation.budget_over_vnd).toBe(0);
  });

  it('ngày bắt đầu và 7 ngày liên tiếp; 3 bữa mỗi ngày', () => {
    expect(plan.days.map((d) => d.date)).toEqual(Array.from({ length: 7 }, (_, i) => addDays('2026-11-07', i)));
    expect(addDays('2026-12-30', 3)).toBe('2027-01-02');
    for (const d of plan.days) expect(d.meals.map((m) => m.slot).sort()).toEqual(['breakfast', 'dinner', 'lunch']);
  });

  it('macro mỗi bữa khớp tính lại từ gram', () => {
    for (const m of mealsOf(plan)) {
      const re = computeMacros(m.grams, data.ingredientsById).total;
      expect(m.macros.kcal).toBeCloseTo(re.kcal, 6);
      expect(m.macros.protein_g).toBeCloseTo(re.protein_g, 6);
    }
  });

  it('không có món chính giống nhau ở trưa và tối cùng ngày; có "nấu 1 lần ăn 2 bữa"', () => {
    for (const d of plan.days) {
      const l = d.meals.find((m) => m.slot === 'lunch')!;
      const di = d.meals.find((m) => m.slot === 'dinner')!;
      expect(l.recipe_id).not.toBe(di.recipe_id);
    }
    const groups = new Map<string, number>();
    for (const m of mealsOf(plan)) groups.set(m.batch_group_id!, (groups.get(m.batch_group_id!) ?? 0) + 1);
    expect([...groups.values()].some((n) => n === 2)).toBe(true);
    expect([...groups.values()].every((n) => n <= 2)).toBe(true);
  });
});

describe('planWeek — tất định', () => {
  it('cùng đầu vào + seed → cùng kết quả', () => {
    const t = manual(1800, 100);
    expect(run(t, {}, 42)).toEqual(run(t, {}, 42));
  });
  it('lập hai lần không đụng vào đầu vào', () => {
    const prefs = basePrefs({ weekly_budget_vnd: 1_000_000 });
    const snap = JSON.stringify(prefs);
    planWeek({ targets: manual(1800, 100), prefs, data, start_date: '2026-11-07', seed: 3 });
    expect(JSON.stringify(prefs)).toBe(snap);
  });
});

describe('planWeek — hồ sơ bất khả thi', () => {
  it('protein quá cao → partial, ngày + mức thiếu đúng với validator', () => {
    const targets = manual(1500, 250);
    const plan = run(targets);
    expect(plan.status).toBe('partial');
    expect(plan.validation.days_missing).toBeGreaterThan(0);
    const proteinShort = plan.validation.shortfalls.filter((s) => s.kind === 'protein_low');
    expect(proteinShort.length).toBeGreaterThan(0);
    for (const s of proteinShort) {
      const d = plan.days.find((x) => x.date === s.date)!;
      expect(s.amount).toBeCloseTo(targets.protein_g - d.totals.protein_g, 6);
    }
    // validator chạy lại độc lập cho cùng kết quả
    const again = validateWeek(plan.days.map((d) => ({ date: d.date, protein_g: d.totals.protein_g, kcal: d.totals.kcal })), targets, plan.budget_vnd, plan.shopping.week_food_cost);
    expect(again.shortfalls).toEqual(plan.validation.shortfalls);
  });

  it('ngân sách quá thấp → partial, báo mức vượt', () => {
    const plan = run(manual(1800, 100), { weekly_budget_vnd: 50_000 });
    expect(plan.status).toBe('partial');
    expect(plan.validation.budget_over_vnd).toBe(plan.shopping.week_food_cost - 50_000);
    expect(plan.validation.days_missing).toBe(0);
  });

  it('ngân sách chặt: các vòng thử lại ưu tiên món rẻ hơn', () => {
    const generous = run(manual(1800, 100), { weekly_budget_vnd: 5_000_000 });
    const tight = run(manual(1800, 100), { weekly_budget_vnd: generous.shopping.week_food_cost - 20_000 });
    expect(tight.shopping.week_food_cost).toBeLessThanOrEqual(generous.shopping.week_food_cost);
  });
});

describe('planWeek — ràng buộc cứng', () => {
  const cases: Partial<Preferences>[] = [
    { exclusions: ['no_pork'] }, { exclusions: ['no_fish', 'no_pork'] }, { diet: 'vegetarian' }, { exclusions: ['no_peanut', 'no_tree_nut'] },
    { disliked_ingredient_ids: ['rau_muong'] }, { blocked_recipe_ids: ['uc_ga_xao_sup_lo_toi'] }, { equipment: ['bep'] },
  ];
  it.each(cases.map((c, i) => [i, c] as const))('hồ sơ %i: không vi phạm', (_i, over) => {
    const prefs = basePrefs({ weekly_budget_vnd: 1_000_000, snack_pm: undefined, ...over } as Partial<Preferences>);
    const plan = planWeek({ targets: manual(1800, 90), prefs, data, start_date: '2026-11-07', seed: 5 });
    const banned = bannedIngredients(data.ingredients, prefs);
    for (const m of mealsOf(plan)) {
      if (!m.recipe_id) continue;
      expect(prefs.blocked_recipe_ids).not.toContain(m.recipe_id);
      const r = data.recipesById.get(m.recipe_id)!;
      for (const e of r.equipment) expect(prefs.equipment).toContain(e);
      for (const g of m.grams) expect(banned.has(g.ingredient_id)).toBe(false);
    }
  });

  it('Ít tinh bột: trưa/tối là món low-carb, carb = 0 g', () => {
    const plan = run(manual(1800, 100), { low_carb: true });
    for (const m of mealsOf(plan)) {
      if (m.slot === 'lunch' || m.slot === 'dinner') {
        expect(data.recipesById.get(m.recipe_id!)!.is_low_carb).toBe(true);
        expect(m.grams.find((g) => g.ingredient_id === 'com_trang')!.grams).toBe(0);
      }
    }
  });

  it('không còn công thức hợp lệ cho một bữa → không ném lỗi, trả tuần partial kèm bữa thiếu (F-ENG-05)', () => {
    const plan = run(manual(1800, 100), { exclusions: ['no_egg'] }); // fixture chỉ có 1 món sáng và nó chứa trứng
    expect(plan.status).toBe('partial');
    expect(plan.unfilled_slots).toEqual(['breakfast']);
    // chỉ tiêu dồn sang bữa khác nên các ngày vẫn có thể đạt, nhưng tuần không được coi là ready vì thiếu hẳn một bữa
    expect(plan.days).toHaveLength(7);
    for (const d of plan.days) {
      const bf = d.meals.find((m) => m.slot === 'breakfast')!;
      expect(bf).toMatchObject({ status: 'unfilled', recipe_id: null, grams: [] });
    }
  });

  it('không có công thức nào cho mọi bữa (ví dụ chỉ có lò vi sóng) → partial, thiếu đủ 7 ngày, mức thiếu = cả chỉ tiêu', () => {
    const t = manual(1800, 100);
    const plan = run(t, { equipment: ['lo_vi_song'] });
    expect(plan.status).toBe('partial');
    expect(plan.unfilled_slots.sort()).toEqual(['breakfast', 'dinner', 'lunch']);
    expect(plan.validation.days_missing).toBe(7);
    const p = plan.validation.shortfalls.filter((s) => s.kind === 'protein_low');
    expect(p).toHaveLength(7);
    for (const s of p) expect(s.amount).toBeCloseTo(t.protein_g, 6);
    expect(plan.shopping.items).toEqual([]);
  });

  it('thuần chay + ít tinh bột + protein cao: không ném lỗi, báo số ngày và mức thiếu', () => {
    const t = manual(1800, 190);
    const plan = run(t, { diet: 'vegan', low_carb: true });
    expect(['ready', 'partial']).toContain(plan.status);
    expect(plan.days).toHaveLength(7);
    if (plan.status === 'partial') {
      expect(plan.validation.days_missing + (plan.validation.budget_over_vnd > 0 ? 1 : 0)).toBeGreaterThan(0);
      for (const s of plan.validation.shortfalls) expect(s.amount).toBeGreaterThan(0);
    }
  });

  it('bữa thiếu món: phần chỉ tiêu còn lại dồn cho các bữa khác (cố gắng bù)', () => {
    const t = manual(1800, 100);
    const plan = run(t, { exclusions: ['no_egg'] }); // không có món sáng
    const withBf = run(t, {});
    const kc = (p: WeekPlan) => p.days[0]!.totals.kcal;
    expect(kc(plan)).toBeGreaterThan(kc(withBf) * 0.5);
  });
});

describe('planWeek — bữa tự lo / bỏ bữa', () => {
  it('bữa self không lên món nhưng được tính đủ chỉ tiêu dự kiến', () => {
    const t = manual(1800, 100);
    const plan = run(t, { slots: { ...basePrefs().slots, breakfast: 'self' } });
    for (const d of plan.days) {
      const bf = d.meals.find((m) => m.slot === 'breakfast')!;
      expect(bf).toMatchObject({ status: 'self', recipe_id: null, grams: [] });
      expect(bf.macros.kcal).toBeCloseTo(1800 * (0.2 / 0.9), 6);
      expect(d.meals.filter((m) => m.status === 'planned')).toHaveLength(2);
    }
    expect(plan.status).toBe('ready');
    expect(mealsOf(plan).some((m) => m.slot === 'breakfast' && m.recipe_id)).toBe(false);
  });

  it('bữa phụ xoay vòng 2–3 món', () => {
    const plan = run(manual(1800, 100), { slots: { ...basePrefs().slots, snack_pm: 'on' } });
    const snacks = new Set(mealsOf(plan).filter((m) => m.slot === 'snack_pm').map((m) => m.recipe_id));
    expect(snacks.size).toBeGreaterThanOrEqual(1);
    expect(snacks.size).toBeLessThanOrEqual(3);
    expect(plan.days.every((d) => d.meals.some((m) => m.slot === 'snack_pm'))).toBe(true);
  });
});

describe('planWeek — ~60 công thức', () => {
  // Nhân bản fixture thành 63 công thức (đổi id, thay đổi nhẹ gram) để kiểm hiệu năng và độ đa dạng.
  const big = (() => {
    const recipes = [...data.recipes];
    for (let k = 1; k <= 8; k++)
      for (const r of data.recipes)
        recipes.push({ ...r, id: `${r.id}_v${k}`, ingredients: r.ingredients.map((i) => (i.role === 'protein' ? { ...i, grams: i.grams + k * 5, max_g: i.max_g + k * 5 } : i)) });
    return { ...data, recipes, recipesById: new Map(recipes.map((r) => [r.id, r])) };
  })();

  it('< 2 s, 7/7 đạt và nhiều món khác nhau', () => {
    const t0 = performance.now();
    const plan = planWeek({ targets: manual(1800, 100), prefs: basePrefs({ weekly_budget_vnd: 1_000_000 }), data: big, start_date: '2026-11-07', seed: 9 });
    expect(performance.now() - t0).toBeLessThan(2000);
    expect(big.recipes.length).toBeGreaterThanOrEqual(56);
    expect(plan.status).toBe('ready');
    expect(plan.distinct_recipes).toBeGreaterThanOrEqual(8);
  });

  it('hồ sơ bất khả thi cũng < 2 s (đủ vòng thử lại)', () => {
    const t0 = performance.now();
    const plan = planWeek({ targets: manual(1500, 250), prefs: basePrefs({ weekly_budget_vnd: 1_000_000 }), data: big, start_date: '2026-11-07', seed: 9 });
    expect(performance.now() - t0).toBeLessThan(2000);
    expect(plan.status).toBe('partial');
  });
});

describe('planWeek — hiệu năng', () => {
  it('< 2 s trên fixture (hồ sơ khó, chạy đủ vòng thử lại)', () => {
    const t0 = performance.now();
    run(manual(1500, 250));
    expect(performance.now() - t0).toBeLessThan(2000);
  });
});

describe('planWeek — món phụ bù chỉ tiêu', () => {
  it('khẩu phần công thức không đủ calo/protein → ghép cơm/đạm phụ để đạt 7/7', () => {
    const t = manual(2800, 140);
    const without = planWeek({ targets: t, prefs: basePrefs({ weekly_budget_vnd: 2_000_000 }), data, start_date: '2026-11-09', seed: 1, options: { extras: false, budgetRepair: false } });
    const withEx = planWeek({ targets: t, prefs: basePrefs({ weekly_budget_vnd: 2_000_000 }), data, start_date: '2026-11-09', seed: 1 });
    expect(without.status).toBe('partial');
    expect(withEx.status).toBe('ready');
    const ex = mealsOf(withEx).filter((m) => m.extras.length);
    expect(ex.length).toBeGreaterThan(0);
    for (const m of ex) {
      expect(['breakfast', 'lunch', 'dinner']).toContain(m.slot);
      // macros cả bữa gồm cả món phụ
      const core = computeMacros(m.grams, data.ingredientsById).total;
      const extra = computeMacros(m.extras, data.ingredientsById).total;
      expect(m.macros.kcal).toBeCloseTo(core.kcal + extra.kcal, 6);
      for (const e of m.extras) expect(e.grams % 5).toBe(0);
    }
    // danh sách đi chợ có tính món phụ
    const extraIds = new Set(ex.flatMap((m) => m.extras.map((e) => e.ingredient_id)));
    for (const id of extraIds) expect(withEx.shopping.items.some((i) => i.ingredient_id === id)).toBe(true);
  });

  it('món phụ không bao giờ là nguyên liệu bị cấm; bữa ít tinh bột không có cơm phụ', () => {
    const plan = run(manual(2400, 130), { exclusions: ['no_pork'], low_carb: true });
    const banned = bannedIngredients(data.ingredients, basePrefs({ exclusions: ['no_pork'] }));
    for (const m of mealsOf(plan)) {
      for (const e of m.extras) expect(banned.has(e.ingredient_id)).toBe(false);
      if (m.forced_zero_carb) expect(m.extras.some((e) => e.ingredient_id === 'com_trang')).toBe(false);
    }
  });

  it('hồ sơ chay không có đạm phụ phù hợp → không thêm đạm động vật', () => {
    const plan = run(manual(2000, 130), { diet: 'vegetarian' });
    for (const m of mealsOf(plan)) for (const e of m.extras) expect(['uc_ga_khong_da', 'ca_basa_phi_le', 'thit_nac_heo']).not.toContain(e.ingredient_id);
  });
});

describe('planWeek — sửa ngân sách', () => {
  it('ngân sách chặt: đổi món/nguyên liệu rẻ hơn, chi phí giảm, không làm hỏng ngày đang đạt', () => {
    const t = manual(1800, 100);
    const generous = run(t, { weekly_budget_vnd: 5_000_000 });
    const budget = generous.shopping.week_food_cost - 60_000;
    const mk = (repair: boolean) =>
      planWeek({ targets: t, prefs: basePrefs({ weekly_budget_vnd: budget }), data, start_date: '2026-11-07', seed: 1, options: { budgetRepair: repair } });
    const off = mk(false);
    const on = mk(true);
    expect(on.repairs).toBeGreaterThan(0);
    expect(on.shopping.week_food_cost).toBeLessThan(off.shopping.week_food_cost);
    expect(on.validation.days_missing).toBeLessThanOrEqual(off.validation.days_missing);
    // gram/ngữ nghĩa nhất quán sau khi đổi
    for (const m of mealsOf(on)) {
      if (m.status !== 'planned') continue;
      const re = computeMacros([...m.grams, ...m.extras], data.ingredientsById).total;
      expect(m.macros.kcal).toBeCloseTo(re.kcal, 6);
      expect(m.grams).toHaveLength(m.standard_grams.length);
    }
  });

  it('không có gì để sửa khi đã trong ngân sách', () => {
    const plan = run(manual(1800, 100));
    expect(plan.repairs).toBe(0);
  });

  it('ràng buộc cứng vẫn đúng sau khi sửa ngân sách', () => {
    const prefs = basePrefs({ weekly_budget_vnd: 300_000, exclusions: ['no_pork'] });
    const plan = planWeek({ targets: manual(1800, 100), prefs, data, start_date: '2026-11-07', seed: 2 });
    const banned = bannedIngredients(data.ingredients, prefs);
    for (const m of mealsOf(plan)) for (const g of [...m.grams, ...m.extras]) expect(banned.has(g.ingredient_id)).toBe(false);
  });
});
