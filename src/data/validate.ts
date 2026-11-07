// Kiểm tra dữ liệu seed (T-002). Trả danh sách vấn đề, mỗi vấn đề chỉ rõ file + id + trường.
import { z } from 'zod';
import {
  IngredientSchema, PriceSchema, RecipeSchema, StoreSchema,
  type Ingredient, type Price, type Recipe, type Store,
} from '../types/schema.ts';
import { FALLBACK_STORE_ID, type RawDataset } from './load.ts';

export interface DataIssue {
  severity: 'error' | 'warning';
  file: 'ingredients' | 'recipes' | 'stores' | 'prices';
  id: string;
  field: string;
  message: string;
}

export const formatIssue = (i: DataIssue): string =>
  `${i.severity === 'error' ? 'LỖI' : 'CẢNH BÁO'} ${i.file}.json · ${i.id} · ${i.field}: ${i.message}`;

/** Sai lệch kcal khai báo so với 4/4/9 (carb tính cả bản có trừ xơ ×2 kcal; lấy sai lệch nhỏ hơn). */
export function kcalDeviation(m: Ingredient['per_100g']): number {
  const plain = 4 * m.protein_g + 4 * m.carb_g + 9 * m.fat_g;
  const fiberAware = 4 * m.protein_g + 4 * Math.max(0, m.carb_g - m.fiber_g) + 2 * m.fiber_g + 9 * m.fat_g;
  const rel = (est: number) => Math.abs(est - m.kcal) / Math.max(m.kcal, 1);
  return Math.min(rel(plain), rel(fiberAware));
}
const KCAL_TOLERANCE = 0.15;

function parseEach<T>(
  file: DataIssue['file'], rows: unknown, schema: z.ZodType<T>, idOf: (r: Record<string, unknown>) => string,
  issues: DataIssue[],
): T[] {
  if (!Array.isArray(rows)) {
    issues.push({ severity: 'error', file, id: '(file)', field: '(root)', message: 'phải là một mảng JSON' });
    return [];
  }
  const out: T[] = [];
  rows.forEach((row, idx) => {
    const r = (row ?? {}) as Record<string, unknown>;
    const id = idOf(r) || `(dòng #${idx})`;
    const res = schema.safeParse(row);
    if (res.success) out.push(res.data);
    else
      for (const is of res.error.issues)
        issues.push({ severity: 'error', file, id, field: is.path.join('.') || '(root)', message: is.message });
  });
  return out;
}

function dupes(file: DataIssue['file'], ids: string[], issues: DataIssue[]): void {
  const seen = new Set<string>();
  for (const id of ids) {
    if (seen.has(id)) issues.push({ severity: 'error', file, id, field: 'id', message: 'id bị trùng' });
    seen.add(id);
  }
}

