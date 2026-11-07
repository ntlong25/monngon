// T-009 — Chi phí suất ăn + danh sách đi chợ: gộp theo hộ, quy ra gói theo cửa hàng, phần dư, 2 loại chi phí.
import { AISLES, type Aisle, type Ingredient, type Price, type Recipe } from '../types/schema.ts';
import { FALLBACK_STORE_ID } from '../data/load.ts';
import type { GramLine } from './nutrition.ts';

export const CHILD_PORTION = 0.6; // giả định Q6
export const MONEY_ROUND_VND = 1000;

export interface ShoppingMeal {
  ingredients: { ingredient_id: string; grams: number; standard_grams: number }[];
}

export interface Household {
  adults: number; // gồm cả "bạn"
  children: number;
}

export interface PriceBook {
  ingredientsById: ReadonlyMap<string, Ingredient>;
  pricesByIngredient: ReadonlyMap<string, ReadonlyMap<string, Price>>;
}

export interface ShoppingItem {
  ingredient_id: string;
  name: string;
  aisle: Aisle;
  /** Lượng cần mua (g), đã tính phần không ăn được (edible_portion). */
  need_g: number;
  packs: number;
  pack_g: number;
  pack_label: string;
  price_vnd_per_pack: number;
  /** Chi phí theo gram dùng (món ăn) và theo gói (trả tại quầy), chưa làm tròn. */
  used_cost_vnd: number;
  till_cost_vnd: number;
  leftover_g: number;
  leftover_days: number;
  price_store_id: string;
  price_fallback: boolean;
}

export interface ShoppingList {
  items: ShoppingItem[];
  byAisle: { aisle: Aisle; items: ShoppingItem[] }[];
  /** Nguyên liệu bỏ qua vì người dùng chọn "nhà có sẵn". */
  skipped_pantry: string[];
  /** Chi phí món ăn tuần này (theo gram dùng), làm tròn 1.000 ₫. */
  week_food_cost: number;
  /** Ước tính trả tại quầy (theo gói), làm tròn 1.000 ₫. */
  till_cost: number;
}

export interface ShoppingOptions {
  store_id: string;
  /** id nguyên liệu người dùng đánh dấu "nhà có sẵn" (gợi ý ban đầu: defaultPantryIds). */
  pantry_ids?: Iterable<string>;
}

const roundMoney = (x: number) => Math.round(x / MONEY_ROUND_VND) * MONEY_ROUND_VND;
const EPS = 1e-9;

export const defaultPantryIds = (ingredients: Iterable<Ingredient>): string[] =>
  [...ingredients].filter((i) => i.default_pantry).map((i) => i.id);

/** Hệ số nhân khẩu phần chuẩn cho những người ăn cùng ngoài "bạn". */
export const otherEatersFactor = (h: Household): number => Math.max(0, h.adults - 1) + h.children * CHILD_PORTION;

function resolvePrice(book: PriceBook, ingredientId: string, storeId: string): { price: Price; fallback: boolean } {
  const m = book.pricesByIngredient.get(ingredientId);
  const own = m?.get(storeId);
  if (own) return { price: own, fallback: false };
  const fb = m?.get(FALLBACK_STORE_ID);
  if (!fb) throw new Error(`Không có giá cho "${ingredientId}" (cả ở cửa hàng "${storeId}" lẫn "${FALLBACK_STORE_ID}")`);
  return { price: fb, fallback: storeId !== FALLBACK_STORE_ID };
}

export function buildShoppingList(
  meals: readonly ShoppingMeal[], household: Household, book: PriceBook, opts: ShoppingOptions,
): ShoppingList {
  const others = otherEatersFactor(household);
  const pantry = new Set(opts.pantry_ids ?? []);
  const eatenG = new Map<string, number>();
  for (const meal of meals)
    for (const li of meal.ingredients)
      eatenG.set(li.ingredient_id, (eatenG.get(li.ingredient_id) ?? 0) + li.grams + others * li.standard_grams);

  const items: ShoppingItem[] = [];
  const skipped: string[] = [];
  for (const [id, grams] of eatenG) {
    if (grams <= 0) continue;
    if (pantry.has(id)) {
      skipped.push(id);
      continue;
    }
    const ing = book.ingredientsById.get(id);
    if (!ing) throw new Error(`Nguyên liệu không tồn tại: ${id}`);
    const { price, fallback } = resolvePrice(book, id, opts.store_id);
    const need = grams / ing.edible_portion;
    const packs = Math.max(1, Math.ceil(need / price.pack_g - EPS));
    items.push({
      ingredient_id: id, name: ing.name, aisle: ing.aisle, need_g: need, packs,
      pack_g: price.pack_g, pack_label: price.pack_label, price_vnd_per_pack: price.price_vnd,
      used_cost_vnd: (need / price.pack_g) * price.price_vnd,
      till_cost_vnd: packs * price.price_vnd,
      leftover_g: packs * price.pack_g - need,
      leftover_days: price.shelf_life_days,
      price_store_id: price.store_id, price_fallback: fallback,
    });
  }

  const order = (a: Aisle) => AISLES.indexOf(a);
  items.sort((a, b) => order(a.aisle) - order(b.aisle) || a.name.localeCompare(b.name, 'vi'));
  const byAisle = AISLES.map((aisle) => ({ aisle, items: items.filter((i) => i.aisle === aisle) })).filter((g) => g.items.length);

  return {
    items, byAisle, skipped_pantry: skipped.sort(),
    week_food_cost: roundMoney(items.reduce((s, i) => s + i.used_cost_vnd, 0)),
    till_cost: roundMoney(items.reduce((s, i) => s + i.till_cost_vnd, 0)),
  };
}

/** Chi phí ước tính của 1 suất (theo gram dùng, chưa làm tròn) — dùng cho chấm điểm chi phí. */
export function servingCostVnd(lines: readonly GramLine[], book: PriceBook, storeId: string): number {
  let total = 0;
  for (const l of lines) {
    if (l.grams <= 0) continue;
    const ing = book.ingredientsById.get(l.ingredient_id);
    if (!ing) throw new Error(`Nguyên liệu không tồn tại: ${l.ingredient_id}`);
    const { price } = resolvePrice(book, l.ingredient_id, storeId);
    total += (l.grams / ing.edible_portion / price.pack_g) * price.price_vnd;
  }
  return total;
}

export const recipeServingCostVnd = (r: Recipe, book: PriceBook, storeId: string): number =>
  servingCostVnd(r.ingredients.map((i) => ({ ingredient_id: i.ingredient_id, grams: i.grams })), book, storeId);
