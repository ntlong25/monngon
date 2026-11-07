// T-011 — Chạy planWeek trên dữ liệu thật, đo tỉ lệ đạt và chẩn đoán nguyên nhân khi thấp. Hàm thuần (không I/O).
import type { Dataset } from '../data/load.ts';
import { bannedIngredients, filterRecipes, recipesForSlot } from '../engine/filter.ts';
import { allocateSlots } from '../engine/mealSlots.ts';
import { planWeek, type PlanOptions, type WeekPlan } from '../engine/planWeek.ts';
import { scaleRecipe } from '../engine/scale.ts';
import { otherEatersFactor, recipeServingCostVnd } from '../engine/shopping.ts';
import { computeTargets, type Targets } from '../engine/targets.ts';
import type { ReportProfile } from '../data/testProfiles.ts';

export interface ProfileResult {
  name: string;
  note: string;
  targets: Targets;
  status: 'ready' | 'partial' | 'error';
  error?: string;
  days_ok: number;
  protein_days_ok: number;
  kcal_days_ok: number;
  distinct_recipes: number;
  distinct_main: number;
  week_food_cost: number;
  till_cost: number;
  budget: number;
  ms: number;
  iterations: number;
  hard_violations: string[];
  diagnosis: string[];
  expect_all_days_pass: boolean;
}

const fmt = (n: number) => Math.round(n).toLocaleString('vi-VN');

export function checkHardConstraints(plan: WeekPlan, rp: ReportProfile, ds: Dataset): string[] {
  const out: string[] = [];
  const banned = bannedIngredients(ds.ingredients, rp.prefs);
  for (const day of plan.days) {
    const mains = day.meals.filter((m) => (m.slot === 'lunch' || m.slot === 'dinner') && m.recipe_id).map((m) => m.recipe_id);
    if (mains.length === 2 && mains[0] === mains[1]) out.push(`${day.date}: trưa và tối cùng món ${mains[0]}`);
    for (const m of day.meals) {
      if (!m.recipe_id) continue;
      const r = ds.recipesById.get(m.recipe_id)!;
      if (rp.prefs.blocked_recipe_ids.includes(r.id)) out.push(`món bị chặn: ${r.id}`);
      for (const e of r.equipment) if (!rp.prefs.equipment.includes(e)) out.push(`${r.id} cần dụng cụ ${e}`);
      for (const g of m.grams) if (g.grams > 0 && banned.has(g.ingredient_id)) out.push(`${r.id} chứa nguyên liệu bị cấm ${g.ingredient_id}`);
      for (const g of m.grams) if (g.grams > 0 && rp.forbidden_ingredient_ids.includes(g.ingredient_id)) out.push(`${r.id} chứa nguyên liệu cấm của hồ sơ ${g.ingredient_id}`);
      if (rp.prefs.low_carb && (m.slot === 'lunch' || m.slot === 'dinner')) {
        if (!r.is_low_carb) out.push(`${r.id} không phải low-carb nhưng được xếp ${m.slot}`);
        for (const [i, li] of r.ingredients.entries()) if (li.role === 'carb' && m.grams[i]!.grams !== 0) out.push(`${r.id}: carb ≠ 0 g`);
      }
    }
  }
  return [...new Set(out)];
}

