import ingredients from './ingredients.json';
import recipes from './recipes.json';
import stores from './stores.json';
import prices from './prices.json';
import { loadDataset, type Dataset } from '../../data/load.ts';
import type { Preferences, Profile } from '../../types/profile.ts';
import { PreferencesSchema } from '../../types/profile.ts';

export const rawFixture = { ingredients, recipes, stores, prices };
export const fixtureDataset = (): Dataset => loadDataset(rawFixture);

/** Ví dụ trong spec mục 4.8: nam 30t, 177,8 cm, 81,6 kg, vận động vừa, giảm mỡ → 2.200 kcal / 175 g. */
export const specProfile: Profile = {
  goal: 'lose', sex: 'male', age: 30, height_cm: 177.8, weight_kg: 81.6, activity: 'moderate', target_mode: 'formula',
};

export const basePrefs = (over: Partial<Preferences> = {}): Preferences =>
  PreferencesSchema.parse({
    store_id: 'winmart',
    weekly_budget_vnd: 600000,
    slots: { breakfast: 'on', lunch: 'on', dinner: 'on', snack_am: 'skip', snack_pm: 'skip' },
    equipment: ['bep', 'noi_com_dien', 'lo_vi_song'],
    ...over,
  });
