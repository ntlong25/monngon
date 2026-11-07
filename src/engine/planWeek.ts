// T-010 — Bộ máy lập tuần (PRD §6.2): lọc → phân slot → chọn món → scale → tinh chỉnh theo ngày → bù bằng món phụ
// → validator → thử lại → sửa ngân sách (đổi món/nguyên liệu rẻ hơn).
// Hàm thuần, tất định theo seed, không I/O, không đọc đồng hồ.
import type { Dataset } from '../data/load.ts';
import type { Preferences, Slot } from '../types/profile.ts';
import type { Ingredient, Recipe } from '../types/schema.ts';
import { bannedIngredients, filterRecipes, recipesForSlot, type ValidRecipe } from './filter.ts';
import { allocateSlots, type SlotTarget } from './mealSlots.ts';
import { computeMacros, macrosOf, ZERO_MACROS, type GramLine, type Macros } from './nutrition.ts';
import { createRng, deriveSeed } from './rng.ts';
import { scaleRecipe, type ScaleResult } from './scale.ts';
import {
  DEFAULT_SCORE_WEIGHTS, mainProteinId, scoreRecipe, type ScoreContext, type ScoreWeights,
} from './score.ts';
import {
  buildShoppingList, otherEatersFactor, recipeServingCostVnd, servingCostVnd, type ShoppingList, type ShoppingMeal,
} from './shopping.ts';
import type { Targets } from './targets.ts';
import { validateWeek, type DayTotals, type WeekValidation } from './validate.ts';

export interface PlanOptions {
  maxIterations: number;
  /** Số món chính (trưa+tối) khác nhau mong muốn; ~10–12 cho 14 bữa (US-2.3). */
  distinctMain: number;
  distinctBreakfast: number;
  distinctSnack: number;
  /** Nhắm protein cao hơn sàn một chút để bù làm tròn 5 g. */
  proteinMargin: number;
  refinePasses: number;
  scoreWeights: ScoreWeights;
  days: number;
  /** Dung sai khi xếp hạng món vào nhóm (chỉ để chọn): bù chênh giữa các bữa là việc của bước tinh chỉnh theo ngày. */
  poolProteinTolG: number;
  poolKcalTolPct: number;
  /** Món phụ (cơm/đạm) ghép vào bữa chính khi cả ngày thiếu calo/protein sau khi scale. */
  extras: boolean;
  extraCarbMaxG: number;
  extraProteinMaxG: number;
  /** Sửa ngân sách bằng đổi món/nguyên liệu rẻ hơn. */
  budgetRepair: boolean;
  repairIterations: number;
  repairMealsPerIter: number;
  repairRecipeAlts: number;
}

export const DEFAULT_PLAN_OPTIONS: PlanOptions = {
  maxIterations: 12, distinctMain: 11, distinctBreakfast: 3, distinctSnack: 3,
  proteinMargin: 1.02, refinePasses: 5, scoreWeights: DEFAULT_SCORE_WEIGHTS, days: 7,
  poolProteinTolG: 8, poolKcalTolPct: 0.12,
  extras: true, extraCarbMaxG: 300, extraProteinMaxG: 150,
  budgetRepair: true, repairIterations: 30, repairMealsPerIter: 10, repairRecipeAlts: 8,
};

export interface PlanWeekInput {
  targets: Targets;
  prefs: Preferences;
  data: Dataset;
  /** Ngày đầu tuần, dạng YYYY-MM-DD (người gọi quyết định "ngày mai"). */
  start_date: string;
  seed: number;
  options?: Partial<PlanOptions>;
}

export interface PlanMeal {
  date: string;
  slot: Slot;
  /** `unfilled`: không còn công thức hợp lệ cho bữa này sau khi lọc (chỉ tiêu của bữa không được đáp ứng). */
  status: 'planned' | 'self' | 'unfilled';
  recipe_id: string | null;
  /** Gram của "bạn" sau scale (rỗng với bữa tự lo). Cùng thứ tự/chỉ số với nguyên liệu của công thức. */
  grams: GramLine[];
  /** Khẩu phần chuẩn gốc của công thức (cho người ăn cùng). */
  standard_grams: GramLine[];
  /** Món phụ ghép thêm (cơm/đạm) để bù chỉ tiêu; đã nằm trong `macros`, KHÔNG nằm trong `grams`. */
  extras: GramLine[];
  /** Nguyên liệu bị đổi sang loại rẻ hơn (cùng swap_group) ở bước sửa ngân sách; `grams[i]` đã dùng nguyên liệu `to`. */
  substitutions: { from: string; to: string }[];
  /** Tổng macro cả bữa = phần công thức + món phụ (chưa làm tròn). */
  macros: Macros;
  batch_group_id: string | null;
  forced_zero_carb: boolean;
  /** Scale không đạt dung sai của bữa (xem scale.ts). */
  scale_infeasible: boolean;
}