export function validateDataset(raw: RawDataset): DataIssue[] {
  const issues: DataIssue[] = [];
  const str = (r: Record<string, unknown>) => (typeof r.id === 'string' ? r.id : '');
  const ingredients: Ingredient[] = parseEach('ingredients', raw.ingredients, IngredientSchema, str, issues);
  const recipes: Recipe[] = parseEach('recipes', raw.recipes, RecipeSchema, str, issues);
  const stores: Store[] = parseEach('stores', raw.stores, StoreSchema, str, issues);
  const prices: Price[] = parseEach(
    'prices', raw.prices, PriceSchema,
    (r) => `${String(r.ingredient_id ?? '?')}@${String(r.store_id ?? '?')}`, issues,
  );

  dupes('ingredients', ingredients.map((i) => i.id), issues);
  dupes('recipes', recipes.map((r) => r.id), issues);
  dupes('stores', stores.map((s) => s.id), issues);
  dupes('prices', prices.map((p) => `${p.ingredient_id}@${p.store_id}`), issues);

  const ingIds = new Set(ingredients.map((i) => i.id));
  const storeIds = new Set(stores.map((s) => s.id));

  for (const r of recipes) {
    r.ingredients.forEach((li, n) => {
      const f = `ingredients[${n}]`;
      if (!ingIds.has(li.ingredient_id))
        issues.push({ severity: 'error', file: 'recipes', id: r.id, field: `${f}.ingredient_id`, message: `nguyên liệu "${li.ingredient_id}" không tồn tại` });
      if (!(li.min_g <= li.grams && li.grams <= li.max_g))
        issues.push({ severity: 'error', file: 'recipes', id: r.id, field: `${f}.grams`, message: `phải thỏa min_g ≤ grams ≤ max_g (${li.min_g} ≤ ${li.grams} ≤ ${li.max_g})` });
      if (li.role !== 'protein' && li.role !== 'carb' && (li.min_g !== li.grams || li.max_g !== li.grams))
        issues.push({ severity: 'error', file: 'recipes', id: r.id, field: `${f}.min_g/max_g`, message: `vai trò "${li.role}" cố định: min_g = max_g = grams` });
    });
    if (r.is_low_carb) {
      for (const li of r.ingredients)
        if (li.role === 'carb' && li.min_g !== 0)
          issues.push({ severity: 'error', file: 'recipes', id: r.id, field: 'is_low_carb', message: `is_low_carb nhưng "${li.ingredient_id}" (carb) có min_g = ${li.min_g} ≠ 0` });
    }
    if (r.meal_types.includes('lunch') && r.lunch_style.length === 0)
      issues.push({ severity: 'warning', file: 'recipes', id: r.id, field: 'lunch_style', message: 'món trưa chưa khai báo hot/packed' });
    if ((r.meal_types.includes('snack_am') || r.meal_types.includes('snack_pm')) && r.snack_style === null)
      issues.push({ severity: 'warning', file: 'recipes', id: r.id, field: 'snack_style', message: 'bữa phụ chưa khai báo sweet/savory' });
  }

  for (const p of prices) {
    const id = `${p.ingredient_id}@${p.store_id}`;
    if (!ingIds.has(p.ingredient_id))
      issues.push({ severity: 'error', file: 'prices', id, field: 'ingredient_id', message: `nguyên liệu "${p.ingredient_id}" không tồn tại` });
    if (!storeIds.has(p.store_id))
      issues.push({ severity: 'error', file: 'prices', id, field: 'store_id', message: `cửa hàng "${p.store_id}" không tồn tại` });
  }
  const fallbackCovered = new Set(prices.filter((p) => p.store_id === FALLBACK_STORE_ID).map((p) => p.ingredient_id));
  if (!storeIds.has(FALLBACK_STORE_ID))
    issues.push({ severity: 'error', file: 'stores', id: FALLBACK_STORE_ID, field: 'id', message: 'thiếu cửa hàng fallback "cho_khac"' });
  // D-SHP-02: nguyên liệu có purchase_as (cơm chín → gạo sống) lấy giá từ nguyên liệu đích nên không bắt buộc có giá riêng ở cho_khac.
  // Đổi lại, nguyên liệu đích phải tồn tại, có giá ở cho_khac, không trỏ về chính nó và không nối chuỗi.
  const byId = new Map<string, (typeof ingredients)[number]>();
  for (const i of ingredients) if (!byId.has(i.id)) byId.set(i.id, i);
  for (const i of ingredients) {
    if (!i.purchase_as) {
      if (!fallbackCovered.has(i.id))
        issues.push({ severity: 'error', file: 'prices', id: `${i.id}@${FALLBACK_STORE_ID}`, field: 'store_id', message: `nguyên liệu "${i.id}" chưa có giá ở "cho_khac"` });
      continue;
    }
    const t = i.purchase_as.ingredient_id;
    const bad = (message: string) => issues.push({ severity: 'error', file: 'ingredients', id: i.id, field: 'purchase_as.ingredient_id', message });
    const target = byId.get(t);
    if (t === i.id) bad('không được trỏ về chính nó');
    else if (!target) bad(`nguyên liệu "${t}" không tồn tại`);
    else {
      if (target.purchase_as) bad(`"${t}" cũng có purchase_as (không nối chuỗi)`);
      if (!fallbackCovered.has(t)) bad(`"${t}" chưa có giá ở "cho_khac"`);
    }
  }

  for (const i of ingredients) {
    const dev = kcalDeviation(i.per_100g);
    if (dev > KCAL_TOLERANCE)
      issues.push({ severity: 'warning', file: 'ingredients', id: i.id, field: 'per_100g.kcal', message: `kcal khai báo lệch ${(dev * 100).toFixed(0)}% so với 4/4/9 (ngưỡng ${KCAL_TOLERANCE * 100}%)` });
  }
  return issues;
}
