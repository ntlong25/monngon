// Nạp dữ liệu seed đã parse + lập index theo id. Thuần TS (không I/O).
import { z } from 'zod';
import {
  IngredientSchema, PriceSchema, RecipeSchema, StoreSchema,
  type Ingredient, type Price, type Recipe, type Store,
} from '../types/schema.ts';

export interface RawDataset {
  ingredients: unknown;
  recipes: unknown;
  stores: unknown;
  prices: unknown;
}

export interface Dataset {
  ingredients: Ingredient[];
  recipes: Recipe[];
  stores: Store[];
  prices: Price[];
  ingredientsById: Map<string, Ingredient>;
  recipesById: Map<string, Recipe>;
  storesById: Map<string, Store>;
  /** ingredient_id -> store_id -> Price */
  pricesByIngredient: Map<string, Map<string, Price>>;
}

export const FALLBACK_STORE_ID = 'cho_khac';

export function buildDataset(parts: Pick<Dataset, 'ingredients' | 'recipes' | 'stores' | 'prices'>): Dataset {
  const pricesByIngredient = new Map<string, Map<string, Price>>();
  for (const p of parts.prices) {
    let m = pricesByIngredient.get(p.ingredient_id);
    if (!m) pricesByIngredient.set(p.ingredient_id, (m = new Map()));
    m.set(p.store_id, p);
  }
  return {
    ...parts,
    ingredientsById: new Map(parts.ingredients.map((i) => [i.id, i])),
    recipesById: new Map(parts.recipes.map((r) => [r.id, r])),
    storesById: new Map(parts.stores.map((s) => [s.id, s])),
    pricesByIngredient,
  };
}

/** Parse nghiêm ngặt: lỗi schema → throw. Dùng validateDataset (validate.ts) để có báo cáo chi tiết. */
export function loadDataset(raw: RawDataset): Dataset {
  return buildDataset({
    ingredients: z.array(IngredientSchema).parse(raw.ingredients),
    recipes: z.array(RecipeSchema).parse(raw.recipes),
    stores: z.array(StoreSchema).parse(raw.stores),
    prices: z.array(PriceSchema).parse(raw.prices),
  });
}

/** Giá của nguyên liệu tại cửa hàng; thiếu thì dùng `cho_khac`. */
export function findPrice(
  ds: Pick<Dataset, 'pricesByIngredient'>, ingredientId: string, storeId: string,
): { price: Price; fallback: boolean } | undefined {
  const m = ds.pricesByIngredient.get(ingredientId);
  if (!m) return undefined;
  const own = m.get(storeId);
  if (own) return { price: own, fallback: false };
  const fb = m.get(FALLBACK_STORE_ID);
  return fb ? { price: fb, fallback: storeId !== FALLBACK_STORE_ID } : undefined;
}
