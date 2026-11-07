// T-006 — Bộ lọc cứng: Preferences → nguyên liệu bị cấm → công thức hợp lệ (kèm lý do loại để debug).
// Quy tắc ánh xạ tạm theo hợp đồng dữ liệu; sẽ đối chiếu docs/research/allergen-rules.md (T-041) khi có.
import type { Exclusion, Preferences, Slot, SlotsConfig } from '../types/profile.ts';
import type { AllergenTag, DietTag, Ingredient, Recipe } from '../types/schema.ts';

interface Ban { allergens?: AllergenTag[]; diet?: DietTag[] }

/** Mỗi lựa chọn loại trừ cấm nguyên liệu có BẤT KỲ tag nào dưới đây. Lạc ≠ hạt cây ≠ hạt giống (hướng dương) ≠ vừng. */
export const EXCLUSION_BANS: Record<Exclusion, Ban> = {
  no_pork: { diet: ['pork'] },
  no_red_meat: { diet: ['red_meat'] },
  no_gluten: { allergens: ['gluten'] },
  no_dairy: { allergens: ['dairy'], diet: ['dairy'] },
  no_egg: { allergens: ['egg'], diet: ['egg'] },
  no_peanut: { allergens: ['peanut'] },
  no_tree_nut: { allergens: ['tree_nut'] },
  no_seed: { allergens: ['seed'] },
  no_sesame: { allergens: ['sesame'] },
  no_soy: { allergens: ['soy'] },
  no_fish: { allergens: ['fish'], diet: ['fish'] },
  no_shellfish: { allergens: ['crustacean', 'mollusc'], diet: ['seafood'] },
};

export const DIET_BANS: Record<Preferences['diet'], DietTag[]> = {
  none: [],
  vegetarian: ['meat', 'poultry', 'pork', 'red_meat', 'fish', 'seafood'],
  vegan: ['meat', 'poultry', 'pork', 'red_meat', 'fish', 'seafood', 'egg', 'dairy'],
  pescatarian: ['meat', 'poultry', 'pork', 'red_meat'],
};

export type FilterPrefs = Pick<
  Preferences,
  'diet' | 'exclusions' | 'disliked_ingredient_ids' | 'blocked_recipe_ids' | 'equipment' | 'low_carb'
>;

export interface BannedIngredient {
  /** Các lý do (vd "no_peanut", "diet:vegan", "disliked"). */
  reasons: string[];
}

/** Tập nguyên liệu bị cấm → lý do. */
export function bannedIngredients(
  ingredients: Iterable<Ingredient>, prefs: FilterPrefs,
): Map<string, BannedIngredient> {
  const dietBan = new Set(DIET_BANS[prefs.diet]);
  const disliked = new Set(prefs.disliked_ingredient_ids);
  const out = new Map<string, BannedIngredient>();
  for (const ing of ingredients) {
    const reasons: string[] = [];
    for (const ex of prefs.exclusions) {
      const ban = EXCLUSION_BANS[ex];
      if (ban.allergens?.some((a) => ing.allergen_tags.includes(a)) || ban.diet?.some((d) => ing.diet_tags.includes(d)))
        reasons.push(ex);
    }
    if (ing.diet_tags.some((d) => dietBan.has(d))) reasons.push(`diet:${prefs.diet}`);
    if (disliked.has(ing.id)) reasons.push('disliked');
    if (reasons.length) out.set(ing.id, { reasons });
  }
  return out;
}

export interface ValidRecipe {
  recipe: Recipe;
  /** Ít tinh bột: engine phải ép nguyên liệu vai trò carb = 0 g. */
  forceZeroCarb: boolean;
}

export interface FilterResult {
  valid: ValidRecipe[];
  /** recipe_id → lý do loại (để debug). */
  excluded: Map<string, string[]>;
}

export function filterRecipes(
  recipes: readonly Recipe[], ingredientsById: ReadonlyMap<string, Ingredient>, prefs: FilterPrefs,
): FilterResult {
  const banned = bannedIngredients(ingredientsById.values(), prefs);
  const blocked = new Set(prefs.blocked_recipe_ids);
  const have = new Set<string>(prefs.equipment);
  const valid: ValidRecipe[] = [];
  const excluded = new Map<string, string[]>();

  for (const recipe of recipes) {
    const why: string[] = [];
    if (blocked.has(recipe.id)) why.push('blocked');
    for (const li of recipe.ingredients) {
      if (!ingredientsById.has(li.ingredient_id)) why.push(`unknown_ingredient:${li.ingredient_id}`);
      const b = banned.get(li.ingredient_id);
      if (b) why.push(`ingredient:${li.ingredient_id}(${b.reasons.join('+')})`);
    }
    const missing = recipe.equipment.filter((e) => !have.has(e));
    if (missing.length) why.push(`equipment:${missing.join(',')}`);

    if (why.length) excluded.set(recipe.id, why);
    else valid.push({ recipe, forceZeroCarb: false });
  }
  return { valid, excluded };
}

const MAIN_LOW_CARB_SLOTS: readonly Slot[] = ['lunch', 'dinner'];

/**
 * Công thức dùng được cho 1 slot: đúng meal_type; trưa khớp hot/packed; phụ chiều khớp ngọt/mặn;
 * Ít tinh bột → trưa/tối chỉ nhận `is_low_carb` và ép carb = 0.
 */
export function recipesForSlot(
  valid: readonly ValidRecipe[], slot: Slot, cfg: Pick<SlotsConfig, 'lunch_style' | 'snack_pm_style'>, lowCarb: boolean,
): ValidRecipe[] {
  const out: ValidRecipe[] = [];
  for (const v of valid) {
    const r = v.recipe;
    if (!r.meal_types.includes(slot)) continue;
    if (slot === 'lunch' && r.lunch_style.length > 0 && !r.lunch_style.includes(cfg.lunch_style)) continue;
    if (slot === 'snack_pm' && r.snack_style !== null && r.snack_style !== cfg.snack_pm_style) continue;
    if (lowCarb && MAIN_LOW_CARB_SLOTS.includes(slot)) {
      if (!r.is_low_carb) continue;
      out.push({ recipe: r, forceZeroCarb: true });
    } else out.push({ recipe: r, forceZeroCarb: false });
  }
  return out;
}