/** Giải thích vì sao hồ sơ không đạt: thiếu món, mật độ protein, ngân sách, giá. */
export function diagnose(rp: ReportProfile, ds: Dataset, targets: Targets, plan: WeekPlan | null, error?: unknown): string[] {
  const lines: string[] = [];
  const filt = filterRecipes(ds.recipes, ds.ingredientsById, rp.prefs);

  // Nguyên nhân loại món: gom theo nguyên liệu / lý do.
  const cause = new Map<string, number>();
  for (const why of filt.excluded.values())
    for (const w of why) {
      const key = w.startsWith('ingredient:') ? w.replace(/^ingredient:([a-z0-9_]+)\(.*\)$/, 'nguyên liệu $1') : w.split(':')[0]!;
      cause.set(key, (cause.get(key) ?? 0) + 1);
    }
  if (filt.excluded.size > 0)
    lines.push(`Lọc cứng loại ${filt.excluded.size}/${ds.recipes.length} món; nhiều nhất do: ` +
      [...cause].sort((a, b) => b[1] - a[1]).slice(0, 4).map(([k, n]) => `${k} (${n})`).join(', '));

  if (plan && plan.unfilled_slots.length > 0)
    lines.push(`KHÔNG CÓ MÓN cho bữa ${plan.unfilled_slots.map((x) => `"${x}"`).join(', ')} sau khi lọc → cần thêm công thức phù hợp nhóm ràng buộc này (tuần vẫn được trả về, các ngày báo thiếu).`);
  void error;

  let slots;
  try {
    slots = allocateSlots(targets, rp.prefs.slots);
  } catch (e) {
    lines.push(`Cấu hình bữa lỗi: ${(e as Error).message}`);
    return lines;
  }
  const kMid = (targets.kcal_min + targets.kcal_max) / 2;
  const self = slots.filter((s) => s.mode === 'self');
  const selfK = self.reduce((a, s) => a + s.kcal, 0);
  const selfP = self.reduce((a, s) => a + s.protein_g, 0);
  const planned = slots.filter((s) => s.planned);
  const share = planned.reduce((a, s) => a + s.share, 0);

  let minWeekCost = 0;
  const household = 1 + otherEatersFactor({ adults: rp.prefs.adults, children: rp.prefs.children });
  for (const st of planned) {
    const cands = recipesForSlot(filt.valid, st.slot, rp.prefs.slots, rp.prefs.low_carb);
    const goalK = Math.max(0, kMid - selfK) * (st.share / share);
    const goalP = Math.max(0, targets.protein_g * 1.02 - selfP) * (st.share / share);
    if (cands.length < 6) lines.push(`Bữa ${st.slot}: chỉ còn ${cands.length} món hợp lệ (nên ≥ 6 để có đa dạng).`);
    let bestP = { p: -1, id: '', kcal: 0 };
    let maxK = { k: -1, id: '' };
    let minK = { k: Infinity, id: '' };
    let nearest = { dev: Infinity, id: '' };
    let cheapest = Infinity;
    let fitCount = 0;
    for (const c of cands) {
      const unlimited = scaleRecipe(c.recipe, ds.ingredientsById, { kcal: goalK, protein_g: 9999 }, { forceZeroCarb: c.forceZeroCarb });
      if (unlimited.macros.protein_g > bestP.p) bestP = { p: unlimited.macros.protein_g, id: c.recipe.id, kcal: unlimited.macros.kcal };
      const hiK = scaleRecipe(c.recipe, ds.ingredientsById, { kcal: 99999, protein_g: 99999 }, { forceZeroCarb: c.forceZeroCarb });
      if (hiK.macros.kcal > maxK.k) maxK = { k: hiK.macros.kcal, id: c.recipe.id };
      const loK = scaleRecipe(c.recipe, ds.ingredientsById, { kcal: 0, protein_g: 0 }, { forceZeroCarb: c.forceZeroCarb });
      if (loK.macros.kcal < minK.k) minK = { k: loK.macros.kcal, id: c.recipe.id };
      const fit = scaleRecipe(c.recipe, ds.ingredientsById, { kcal: goalK, protein_g: goalP }, { forceZeroCarb: c.forceZeroCarb });
      const dev = Math.abs(fit.deviation.protein_g) / 3 + Math.abs(fit.deviation.kcal_pct) / 0.05;
      if (dev < nearest.dev) nearest = { dev, id: c.recipe.id };
      if (!fit.infeasible) fitCount++;
      cheapest = Math.min(cheapest, recipeServingCostVnd(c.recipe, ds, rp.prefs.store_id));
    }
    if (cands.length > 0) {
      if (fitCount < Math.min(4, cands.length))
        lines.push(`Bữa ${st.slot}: chỉ ${fitCount}/${cands.length} món scale khớp được mục tiêu bữa (~${goalK.toFixed(0)} kcal, ≥ ${goalP.toFixed(0)} g protein; dung sai protein 3 g, kcal 5%); gần nhất: ${nearest.id}.`);
      const protKcalNeeded = goalP / Math.max(1, goalK);
      if (bestP.p < goalP)
        lines.push(`Bữa ${st.slot}: cần ≥ ${goalP.toFixed(0)} g protein trong ~${goalK.toFixed(0)} kcal (${(protKcalNeeded * 400).toFixed(0)}% calo từ protein), ` +
          `món mạnh nhất (${bestP.id}) chỉ đạt ${bestP.p.toFixed(0)} g khi scale tối đa → THIẾU MÓN GIÀU ĐẠM cho bữa này.`);
      if (maxK.k < goalK * 0.95)
        lines.push(`Bữa ${st.slot}: cần ~${goalK.toFixed(0)} kcal nhưng món nhiều calo nhất (${maxK.id}) chỉ đạt ${maxK.k.toFixed(0)} kcal khi scale tối đa → biên max_g của protein/carb quá chặt hoặc thiếu món calo cao.`);
      if (minK.k > goalK * 1.05)
        lines.push(`Bữa ${st.slot}: cần ~${goalK.toFixed(0)} kcal nhưng món nhẹ nhất (${minK.id}) vẫn ${minK.k.toFixed(0)} kcal khi scale tối thiểu → thiếu món nhẹ.`);
      minWeekCost += cheapest * planDays(plan) * household;
    }
  }
  if (minWeekCost > rp.prefs.weekly_budget_vnd)
    lines.push(`Ngân sách ${fmt(rp.prefs.weekly_budget_vnd)} ₫ thấp hơn mức tối thiểu ước tính ~${fmt(minWeekCost)} ₫ nếu chọn món rẻ nhất mọi bữa (giá/khẩu phần chuẩn).`);

  if (plan) {
    const v = plan.validation;
    const kinds = new Map<string, number>();
    for (const s of v.shortfalls) kinds.set(s.kind, (kinds.get(s.kind) ?? 0) + 1);
    if (kinds.size) lines.push('Ngày không đạt theo loại: ' + [...kinds].map(([k, n]) => `${k}×${n}`).join(', '));
    const worst = [...v.shortfalls].sort((a, b) => b.amount - a.amount)[0];
    if (worst) lines.push(`Thiếu nặng nhất: ${worst.date} ${worst.kind} ${worst.amount.toFixed(0)}${worst.kind === 'protein_low' ? ' g' : ' kcal'}.`);
    if (v.budget_over_vnd > 0) {
      const top = [...plan.shopping.items].sort((a, b) => b.used_cost_vnd - a.used_cost_vnd).slice(0, 5);
      lines.push(`Vượt ngân sách ${fmt(v.budget_over_vnd)} ₫. Nguyên liệu tốn nhất: ` +
        top.map((i) => `${i.ingredient_id} ${fmt(i.used_cost_vnd)} ₫ (~${fmt((i.price_vnd_per_pack / i.pack_g) * 1000)} ₫/kg, ${i.price_fallback ? 'giá cho_khac' : 'giá ' + i.price_store_id})`).join('; '));
    }
  }
  return lines;
}