export interface PlanDay {
  date: string;
  meals: PlanMeal[];
  totals: { kcal: number; protein_g: number; carb_g: number; fat_g: number };
}

export interface WeekPlan {
  status: 'ready' | 'partial';
  start_date: string;
  seed: number;
  days: PlanDay[];
  validation: WeekValidation;
  shopping: ShoppingList;
  budget_vnd: number;
  iterations: number;
  /** Số công thức khác nhau dùng trong tuần. */
  distinct_recipes: number;
  /** Số lần đổi món/nguyên liệu ở bước sửa ngân sách. */
  repairs: number;
  /** Các bữa không có công thức hợp lệ (thiếu món sau khi lọc); tuần vẫn được trả về với trạng thái partial. */
  unfilled_slots: Slot[];
}

export const addDays = (iso: string, n: number): string => {
  const [y, m, d] = iso.split('-').map(Number) as [number, number, number];
  return new Date(Date.UTC(y, m - 1, d + n)).toISOString().slice(0, 10);
};

type Group = 'main' | 'breakfast' | 'snack_am' | 'snack_pm';
const groupOf = (s: Slot): Group => (s === 'lunch' || s === 'dinner' ? 'main' : s);
const DAY_ORDER: Slot[] = ['breakfast', 'snack_am', 'lunch', 'snack_pm', 'dinner'];
const EXTRA_SLOTS: Slot[] = ['breakfast', 'lunch', 'dinner'];

interface SlotCtx {
  target: SlotTarget;
  cands: ValidRecipe[];
}

const addM = (a: Macros, b: Macros): Macros => ({
  kcal: a.kcal + b.kcal, protein_g: a.protein_g + b.protein_g, carb_g: a.carb_g + b.carb_g,
  fat_g: a.fat_g + b.fat_g, fiber_g: a.fiber_g + b.fiber_g,
});
const subM = (a: Macros, b: Macros): Macros => ({
  kcal: a.kcal - b.kcal, protein_g: a.protein_g - b.protein_g, carb_g: a.carb_g - b.carb_g,
  fat_g: a.fat_g - b.fat_g, fiber_g: a.fiber_g - b.fiber_g,
});
const round5 = (x: number) => Math.round(x / 5) * 5;

