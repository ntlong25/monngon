// T-012 (phần logic thuần) — trạng thái ứng dụng, reducer, selector, migrate. Không phụ thuộc React/Expo/Zustand.
import type { Preferences, Profile } from '../types/profile.ts';
import type { WeekPlan } from '../engine/planWeek.ts';

export const STATE_VERSION = 1;

export interface ShoppingCheck {
  bought?: boolean;
  /** "Nhà có sẵn": bỏ khỏi danh sách và chi phí. */
  have_at_home?: boolean;
}

export interface AppState {
  version: number;
  profile: Profile | null;
  preferences: Preferences | null;
  onboardingStep: number;
  currentPlan: WeekPlan | null;
  savedPlans: WeekPlan[];
  /** plan key (start_date) → ingredient_id → trạng thái. */
  shoppingChecks: Record<string, Record<string, ShoppingCheck>>;
  blockedRecipes: string[];
}

export const initialState = (): AppState => ({
  version: STATE_VERSION, profile: null, preferences: null, onboardingStep: 0, currentPlan: null,
  savedPlans: [], shoppingChecks: {}, blockedRecipes: [],
});

export type Action =
  | { type: 'setProfile'; profile: Profile }
  | { type: 'setPreferences'; preferences: Preferences }
  | { type: 'setOnboardingStep'; step: number }
  | { type: 'setPlan'; plan: WeekPlan }
  | { type: 'toggleShoppingCheck'; ingredient_id: string; field: keyof ShoppingCheck }
  | { type: 'blockRecipe'; recipe_id: string }
  | { type: 'unblockRecipe'; recipe_id: string }
  | { type: 'reset' };

export function reducer(s: AppState, a: Action): AppState {
  switch (a.type) {
    case 'setProfile':
      return { ...s, profile: a.profile };
    case 'setPreferences':
      return { ...s, preferences: a.preferences };
    case 'setOnboardingStep':
      return { ...s, onboardingStep: Math.max(0, Math.floor(a.step)) };
    case 'setPlan': {
      // Tuần cũ (khác ngày bắt đầu) được lưu vào "Tuần đã lưu"; cùng ngày bắt đầu (lên lại) thay thế nhưng vẫn lưu bản cũ.
      const old = s.currentPlan;
      const savedPlans = old ? [old, ...s.savedPlans.filter((p) => p !== old)].slice(0, 20) : s.savedPlans;
      return { ...s, currentPlan: a.plan, savedPlans };
    }
    case 'toggleShoppingCheck': {
      const key = s.currentPlan?.start_date;
      if (!key) return s;
      const week = { ...(s.shoppingChecks[key] ?? {}) };
      const cur = { ...(week[a.ingredient_id] ?? {}) };
      cur[a.field] = !cur[a.field];
      week[a.ingredient_id] = cur;
      return { ...s, shoppingChecks: { ...s.shoppingChecks, [key]: week } };
    }
    case 'blockRecipe':
      return s.blockedRecipes.includes(a.recipe_id) ? s : { ...s, blockedRecipes: [...s.blockedRecipes, a.recipe_id] };
    case 'unblockRecipe':
      return { ...s, blockedRecipes: s.blockedRecipes.filter((r) => r !== a.recipe_id) };
    case 'reset':
      return initialState();
  }
}

// ---- selector ----
export const pantryIdsOf = (s: AppState): string[] => {
  const key = s.currentPlan?.start_date;
  const checks = key ? s.shoppingChecks[key] : undefined;
  return checks ? Object.entries(checks).filter(([, c]) => c.have_at_home).map(([id]) => id) : [];
};
export const boughtIdsOf = (s: AppState): string[] => {
  const key = s.currentPlan?.start_date;
  const checks = key ? s.shoppingChecks[key] : undefined;
  return checks ? Object.entries(checks).filter(([, c]) => c.bought).map(([id]) => id) : [];
};
/** Preferences dùng cho engine: gộp món bị chặn từ store. */
export const effectivePreferences = (s: AppState): Preferences | null =>
  s.preferences && {
    ...s.preferences,
    blocked_recipe_ids: [...new Set([...s.preferences.blocked_recipe_ids, ...s.blockedRecipes])],
  };

// ---- migrate ----
type Migration = (raw: Record<string, unknown>) => Record<string, unknown>;
/** migrations[n] nâng từ phiên bản n lên n+1. Thêm phần tử khi đổi cấu trúc và tăng STATE_VERSION. */
export const migrations: Record<number, Migration> = {};

/** Dữ liệu lưu hỏng/không đọc được → trạng thái mặc định (không bao giờ throw). */
export function migrateState(raw: unknown): AppState {
  if (typeof raw !== 'object' || raw === null) return initialState();
  let cur = raw as Record<string, unknown>;
  let v = typeof cur.version === 'number' ? cur.version : 0;
  if (v > STATE_VERSION) return initialState(); // phiên bản mới hơn app hiện tại: không đoán
  while (v < STATE_VERSION) {
    const m = migrations[v];
    if (!m) return initialState();
    cur = { ...m(cur), version: v + 1 };
    v++;
  }
  return { ...initialState(), ...(cur as Partial<AppState>), version: STATE_VERSION };
}