const planDays = (plan: WeekPlan | null) => plan?.days.length ?? 7;

export function runProfile(
  rp: ReportProfile, ds: Dataset, seed: number, startDate: string, options?: Partial<PlanOptions>,
): ProfileResult {
  const targets = computeTargets(rp.profile);
  const base = { name: rp.name, note: rp.note, targets, budget: rp.prefs.weekly_budget_vnd, expect_all_days_pass: rp.expect_all_days_pass };
  const t0 = performance.now();
  try {
    const plan = planWeek({ targets, prefs: rp.prefs, data: ds, start_date: startDate, seed, options });
    const ms = performance.now() - t0;
    const days = plan.validation.days;
    const mainIds = new Set(plan.days.flatMap((d) => d.meals).filter((m) => (m.slot === 'lunch' || m.slot === 'dinner') && m.recipe_id).map((m) => m.recipe_id!));
    const res: ProfileResult = {
      ...base, status: plan.status, days_ok: days.filter((d) => d.ok).length,
      protein_days_ok: days.filter((d) => d.protein_short_g <= 1e-6).length,
      kcal_days_ok: days.filter((d) => d.kcal_delta === 0).length,
      distinct_recipes: plan.distinct_recipes, distinct_main: mainIds.size,
      week_food_cost: plan.shopping.week_food_cost, till_cost: plan.shopping.till_cost, ms, iterations: plan.iterations,
      hard_violations: checkHardConstraints(plan, rp, ds), diagnosis: [],
    };
    if (plan.status !== 'ready') res.diagnosis = diagnose(rp, ds, targets, plan);
    return res;
  } catch (e) {
    return {
      ...base, status: 'error', error: (e as Error).message, days_ok: 0, protein_days_ok: 0, kcal_days_ok: 0, distinct_recipes: 0, distinct_main: 0,
      week_food_cost: 0, till_cost: 0, ms: performance.now() - t0, iterations: 0, hard_violations: [], diagnosis: diagnose(rp, ds, targets, null, e),
    };
  }
}