export function planWeek(input: PlanWeekInput): WeekPlan {
  const opt: PlanOptions = { ...DEFAULT_PLAN_OPTIONS, ...input.options };
  const { targets, prefs, data } = input;

  const slotTargets = allocateSlots(targets, prefs.slots);
  const filtered = filterRecipes(data.recipes, data.ingredientsById, prefs);
  const banned = bannedIngredients(data.ingredients, prefs);

  // Bữa không còn công thức hợp lệ không làm engine lỗi: ghi nhận `unfilled`, phần chỉ tiêu còn lại dồn cho các bữa khác;
  // validator sẽ báo thiếu trung thực (F-ENG-05).
  const planned: SlotTarget[] = [];
  const unfilled: Slot[] = [];
  const slotCtx = new Map<Slot, SlotCtx>();
  for (const st of slotTargets.filter((s) => s.planned)) {
    const cands = recipesForSlot(filtered.valid, st.slot, prefs.slots, prefs.low_carb);
    if (cands.length === 0) {
      unfilled.push(st.slot);
      continue;
    }
    planned.push(st);
    slotCtx.set(st.slot, { target: st, cands });
  }
  const selfSlots = slotTargets.filter((s) => s.mode === 'self');
  const selfKcal = selfSlots.reduce((a, s) => a + s.kcal, 0);
  const selfProtein = selfSlots.reduce((a, s) => a + s.protein_g, 0);
  const plannedShare = planned.reduce((a, s) => a + s.share, 0) || 1;

  const kMid = (targets.kcal_min + targets.kcal_max) / 2;
  const pGoal = targets.protein_g * opt.proteinMargin;
  // Mục tiêu cho các bữa lên món sao cho cả ngày (cùng bữa tự lo) rơi vào giữa dải và vượt sàn protein.
  const slotGoal = (st: SlotTarget) => ({
    kcal: Math.max(0, kMid - selfKcal) * (st.share / plannedShare),
    protein_g: Math.max(0, pGoal - selfProtein) * (st.share / plannedShare),
  });

  const nMeals = planned.length * opt.days;
  const others = otherEatersFactor({ adults: prefs.adults, children: prefs.children });
  const costRef = prefs.weekly_budget_vnd / Math.max(1, nMeals) / (1 + others);
  const servingCost = new Map<string, number>();
  const costOf = (r: Recipe) => {
    let c = servingCost.get(r.id);
    if (c === undefined) servingCost.set(r.id, (c = recipeServingCostVnd(r, data, prefs.store_id)));
    return c;
  };

  const dates = Array.from({ length: opt.days }, (_, i) => addDays(input.start_date, i));
  const extrasPick = opt.extras ? pickExtras(data, banned, prefs.store_id) : { carb: null, protein: null };

  type Matrix = PlanMeal[][];
  const dayTot = (dm: readonly PlanMeal[]) => dayTotals(dm);
  const dayOk = (t: { kcal: number; protein_g: number }) =>
    t.protein_g >= targets.protein_g && t.kcal >= targets.kcal_min && t.kcal <= targets.kcal_max;

  const toShoppingMeals = (meals: Matrix): ShoppingMeal[] =>
    meals.flat().filter((m) => m.status === 'planned').map((m) => ({
      ingredients: [
        ...m.grams.map((g, i) => ({ ingredient_id: g.ingredient_id, grams: g.grams, standard_grams: m.standard_grams[i]!.grams })),
        ...m.extras.map((e) => ({ ingredient_id: e.ingredient_id, grams: e.grams, standard_grams: 0 })),
      ],
    }));
  const shoppingOf = (meals: Matrix) =>
    buildShoppingList(toShoppingMeals(meals), { adults: prefs.adults, children: prefs.children }, data, { store_id: prefs.store_id });

  const finalize = (meals: Matrix, iterations: number, repairs: number): WeekPlan => {
    assignBatchGroups(meals.flat(), data);
    const days: PlanDay[] = meals.map((dm, i) => ({ date: dates[i]!, meals: dm, totals: dayTot(dm) }));
    const shopping = shoppingOf(meals);
    const validation = validateWeek(
      days.map((d) => ({ date: d.date, protein_g: d.totals.protein_g, kcal: d.totals.kcal }) satisfies DayTotals),
      targets, prefs.weekly_budget_vnd, shopping.week_food_cost,
    );
    const distinct = new Set(meals.flat().map((m) => m.recipe_id).filter(Boolean)).size;
    return {
      status: validation.ok && unfilled.length === 0 ? 'ready' : 'partial', start_date: input.start_date, seed: input.seed, days, validation, shopping,
      budget_vnd: prefs.weekly_budget_vnd, iterations, distinct_recipes: distinct, repairs, unfilled_slots: unfilled,
    };
  };

  let best: { meals: Matrix; plan: WeekPlan; badness: number } | null = null;
  let iterations = 0;

  for (let it = 0; it < opt.maxIterations; it++) {
    iterations = it + 1;
    const rng = createRng(deriveSeed(input.seed, it));
    const weights: ScoreWeights = { ...opt.scoreWeights, cost: opt.scoreWeights.cost * (1 + it * 1.5) };
    const noise = it === 0 ? 0 : 1.5;

    // 1. Chọn nhóm món (pool) cho từng nhóm bữa.
    const pools = new Map<Group, Set<string>>();
    const poolSizes: Record<Group, number> = {
      main: opt.distinctMain, breakfast: opt.distinctBreakfast, snack_am: opt.distinctSnack, snack_pm: opt.distinctSnack,
    };
    for (const g of ['main', 'breakfast', 'snack_am', 'snack_pm'] as Group[]) {
      const slotsOfGroup = planned.filter((s) => groupOf(s.slot) === g);
      if (slotsOfGroup.length === 0) continue;
      const union = new Map<string, { vr: ValidRecipe; slot: SlotTarget }>();
      for (const st of slotsOfGroup)
        for (const vr of slotCtx.get(st.slot)!.cands) if (!union.has(vr.recipe.id)) union.set(vr.recipe.id, { vr, slot: st });
      const scored = [...union.values()].map(({ vr, slot }) => {
        const goal = slotGoal(slot);
        const sc = scaleRecipe(vr.recipe, data.ingredientsById, goal, { forceZeroCarb: vr.forceZeroCarb });
        const base = scoreRecipe(vr.recipe, neutralCtx(prefs, costOf(vr.recipe), costRef), weights).total;
        const fit =
          (sc.infeasible ? -2 : 0) - 0.5 * (Math.abs(sc.deviation.protein_g) / opt.poolProteinTolG) -
          0.5 * (Math.abs(sc.deviation.kcal_pct) / opt.poolKcalTolPct);
        return { id: vr.recipe.id, s: base + fit + noise * rng() };
      });
      scored.sort((a, b) => b.s - a.s || a.id.localeCompare(b.id));
      pools.set(g, new Set(scored.slice(0, poolSizes[g]).map((x) => x.id)));
    }

    // 2. Gán món vào từng bữa theo thứ tự thời gian.
    const uses = new Map<string, number>();
    const recentMain: string[] = [];
    const meals: Matrix = [];
    for (const date of dates) {
      const dayMeals: PlanMeal[] = [];
      const sameDay: string[] = [];
      for (const slot of DAY_ORDER) {
        const sc = slotCtx.get(slot);
        const selfT = selfSlots.find((s) => s.slot === slot);
        if (selfT) {
          dayMeals.push({
            date, slot, status: 'self', recipe_id: null, grams: [], standard_grams: [], extras: [], substitutions: [],
            macros: { ...ZERO_MACROS, kcal: selfT.kcal, protein_g: selfT.protein_g },
            batch_group_id: null, forced_zero_carb: false, scale_infeasible: false,
          });
          continue;
        }
        if (unfilled.includes(slot)) {
          dayMeals.push({
            date, slot, status: 'unfilled', recipe_id: null, grams: [], standard_grams: [], extras: [], substitutions: [],
            macros: ZERO_MACROS, batch_group_id: null, forced_zero_carb: false, scale_infeasible: false,
          });
          continue;
        }
        if (!sc) continue;
        const g = groupOf(slot);
        const pool = pools.get(g)!;
        let eligible = sc.cands.filter((c) => pool.has(c.recipe.id));
        if (eligible.length === 0) eligible = sc.cands;
        if (g === 'main') {
          const fresh = eligible.filter((c) => !sameDay.includes(c.recipe.id));
          if (fresh.length > 0) eligible = fresh;
        }
        let pick: ValidRecipe | null = null;
        let pickScore = -Infinity;
        for (const c of eligible) {
          const s = scoreRecipe(c.recipe, {
            ...neutralCtx(prefs, costOf(c.recipe), costRef),
            uses_this_week: uses.get(c.recipe.id) ?? 0,
            same_day_recipe_ids: sameDay,
            recent_main_proteins: g === 'main' ? recentMain : [],
          }, weights).total;
          if (s > pickScore + 1e-9 || (Math.abs(s - pickScore) <= 1e-9 && pick && c.recipe.id < pick.recipe.id)) {
            pick = c;
            pickScore = s;
          }
        }
        const chosen = pick!;
        uses.set(chosen.recipe.id, (uses.get(chosen.recipe.id) ?? 0) + 1);
        sameDay.push(chosen.recipe.id);
        if (g === 'main') recentMain.push(mainProteinId(chosen.recipe) ?? '');
        dayMeals.push(makeMeal(date, slot, chosen.recipe, chosen.forceZeroCarb, scaleRecipe(chosen.recipe, data.ingredientsById, slotGoal(sc.target), { forceZeroCarb: chosen.forceZeroCarb })));
      }
      meals.push(dayMeals);
    }

    // 3. Tinh chỉnh theo ngày (bù chênh giữa các bữa), rồi ghép món phụ nếu vẫn thiếu.
    for (const dayMeals of meals) {
      refineDay(dayMeals);
      if (opt.extras) addExtras(dayMeals);
      polishDay(dayMeals);
    }

    const plan = finalize(meals, iterations, 0);
    const badness = badnessOf(plan.validation, targets);
    if (!best || badness < best.badness) best = { meals, plan, badness };
    if (plan.status === 'ready') break;
  }

  let result = best!.plan;

  // 4. Sửa ngân sách: đổi món/nguyên liệu rẻ hơn mà vẫn giữ các ngày đang đạt.
  if (opt.budgetRepair && result.validation.budget_over_vnd > 0) {
    const work = structuredClone(best!.meals); // sửa trên bản sao để không làm lệch kết quả đã chốt
    const repairs = repairBudget(work);
    if (repairs > 0) {
      const after = finalize(work, iterations, repairs);
      if (badnessOf(after.validation, targets) <= best!.badness + 1e-9) result = after;
      else result = { ...best!.plan, iterations };
    }
  }
  result.iterations = iterations;
  return result;

  // ---------------------------------------------------------------------------------------------
  function makeMeal(date: string, slot: Slot, recipe: Recipe, forceZeroCarb: boolean, sc: ScaleResult): PlanMeal {
    return {
      date, slot, status: 'planned', recipe_id: recipe.id, grams: sc.grams,
      standard_grams: recipe.ingredients.map((i) => ({ ingredient_id: i.ingredient_id, grams: i.grams })),
      extras: [], substitutions: [], macros: sc.macros, batch_group_id: null, forced_zero_carb: forceZeroCarb,
      scale_infeasible: sc.infeasible,
    };
  }

  function extrasMacros(m: PlanMeal): Macros {
    return m.extras.length ? computeMacros(m.extras, data.ingredientsById).total : ZERO_MACROS;
  }

  function refineDay(dayMeals: PlanMeal[]): void {
    const plannedMeals = dayMeals.filter((m) => m.status === 'planned');
    for (let pass = 0; pass < opt.refinePasses; pass++) {
      const tot = dayTot(dayMeals);
      if (dayOk(tot)) return;
      const rp = pGoal - tot.protein_g;
      const rk = kMid - tot.kcal;
      for (const m of plannedMeals) {
        const sc = slotCtx.get(m.slot)!;
        const w = sc.target.share / plannedShare;
        const recipe = data.recipesById.get(m.recipe_id!)!;
        const res = scaleRecipe(
          recipe, data.ingredientsById,
          { kcal: Math.max(0, m.macros.kcal + rk * w), protein_g: Math.max(0, m.macros.protein_g + rp * w) },
          { forceZeroCarb: m.forced_zero_carb },
        );
        m.grams = res.grams;
        m.macros = res.macros;
        m.scale_infeasible = res.infeasible;
      }
    }
  }

  /** Ghép cơm/đạm phụ vào bữa chính khi cả ngày vẫn thiếu protein hoặc calo (vượt biên của công thức). */
  function addExtras(dayMeals: PlanMeal[]): void {
    const eligible = dayMeals.filter((m) => m.status === 'planned' && EXTRA_SLOTS.includes(m.slot));
    if (eligible.length === 0) return;
    const per = (id: string) => data.ingredientsById.get(id)!.per_100g;
    const put = (m: PlanMeal, id: string, g: number) => {
      if (g < 5) return;
      const cur = m.extras.find((e) => e.ingredient_id === id);
      if (cur) cur.grams += g;
      else m.extras.push({ ingredient_id: id, grams: g });
      m.macros = addM(m.macros, computeMacros([{ ingredient_id: id, grams: g }], data.ingredientsById).total);
    };
    const extraG = (m: PlanMeal, id: string) => m.extras.find((e) => e.ingredient_id === id)?.grams ?? 0;
    const bySlotShare = [...eligible].sort((a, b) => slotCtx.get(b.slot)!.target.share - slotCtx.get(a.slot)!.target.share);

    // Protein trước (thêm cả calo).
    if (extrasPick.protein) {
      const pid = extrasPick.protein;
      const p = per(pid);
      let need = pGoal - dayTot(dayMeals).protein_g;
      for (const m of bySlotShare) {
        if (need <= 0.5) break;
        const kroom = targets.kcal_max - dayTot(dayMeals).kcal;
        const gByKcal = Math.floor(Math.max(0, kroom) / (p.kcal / 100) / 5) * 5;
        const g = Math.min(opt.extraProteinMaxG - extraG(m, pid), Math.ceil(need / (p.protein_g / 100) / 5) * 5, gByKcal);
        put(m, pid, g);
        need = pGoal - dayTot(dayMeals).protein_g;
      }
    }
    // Calo: cơm/tinh bột; nếu bữa bị ép ít tinh bột hoặc không có tinh bột phụ thì dùng đạm phụ.
    let kneed = kMid - dayTot(dayMeals).kcal;
    if (kneed > 0 && dayTot(dayMeals).kcal < targets.kcal_min) {
      const carbId = extrasPick.carb;
      if (carbId) {
        const c = per(carbId);
        const slotsOk = bySlotShare.filter((m) => !m.forced_zero_carb);
        for (const m of slotsOk) {
          if (kneed <= 5) break;
          const share = slotsOk.length ? 1 / slotsOk.length : 1;
          const g = Math.min(opt.extraCarbMaxG - extraG(m, carbId), Math.max(0, round5((kneed * Math.max(share, 0.5)) / (c.kcal / 100))));
          put(m, carbId, g);
          kneed = kMid - dayTot(dayMeals).kcal;
        }
      }
      kneed = kMid - dayTot(dayMeals).kcal;
      if (kneed > 20 && extrasPick.protein) {
        const pid = extrasPick.protein;
        const p = per(pid);
        for (const m of bySlotShare) {
          if (kneed <= 5) break;
          const g = Math.min(opt.extraProteinMaxG - extraG(m, pid), round5(kneed / (p.kcal / 100)));
          put(m, pid, g);
          kneed = kMid - dayTot(dayMeals).kcal;
        }
      }
    }
  }

  /**
   * Chỉnh tinh từng bước 5 g (nguyên liệu protein/carb trong biên của công thức, và món phụ) để đưa ngày vào vùng đạt.
   * Chỉ nhận bước làm giảm độ vi phạm (protein dưới sàn ×4 kcal + kcal ngoài dải).
   */
  function polishDay(dayMeals: PlanMeal[]): void {
    const viol = (protein: number, kcal: number) =>
      Math.max(0, targets.protein_g - protein) * 4 + Math.max(0, targets.kcal_min - kcal) + Math.max(0, kcal - targets.kcal_max);
    const mealsP = dayMeals.filter((m) => m.status === 'planned');
    const extraIds = [extrasPick.carb, extrasPick.protein].filter((x): x is string => !!x);
    for (let step = 0; step < 80; step++) {
      const tot = dayTot(dayMeals);
      const v0 = viol(tot.protein_g, tot.kcal);
      if (v0 <= 1e-9) return;
      let bestMove: { v: number; apply: () => void } | null = null;
      const consider = (ingId: string, d: number, apply: () => void) => {
        const dm = macrosOf(data.ingredientsById.get(ingId)!, d);
        const v = viol(tot.protein_g + dm.protein_g, tot.kcal + dm.kcal);
        if (v < v0 - 1e-9 && (!bestMove || v < bestMove.v)) bestMove = { v, apply: () => { apply(); } };
      };
      for (const m of mealsP) {
        const recipe = data.recipesById.get(m.recipe_id!)!;
        recipe.ingredients.forEach((li, i) => {
          if ((li.role !== 'protein' && li.role !== 'carb') || li.min_g >= li.max_g) return;
          if (li.role === 'carb' && m.forced_zero_carb) return;
          const gl = m.grams[i]!;
          for (const d of [5, -5]) {
            const g = gl.grams + d;
            if (g < li.min_g || g > li.max_g) continue;
            consider(gl.ingredient_id, d, () => {
              gl.grams = g;
              m.macros = addM(m.macros, macrosOf(data.ingredientsById.get(gl.ingredient_id)!, d));
            });
          }
        });
        if (opt.extras && EXTRA_SLOTS.includes(m.slot)) {
          for (const id of extraIds) {
            if (id === extrasPick.carb && m.forced_zero_carb) continue;
            const cap = id === extrasPick.carb ? opt.extraCarbMaxG : opt.extraProteinMaxG;
            const cur = m.extras.find((e) => e.ingredient_id === id);
            for (const d of [5, -5]) {
              const g = (cur?.grams ?? 0) + d;
              if (g < 0 || g > cap) continue;
              consider(id, d, () => {
                const e = m.extras.find((x) => x.ingredient_id === id);
                if (e) e.grams = g;
                else m.extras.push({ ingredient_id: id, grams: g });
                m.extras = m.extras.filter((x) => x.grams > 0);
                m.macros = addM(m.macros, macrosOf(data.ingredientsById.get(id)!, d));
              });
            }
          }
        }
      }
      if (!bestMove) return;
      (bestMove as { apply: () => void }).apply();
    }
  }

  /** Đổi món/nguyên liệu rẻ hơn tới khi hết vượt ngân sách. Trả số lần đổi. */
  function repairBudget(meals: Matrix): number {
    const budget = prefs.weekly_budget_vnd;
    const used = (mm: Matrix) => shoppingOf(mm).items.reduce((s, i) => s + i.used_cost_vnd, 0);
    let cost = used(meals);
    if (cost <= budget) return 0;
    const mealCost = (grams: GramLine[], std: GramLine[]) =>
      servingCostVnd(grams, data, prefs.store_id) + others * servingCostVnd(std, data, prefs.store_id);
    const swapPool = buildSwapPool(data, banned);
    const tabu = new Set<string>();
    let applied = 0;

    for (let iter = 0; iter < opt.repairIterations; iter++) {
      if (shoppingOf(meals).week_food_cost <= budget) break;
      type Cand = { day: number; idx: number; saving: number; meal: PlanMeal; variantRecipe: Recipe; res: ScaleResult; subs: PlanMeal['substitutions']; key: string };
      let bestC: Cand | null = null;

      const ranked = meals
        .flatMap((dm, day) => dm.map((m, idx) => ({ m, day, idx })))
        .filter((x) => x.m.status === 'planned')
        .map((x) => ({ ...x, c: mealCost(x.m.grams, x.m.standard_grams) }))
        .sort((a, b) => b.c - a.c)
        .slice(0, opt.repairMealsPerIter);

      for (const { m, day, idx, c: curCost } of ranked) {
        const sc = slotCtx.get(m.slot)!;
        const base = data.recipesById.get(m.recipe_id!)!;
        const exM = extrasMacros(m);
        const core = subM(m.macros, exM); // phần do công thức đóng góp
        const target = { kcal: core.kcal, protein_g: core.protein_g };
        const dayTotNow = dayTot(meals[day]!);
        const wasOk = dayOk(dayTotNow);
        const sameDay = new Set(meals[day]!.filter((x) => x !== m && x.recipe_id).map((x) => x.recipe_id!));

        // a) đổi sang công thức rẻ hơn cùng bữa
        const recipeAlts = sc.cands
          .filter((cd) => cd.recipe.id !== m.recipe_id && !(groupOf(m.slot) === 'main' && sameDay.has(cd.recipe.id)))
          .sort((a, b) => costOf(a.recipe) - costOf(b.recipe))
          .slice(0, opt.repairRecipeAlts)
          .map((cd) => ({ recipe: cd.recipe, zero: cd.forceZeroCarb, subs: [] as PlanMeal['substitutions'], key: cd.recipe.id }));

        // b) đổi nguyên liệu (protein/carb) trong cùng swap_group sang loại rẻ hơn
        const subAlts: typeof recipeAlts = [];
        base.ingredients.forEach((li, i) => {
          if (!li.swap_group || (li.role !== 'protein' && li.role !== 'carb')) return;
          const curIng = m.grams[i]!.ingredient_id;
          for (const id of swapPool.get(`${li.swap_group}|${li.role}`) ?? []) {
            if (id === curIng) continue;
            const v: Recipe = { ...base, ingredients: base.ingredients.map((x, j) => (j === i ? { ...x, ingredient_id: id } : { ...x, ingredient_id: m.grams[j]!.ingredient_id })) };
            subAlts.push({ recipe: v, zero: m.forced_zero_carb, subs: [...m.substitutions.filter((s) => s.to !== curIng), { from: li.ingredient_id, to: id }], key: `${base.id}~${i}:${id}` });
          }
        });

        for (const alt of [...recipeAlts, ...subAlts]) {
          const key = `${day}|${m.slot}|${alt.key}`;
          if (tabu.has(key)) continue;
          const res = scaleRecipe(alt.recipe, data.ingredientsById, target, { forceZeroCarb: alt.zero });
          const stdAlt = alt.recipe.ingredients.map((i) => ({ ingredient_id: i.ingredient_id, grams: i.grams }));
          const saving = curCost - mealCost(res.grams, stdAlt);
          if (saving <= 1 || (bestC && saving <= bestC.saving)) continue;
          const newTot = addM(subM(dayTotNow as unknown as Macros, core), res.macros);
          if (wasOk && !dayOk(newTot)) continue;
          if (!wasOk && (newTot.protein_g < dayTotNow.protein_g - 1e-6 || Math.abs(newTot.kcal - kMid) > Math.abs(dayTotNow.kcal - kMid) + 1e-6)) continue;
          bestC = { day, idx, saving, meal: m, variantRecipe: alt.recipe, res, subs: alt.subs, key };
        }
      }
      if (!bestC) break;

      const { meal: m, variantRecipe, res } = bestC;
      const backup = { ...m };
      const isRecipeSwap = !bestC.key.includes('~');
      const exM = extrasMacros(m);
      m.recipe_id = isRecipeSwap ? variantRecipe.id : m.recipe_id;
      m.grams = res.grams;
      m.standard_grams = variantRecipe.ingredients.map((i) => ({ ingredient_id: i.ingredient_id, grams: i.grams }));
      m.substitutions = isRecipeSwap ? [] : bestC.subs;
      m.macros = addM(res.macros, exM);
      m.scale_infeasible = res.infeasible;
      if (isRecipeSwap) m.forced_zero_carb = sc0(m.slot, variantRecipe.id);
      const newCost = used(meals);
      if (newCost < cost - 1e-6) {
        cost = newCost;
        applied++;
      } else {
        Object.assign(m, backup);
        tabu.add(`${bestC.day}|${m.slot}|${bestC.key}`);
      }
    }
    return applied;

    function sc0(slot: Slot, recipeId: string): boolean {
      return slotCtx.get(slot)!.cands.find((c) => c.recipe.id === recipeId)?.forceZeroCarb ?? false;
    }
  }
}

