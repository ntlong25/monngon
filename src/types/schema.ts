// Hợp đồng dữ liệu v0.1 (docs/pm/backlog.md) hiện thực bằng zod. Thuần TS, không import React/Expo.
import { z } from 'zod';

const id = z.string().regex(/^[a-z0-9]+(_[a-z0-9]+)*$/, 'id phải là snake_case ASCII không dấu');
const nonNeg = z.number().finite().nonnegative();

export const AISLES = [
  'thit', 'ca_hai_san', 'trung_dau_phu', 'rau_cu', 'trai_cay', 'gao_do_kho', 'gia_vi_dau', 'sua',
] as const;
export const ALLERGEN_TAGS = [
  'peanut', 'tree_nut', 'seed', 'sesame', 'gluten', 'dairy', 'egg', 'soy', 'fish', 'crustacean', 'mollusc',
] as const;
export const DIET_TAGS = ['meat', 'poultry', 'pork', 'red_meat', 'fish', 'seafood', 'egg', 'dairy', 'plant'] as const;
export const MEAL_TYPES = ['breakfast', 'lunch', 'dinner', 'snack_am', 'snack_pm'] as const;
export const ROLES = ['protein', 'carb', 'veg', 'fat', 'seasoning'] as const;
export const EQUIPMENT = [
  'bep', 'noi_com_dien', 'lo_vi_song', 'noi_chien_khong_dau', 'lo_nuong', 'noi_ap_suat', 'may_xay',
] as const;

export const AisleSchema = z.enum(AISLES);
export const AllergenTagSchema = z.enum(ALLERGEN_TAGS);
export const DietTagSchema = z.enum(DIET_TAGS);
export const MealTypeSchema = z.enum(MEAL_TYPES);
export const RoleSchema = z.enum(ROLES);
export const EquipmentSchema = z.enum(EQUIPMENT);

export const MacrosPer100gSchema = z.object({
  kcal: nonNeg,
  protein_g: nonNeg,
  carb_g: nonNeg,
  fat_g: nonNeg,
  fiber_g: nonNeg,
});

export const SourceSchema = z.object({
  db: z.enum(['VN_FCT_2007', 'USDA_FDC']),
  code: z.string().min(1),
  note: z.string().default(''),
});

export const HouseholdUnitSchema = z.object({ unit: z.string().min(1), grams: z.number().positive() });

export const IngredientSchema = z.object({
  id,
  name: z.string().min(1),
  aliases: z.array(z.string()).default([]),
  aisle: AisleSchema,
  per_100g: MacrosPer100gSchema,
  source: SourceSchema,
  allergen_tags: z.array(AllergenTagSchema).default([]),
  diet_tags: z.array(DietTagSchema).default([]),
  household_units: z.array(HouseholdUnitSchema).default([]),
  edible_portion: z.number().gt(0).max(1).default(1),
  default_pantry: z.boolean().default(false),
  /** D-SHP-02: mua dưới dạng nguyên liệu khác (cơm chín → gạo sống); chỉ dùng ở danh sách đi chợ, không đổi dinh dưỡng. */
  purchase_as: z.object({ ingredient_id: id, factor: z.number().gt(0).max(1) }).optional(),
});

export const RecipeIngredientSchema = z.object({
  ingredient_id: id,
  grams: z.number().positive(),
  role: RoleSchema,
  min_g: nonNeg,
  max_g: nonNeg,
  swap_group: z.string().nullable().default(null),
});

export const RecipeSchema = z.object({
  id,
  name: z.string().min(1),
  meal_types: z.array(MealTypeSchema).min(1),
  lunch_style: z.array(z.enum(['hot', 'packed'])).default([]),
  snack_style: z.enum(['sweet', 'savory']).nullable().default(null),
  cuisine_tags: z.array(z.string()).default([]),
  health_tags: z.array(z.string()).default([]),
  equipment: z.array(EquipmentSchema).default([]),
  cook_minutes: nonNeg,
  batchable: z.boolean().default(false),
  is_low_carb: z.boolean().default(false),
  ingredients: z.array(RecipeIngredientSchema).min(1),
  steps: z.array(z.string()).default([]),
  image: z.string().nullable().default(null),
});

export const StoreSchema = z.object({
  id,
  name: z.string().min(1),
  price_survey_date: z.string().optional(),
});

export const PriceSchema = z.object({
  ingredient_id: id,
  store_id: id,
  pack_g: z.number().positive(),
  pack_label: z.string().min(1),
  price_vnd: nonNeg,
  shelf_life_days: z.number().int().positive(),
  source_url: z.string().optional(),
  surveyed_on: z.string().optional(),
});

export type Aisle = z.infer<typeof AisleSchema>;
export type AllergenTag = z.infer<typeof AllergenTagSchema>;
export type DietTag = z.infer<typeof DietTagSchema>;
export type MealType = z.infer<typeof MealTypeSchema>;
export type Role = z.infer<typeof RoleSchema>;
export type Equipment = z.infer<typeof EquipmentSchema>;
export type MacrosPer100g = z.infer<typeof MacrosPer100gSchema>;
export type Ingredient = z.infer<typeof IngredientSchema>;
export type RecipeIngredient = z.infer<typeof RecipeIngredientSchema>;
export type Recipe = z.infer<typeof RecipeSchema>;
export type Store = z.infer<typeof StoreSchema>;
export type Price = z.infer<typeof PriceSchema>;