export interface ReportSummary {
  profiles: number;
  ready: number;
  partial: number;
  errors: number;
  days_total: number;
  days_ok: number;
  protein_days_ok: number;
  kcal_days_ok: number;
  expected_pass: number;
  expected_pass_ready: number;
  hard_violations: number;
  avg_ms: number;
  max_ms: number;
}

export function summarize(rs: readonly ProfileResult[]): ReportSummary {
  const exp = rs.filter((r) => r.expect_all_days_pass);
  return {
    profiles: rs.length,
    ready: rs.filter((r) => r.status === 'ready').length,
    partial: rs.filter((r) => r.status === 'partial').length,
    errors: rs.filter((r) => r.status === 'error').length,
    days_total: rs.filter((r) => r.status !== 'error').length * 7,
    days_ok: rs.reduce((a, r) => a + r.days_ok, 0),
    protein_days_ok: rs.reduce((a, r) => a + r.protein_days_ok, 0),
    kcal_days_ok: rs.reduce((a, r) => a + r.kcal_days_ok, 0),
    expected_pass: exp.length,
    expected_pass_ready: exp.filter((r) => r.status === 'ready').length,
    hard_violations: rs.reduce((a, r) => a + r.hard_violations.length, 0),
    avg_ms: rs.reduce((a, r) => a + r.ms, 0) / Math.max(1, rs.length),
    max_ms: Math.max(0, ...rs.map((r) => r.ms)),
  };
}

