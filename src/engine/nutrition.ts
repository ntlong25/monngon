// T-005 — Macro tất định: Σ gram × per_100g / 100, kèm dấu vết nguồn từng dòng (F-ENG-04, NFR-01).
import type { Ingredient, Recipe } from '../types/schema.ts';

export interface Macros {
  kcal: number;
  protein_g: number;
  carb_g: number;
  fat_g: number;
  fiber_g: number;
}

export interface MacroLine {
  ingredient_id: string;
  name: string;
  grams: number;
  macros: Macros;
  source: Ingredient['source'];
}

export interface MacroResult {
  total: Macros;
  lines: MacroLine[];
}

export interface GramLine {
  ingredient_id: string;
  grams: number;
}

export type IngredientIndex = ReadonlyMap<string, Ingredient>;

export const ZERO_MACROS: Macros = { kcal: 0, protein_g: 0, carb_g: 0, fat_g: 0, fiber_g: 0 };

export function addMacros(a: Macros, b: Macros): Macros {
  return {
    kcal: a.kcal + b.kcal, protein_g: a.protein_g + b.protein_g, carb_g: a.carb_g + b.carb_g,
    fat_g: a.fat_g + b.fat_g, fiber_g: a.fiber_g + b.fiber_g,
  };
}

export function macrosOf(ing: Ingredient, grams: number): Macros {
  const k = grams / 100;
  const m = ing.per_100g;
  return { kcal: m.kcal * k, protein_g: m.protein_g * k, carb_g: m.carb_g * k, fat_g: m.fat_g * k, fiber_g: m.fiber_g * k };
}

/** Macro của một suất (giá trị chưa làm tròn). Nguyên liệu không có trong kho → throw. */
export function computeMacros(lines: readonly GramLine[], index: IngredientIndex): MacroResult {
  let total = ZERO_MACROS;
  const out: MacroLine[] = lines.map((l) => {
    const ing = index.get(l.ingredient_id);
    if (!ing) throw new Error(`Nguyên liệu không tồn tại: ${l.ingredient_id}`);
    const macros = macrosOf(ing, l.grams);
    total = addMacros(total, macros);
    return { ingredient_id: l.ingredient_id, name: ing.name, grams: l.grams, macros, source: ing.source };
  });
  return { total, lines: out };
}

export const recipeBaseLines = (r: Recipe): GramLine[] =>
  r.ingredients.map((i) => ({ ingredient_id: i.ingredient_id, grams: i.grams }));

/** Làm tròn CHỈ để hiển thị: protein/carb/fat 1 g, kcal 5 kcal. Giá trị tính toán giữ nguyên. */
export function roundForDisplay(m: Macros): Macros {
  const r1 = (x: number) => Math.round(x);
  return {
    kcal: Math.round(m.kcal / 5) * 5, protein_g: r1(m.protein_g), carb_g: r1(m.carb_g),
    fat_g: r1(m.fat_g), fiber_g: r1(m.fiber_g),
  };
}

/** Chuỗi nguồn để hiển thị ở "Cách chúng mình tính". */
export function formatSource(s: Ingredient['source']): string {
  return s.db === 'USDA_FDC' ? `USDA FDC #${s.code}` : `Bảng TPDD VN 2007 · mã ${s.code}`;
}
