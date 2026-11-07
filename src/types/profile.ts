// Dữ liệu người dùng nhập ở onboarding (PRD Epic 1).
import { z } from 'zod';
import { EquipmentSchema } from './schema.ts';

export const GoalSchema = z.enum(['lose', 'hold', 'build']);
export const SexSchema = z.enum(['male', 'female']);
export const ActivitySchema = z.enum(['sedentary', 'light', 'moderate', 'high', 'athlete']);

export const ProfileSchema = z.object({
  goal: GoalSchema,
  sex: SexSchema,
  age: z.number().min(14).max(90),
  height_cm: z.number().min(120).max(220),
  weight_kg: z.number().min(30).max(250),
  activity: ActivitySchema,
  target_mode: z.enum(['formula', 'manual']).default('formula'),
  manual_kcal: z.number().positive().optional(),
  manual_protein_g: z.number().positive().optional(),
});

export const SLOTS = ['breakfast', 'lunch', 'dinner', 'snack_am', 'snack_pm'] as const;
export const SlotSchema = z.enum(SLOTS);
export const SlotModeSchema = z.enum(['on', 'self', 'skip']);

export const SlotsConfigSchema = z.object({
  breakfast: SlotModeSchema,
  lunch: SlotModeSchema,
  dinner: SlotModeSchema,
  snack_am: SlotModeSchema,
  snack_pm: SlotModeSchema,
  lunch_style: z.enum(['hot', 'packed']).default('hot'),
  snack_pm_style: z.enum(['sweet', 'savory']).default('savory'),
});

/** Các lựa chọn loại bỏ hoàn toàn (ràng buộc cứng). */
export const EXCLUSIONS = [
  'no_pork', 'no_red_meat', 'no_gluten', 'no_dairy', 'no_egg', 'no_peanut', 'no_tree_nut',
  'no_seed', 'no_sesame', 'no_soy', 'no_fish', 'no_shellfish',
] as const;
export const ExclusionSchema = z.enum(EXCLUSIONS);

export const PreferencesSchema = z.object({
  store_id: z.string(),
  weekly_budget_vnd: z.number().nonnegative(),
  adults: z.number().int().min(1).max(6).default(1),
  children: z.number().int().min(0).max(4).default(0),
  slots: SlotsConfigSchema,
  diet: z.enum(['none', 'vegetarian', 'vegan', 'pescatarian']).default('none'),
  low_carb: z.boolean().default(false),
  exclusions: z.array(ExclusionSchema).default([]),
  disliked_ingredient_ids: z.array(z.string()).default([]),
  health_leanings: z.array(z.string()).default([]),
  cuisine_likes: z.array(z.string()).default([]),
  cuisine_less: z.array(z.string()).default([]),
  equipment: z.array(EquipmentSchema).default([]),
  blocked_recipe_ids: z.array(z.string()).default([]),
});

export type Goal = z.infer<typeof GoalSchema>;
export type Sex = z.infer<typeof SexSchema>;
export type Activity = z.infer<typeof ActivitySchema>;
export type Profile = z.infer<typeof ProfileSchema>;
export type Slot = z.infer<typeof SlotSchema>;
export type SlotMode = z.infer<typeof SlotModeSchema>;
export type SlotsConfig = z.infer<typeof SlotsConfigSchema>;
export type Exclusion = z.infer<typeof ExclusionSchema>;
export type Preferences = z.infer<typeof PreferencesSchema>;