export function formatReport(rs: readonly ProfileResult[]): string {
  const L: string[] = [];
  L.push('BÁO CÁO ENGINE (T-011)', '');
  for (const r of rs) {
    const flag = r.status === 'ready' ? 'ĐẠT ' : r.status === 'partial' ? 'PARTIAL' : 'LỖI';
    L.push(`[${flag}] ${r.name} — ${r.note}`);
    L.push(`   chỉ tiêu: ${r.targets.kcal_min}–${r.targets.kcal_max} kcal, protein ≥ ${r.targets.protein_g} g`);
    if (r.status === 'error') L.push(`   lỗi: ${r.error}`);
    else {
      L.push(`   ngày đạt ${r.days_ok}/7 (protein ${r.protein_days_ok}/7, kcal ${r.kcal_days_ok}/7) · món khác nhau ${r.distinct_recipes} (trưa/tối ${r.distinct_main}) · ${r.ms.toFixed(0)} ms · ${r.iterations} vòng`);
      L.push(`   chi phí món ăn ${fmt(r.week_food_cost)} ₫ / ngân sách ${fmt(r.budget)} ₫ ${r.week_food_cost <= r.budget ? '✓' : '✗ VƯỢT'} · trả tại quầy ~${fmt(r.till_cost)} ₫`);
    }
    if (r.hard_violations.length) L.push(`   !!! VI PHẠM RÀNG BUỘC CỨNG: ${r.hard_violations.join(' | ')}`);
    for (const d of r.diagnosis) L.push(`   · ${d}`);
    L.push('');
  }
  const s = summarize(rs);
  const pct = (a: number, b: number) => (b ? ((a / b) * 100).toFixed(0) : '0') + '%';
  L.push('TỔNG HỢP');
  L.push(`  Hồ sơ đạt 7/7: ${s.ready}/${s.profiles} · partial ${s.partial} · lỗi ${s.errors}`);
  L.push(`  Hồ sơ kỳ vọng đạt: ${s.expected_pass_ready}/${s.expected_pass} (${pct(s.expected_pass_ready, s.expected_pass)})`);
  L.push(`  Ngày đạt: ${s.days_ok}/${s.days_total} (${pct(s.days_ok, s.days_total)}) · sàn protein ${pct(s.protein_days_ok, s.days_total)} · dải calo ${pct(s.kcal_days_ok, s.days_total)}`);
  L.push(`  Vi phạm ràng buộc cứng: ${s.hard_violations} · thời gian TB ${s.avg_ms.toFixed(0)} ms, tối đa ${s.max_ms.toFixed(0)} ms`);
  return L.join('\n');
}

const SCENARIOS: { name: string; over: Record<string, unknown> }[] = [
  { name: 'không ràng buộc', over: {} },
  { name: 'chay', over: { diet: 'vegetarian' } },
  { name: 'thuần chay', over: { diet: 'vegan' } },
  { name: 'chay có cá', over: { diet: 'pescatarian' } },
  { name: 'không lợn', over: { exclusions: ['no_pork'] } },
  { name: 'không thịt đỏ', over: { exclusions: ['no_red_meat'] } },
  { name: 'không trứng', over: { exclusions: ['no_egg'] } },
  { name: 'không sữa', over: { exclusions: ['no_dairy'] } },
  { name: 'không gluten', over: { exclusions: ['no_gluten'] } },
  { name: 'không đậu nành', over: { exclusions: ['no_soy'] } },
  { name: 'không cá', over: { exclusions: ['no_fish'] } },
  { name: 'không hải sản có vỏ', over: { exclusions: ['no_shellfish'] } },
  { name: 'không lạc', over: { exclusions: ['no_peanut'] } },
  { name: 'ít tinh bột (trưa/tối)', over: { low_carb: true } },
  { name: 'chỉ có bếp', over: { equipment: ['bep'] } },
];

/** Số công thức dùng được cho từng bữa theo từng nhóm ràng buộc — chỉ ra chỗ thiếu món cho RESEARCH. */
export function coverageMatrix(ds: Dataset, basePrefs: ReportProfile['prefs']): string {
  const slots = ['breakfast', 'lunch', 'dinner', 'snack_am', 'snack_pm'] as const;
  const rows = ['MA TRẬN PHỦ MÓN (số công thức dùng được / bữa; ⚠ = dưới 6)', '  ' + 'nhóm ràng buộc'.padEnd(26) + slots.map((s) => s.padStart(10)).join('')];
  for (const sc of SCENARIOS) {
    const prefs = { ...basePrefs, ...sc.over } as ReportProfile['prefs'];
    const f = filterRecipes(ds.recipes, ds.ingredientsById, prefs);
    const cells = slots.map((slot) => {
      const n = recipesForSlot(f.valid, slot, { lunch_style: 'hot', snack_pm_style: 'savory' }, prefs.low_carb).length;
      return (String(n) + (n < 6 ? '⚠' : ' ')).padStart(10);
    });
    rows.push('  ' + sc.name.padEnd(26) + cells.join(''));
  }
  return rows.join('\n');
}