function neutralCtx(prefs: Preferences, cost: number, costRef: number): ScoreContext {
  return {
    cuisine_likes: prefs.cuisine_likes, cuisine_less: prefs.cuisine_less, health_leanings: prefs.health_leanings,
    cost_vnd: cost, cost_reference_vnd: costRef, uses_this_week: 0, same_day_recipe_ids: [], recent_main_proteins: [],
  };
}

function dayTotals(dayMeals: readonly PlanMeal[]): PlanDay['totals'] {
  const t = { kcal: 0, protein_g: 0, carb_g: 0, fat_g: 0 };
  for (const m of dayMeals) {
    t.kcal += m.macros.kcal;
    t.protein_g += m.macros.protein_g;
    t.carb_g += m.macros.carb_g;
    t.fat_g += m.macros.fat_g;
  }
  return t;
}

/** Chọn nguyên liệu phụ: tinh bột rẻ nhất theo kcal và đạm gọn/rẻ nhất theo gram protein (không bị cấm). */
function pickExtras(
  data: Dataset, banned: ReadonlyMap<string, unknown>, storeId: string,
): { carb: string | null; protein: string | null } {
  const price = (i: Ingredient) => {
    const m = data.pricesByIngredient.get(i.id);
    const p = m?.get(storeId) ?? m?.get('cho_khac');
    return p ? p.price_vnd / p.pack_g : Infinity; // ₫/g
  };
  let carb: { id: string; v: number } | null = null;
  let protein: { id: string; v: number } | null = null;
  for (const i of data.ingredients) {
    if (banned.has(i.id)) continue;
    const m = i.per_100g;
    const unit = price(i);
    if (!Number.isFinite(unit)) continue;
    if (i.aisle === 'gao_do_kho' && m.carb_g >= 20 && m.protein_g <= 10 && m.fat_g <= 5 && m.kcal >= 100) {
      const v = unit / m.kcal; // ₫ mỗi kcal
      if (!carb || v < carb.v) carb = { id: i.id, v };
    }
    if ((i.aisle === 'thit' || i.aisle === 'ca_hai_san') && m.protein_g >= 15 && m.protein_g / Math.max(1, m.kcal) >= 0.12) {
      const v = unit / m.protein_g;
      if (!protein || v < protein.v) protein = { id: i.id, v };
    }
  }
  return { carb: carb?.id ?? null, protein: protein?.id ?? null };
}

