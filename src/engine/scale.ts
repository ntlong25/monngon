// T-007 — Scale khẩu phần: chỉnh gram nguyên liệu vai trò protein/carb trong [min_g, max_g] (bước 5 g)
// để khớp mục tiêu kcal/protein của 1 bữa. Các vai trò khác giữ nguyên.
import type { Ingredient, Recipe } from '../types/schema.ts';
import type { GramLine, IngredientIndex, Macros } from './nutrition.ts';

export interface ScaleTarget {
  kcal: number;
  protein_g: number;
}

export interface ScaleOptions {
  /** Ít tinh bột: ép mọi nguyên liệu vai trò carb = 0 g. */
  forceZeroCarb?: boolean;
  step?: number; // mặc định 5 g
  /** Ngưỡng coi là đạt: protein ±3 g, kcal ±5%. */
  proteinToleranceG?: number;
  kcalTolerancePct?: number;
}

export interface ScaleResult {
  grams: GramLine[]; // cùng thứ tự recipe.ingredients
  macros: Macros;
  deviation: {
    protein_g: number; // thực − mục tiêu (âm = thiếu)
    kcal: number;
    kcal_pct: number; // (thực − mục tiêu) / mục tiêu
  };
  /** Không đạt dung sai (protein thiếu > 3 g hoặc kcal lệch > 5%): nghiệm trả về là nghiệm gần nhất. */
  infeasible: boolean;
}

const OVER_PROTEIN_WEIGHT = 0.5;
const VIOLATION_PENALTY = 1000;

interface Line {
  base: number;
  lo: number;
  hi: number;
  kcalPerG: number;
  protPerG: number;
  carbPerG: number;
  fatPerG: number;
  fiberPerG: number;
}

function candidateVectors(lines: Line[], step: number): number[][] {
  if (lines.length === 0) return [[]];
  const seen = new Set<string>();
  const out: number[][] = [];
  for (let f = 0; f <= 4.0001; f += 0.005) {
    const v = lines.map((l) => Math.min(l.hi, Math.max(l.lo, Math.round((l.base * f) / step) * step)));
    const key = v.join(',');
    if (!seen.has(key)) {
      seen.add(key);
      out.push(v);
    }
  }
  return out;
}

export function scaleRecipe(
  recipe: Recipe, index: IngredientIndex, target: ScaleTarget, opts: ScaleOptions = {},
): ScaleResult {
  const step = opts.step ?? 5;
  const pTol = opts.proteinToleranceG ?? 3;
  const kTol = opts.kcalTolerancePct ?? 0.05;

  const lines: Line[] = recipe.ingredients.map((li) => {
    const ing: Ingredient | undefined = index.get(li.ingredient_id);
    if (!ing) throw new Error(`Nguyên liệu không tồn tại: ${li.ingredient_id}`);
    const zero = opts.forceZeroCarb && li.role === 'carb';
    const scalable = li.role === 'protein' || li.role === 'carb';
    const m = ing.per_100g;
    return {
      base: zero ? 0 : li.grams,
      lo: zero ? 0 : scalable ? li.min_g : li.grams,
      hi: zero ? 0 : scalable ? li.max_g : li.grams,
      kcalPerG: m.kcal / 100, protPerG: m.protein_g / 100, carbPerG: m.carb_g / 100,
      fatPerG: m.fat_g / 100, fiberPerG: m.fiber_g / 100,
    };
  });

  const scalableIdx = (role: string) =>
    recipe.ingredients.flatMap((li, i) => (li.role === role && lines[i]!.lo < lines[i]!.hi ? [i] : []));
  const protIdx = scalableIdx('protein');
  const carbIdx = scalableIdx('carb');

  const grams = lines.map((l) => (l.lo === l.hi ? l.lo : l.base));
  let kcal0 = 0;
  let prot0 = 0;
  const free = new Set([...protIdx, ...carbIdx]);
  lines.forEach((l, i) => {
    if (free.has(i)) return;
    kcal0 += l.kcalPerG * grams[i]!;
    prot0 += l.protPerG * grams[i]!;
  });

  const protCands = candidateVectors(protIdx.map((i) => lines[i]!), step);
  const carbCands = candidateVectors(carbIdx.map((i) => lines[i]!), step);
  // Gộp hệ số theo từng ứng viên để vòng lặp trong cùng chỉ cộng số.
  const agg = (idx: number[], cands: number[][]) =>
    cands.map((v) => {
      let k = 0;
      let p = 0;
      let dist = 0;
      v.forEach((g, n) => {
        const l = lines[idx[n]!]!;
        k += l.kcalPerG * g;
        p += l.protPerG * g;
        dist += l.base > 0 ? Math.abs(g - l.base) / l.base : 0;
      });
      return { v, k, p, dist };
    });
  const pA = agg(protIdx, protCands);
  const cA = agg(carbIdx, carbCands);

  let best = { cost: Infinity, pi: 0, ci: 0 };
  for (let pi = 0; pi < pA.length; pi++) {
    const a = pA[pi]!;
    for (let ci = 0; ci < cA.length; ci++) {
      const b = cA[ci]!;
      const dP = prot0 + a.p + b.p - target.protein_g;
      const dK = kcal0 + a.k + b.k - target.kcal;
      const pTerm = (dP < 0 ? -dP : dP * OVER_PROTEIN_WEIGHT) / pTol;
      const kTerm = Math.abs(dK) / Math.max(1, kTol * target.kcal);
      const cost =
        pTerm * pTerm + kTerm * kTerm +
        VIOLATION_PENALTY * (Math.max(0, pTerm - 1) + Math.max(0, kTerm - 1)) +
        1e-6 * (a.dist + b.dist);
      if (cost < best.cost) best = { cost, pi, ci };
    }
  }

  pA[best.pi]!.v.forEach((g, n) => (grams[protIdx[n]!] = g));
  cA[best.ci]!.v.forEach((g, n) => (grams[carbIdx[n]!] = g));

  const macros: Macros = { kcal: 0, protein_g: 0, carb_g: 0, fat_g: 0, fiber_g: 0 };
  lines.forEach((l, i) => {
    const g = grams[i]!;
    macros.kcal += l.kcalPerG * g;
    macros.protein_g += l.protPerG * g;
    macros.carb_g += l.carbPerG * g;
    macros.fat_g += l.fatPerG * g;
    macros.fiber_g += l.fiberPerG * g;
  });

  const dProt = macros.protein_g - target.protein_g;
  const dKcal = macros.kcal - target.kcal;
  const kcalPct = target.kcal > 0 ? dKcal / target.kcal : 0;
  return {
    grams: recipe.ingredients.map((li, i) => ({ ingredient_id: li.ingredient_id, grams: grams[i]! })),
    macros,
    deviation: { protein_g: dProt, kcal: dKcal, kcal_pct: kcalPct },
    infeasible: -dProt > pTol || Math.abs(kcalPct) > kTol,
  };
}