/** Độ phủ giá theo cửa hàng (thiếu → engine dùng giá cho_khac). */
export function priceCoverage(ds: Dataset): string {
  const total = ds.ingredients.length;
  const rows = ['ĐỘ PHỦ GIÁ (số nguyên liệu có giá riêng của cửa hàng / ' + total + ')'];
  for (const st of ds.stores) {
    const n = ds.ingredients.filter((i) => ds.pricesByIngredient.get(i.id)?.has(st.id)).length;
    rows.push(`  ${st.id.padEnd(16)} ${n}/${total}${st.id === 'cho_khac' ? '' : n < total ? '  (phần thiếu dùng giá cho_khac)' : ''}`);
  }
  const unused = ds.ingredients.filter((i) => !ds.recipes.some((r) => r.ingredients.some((l) => l.ingredient_id === i.id))).map((i) => i.id);
  if (unused.length) rows.push(`  Nguyên liệu không dùng trong công thức nào: ${unused.join(', ')}`);
  return rows.join('\n');
}

/** Mật độ protein ở khẩu phần chuẩn (% calo từ protein) của món chính — để biết dữ liệu có đủ giàu đạm cho mục tiêu 30–35%. */
export function proteinDensity(ds: Dataset): string {
  const rows = ['MẬT ĐỘ PROTEIN MÓN TRƯA/TỐI Ở KHẨU PHẦN CHUẨN (% calo từ protein)'];
  const vals: { id: string; pct: number; kcal: number; p: number }[] = [];
  for (const r of ds.recipes) {
    if (!r.meal_types.includes('lunch') && !r.meal_types.includes('dinner')) continue;
    let kcal = 0;
    let p = 0;
    for (const li of r.ingredients) {
      const m = ds.ingredientsById.get(li.ingredient_id)!.per_100g;
      kcal += (m.kcal * li.grams) / 100;
      p += (m.protein_g * li.grams) / 100;
    }
    vals.push({ id: r.id, pct: (p * 4 * 100) / Math.max(1, kcal), kcal, p });
  }
  vals.sort((a, b) => a.pct - b.pct);
  const q = (f: number) => vals[Math.min(vals.length - 1, Math.floor(f * vals.length))]!;
  const ge = (t: number) => vals.filter((v) => v.pct >= t).length;
  rows.push(`  ${vals.length} món; trung vị ${q(0.5).pct.toFixed(0)}%, thấp nhất ${vals[0]!.pct.toFixed(0)}% (${vals[0]!.id}), cao nhất ${vals.at(-1)!.pct.toFixed(0)}% (${vals.at(-1)!.id})`);
  rows.push(`  ≥ 25% calo từ protein: ${ge(25)}/${vals.length} · ≥ 30%: ${ge(30)}/${vals.length} · ≥ 35%: ${ge(35)}/${vals.length}`);
  const kc = vals.map((v) => v.kcal).sort((a, b) => a - b);
  rows.push(`  kcal khẩu phần chuẩn: min ${kc[0]!.toFixed(0)}, trung vị ${kc[Math.floor(kc.length / 2)]!.toFixed(0)}, max ${kc.at(-1)!.toFixed(0)}`);
  return rows.join('\n');
}

/** Cấu hình tương đương engine trước T-011 cải tiến (để so sánh trước/sau). */
export const LEGACY_OPTIONS: Partial<PlanOptions> = {
  extras: false, budgetRepair: false, poolProteinTolG: 3, poolKcalTolPct: 0.05, refinePasses: 3,
};