/** `${swap_group}|${role}` → nguyên liệu có thể thay (không bị cấm), lấy từ chính các công thức. */
function buildSwapPool(data: Dataset, banned: ReadonlyMap<string, unknown>): Map<string, string[]> {
  const pool = new Map<string, Set<string>>();
  for (const r of data.recipes)
    for (const li of r.ingredients) {
      if (!li.swap_group || banned.has(li.ingredient_id)) continue;
      const key = `${li.swap_group}|${li.role}`;
      (pool.get(key) ?? pool.set(key, new Set()).get(key)!).add(li.ingredient_id);
    }
  return new Map([...pool].map(([k, v]) => [k, [...v].sort()]));
}

/** Món `batchable` dùng nhiều lần: ghép từng 2 bữa liên tiếp thành "nấu 1 lần ăn 2 bữa". */
function assignBatchGroups(allMeals: PlanMeal[], data: Dataset): void {
  const byRecipe = new Map<string, PlanMeal[]>();
  for (const m of allMeals) {
    if (m.status !== 'planned') continue;
    (byRecipe.get(m.recipe_id!) ?? byRecipe.set(m.recipe_id!, []).get(m.recipe_id!)!).push(m);
  }
  for (const [rid, list] of byRecipe) {
    const batchable = data.recipesById.get(rid)!.batchable;
    list.forEach((m, i) => {
      m.batch_group_id = batchable ? `${rid}#${Math.floor(i / 2)}` : `${rid}#${m.date}-${m.slot}`;
    });
  }
}

function badnessOf(v: WeekValidation, t: Targets): number {
  let s = v.days_missing * 1000 + (v.budget_over_vnd > 0 ? 100 + v.budget_over_vnd / 1000 : 0);
  for (const f of v.shortfalls) s += f.kind === 'protein_low' ? f.amount / Math.max(1, t.protein_g) : f.amount / Math.max(1, t.kcal_target);
  return s;
}
