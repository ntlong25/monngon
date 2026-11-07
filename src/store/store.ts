// Store tối giản + lưu trữ qua giao diện KeyValueStorage (AsyncStorage/localStorage gắn vào ở tầng app).
import { planWeek, type WeekPlan } from '../engine/planWeek.ts';
import { computeTargets } from '../engine/targets.ts';
import type { Dataset } from '../data/load.ts';
import { effectivePreferences, initialState, migrateState, reducer, type Action, type AppState } from './state.ts';

export interface KeyValueStorage {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
}

export const STORAGE_KEY = 'mon-ngon/state';

export interface AppStore {
  getState(): AppState;
  dispatch(a: Action): void;
  subscribe(fn: (s: AppState) => void): () => void;
  /** Nạp từ storage (lỗi/hỏng → trạng thái mặc định). */
  hydrate(): Promise<AppState>;
  /** Chờ các lần ghi đang chạy xong (dùng trong test / trước khi thoát). */
  flush(): Promise<void>;
  /** Xóa sạch dữ liệu: state và storage. */
  clearAll(): Promise<void>;
}

export function createStore(storage: KeyValueStorage, key = STORAGE_KEY): AppStore {
  let state = initialState();
  const subs = new Set<(s: AppState) => void>();
  let pending: Promise<void> = Promise.resolve();

  const persist = (): void => {
    const snapshot = JSON.stringify(state);
    pending = pending.then(() => storage.setItem(key, snapshot)).catch(() => undefined);
  };

  return {
    getState: () => state,
    dispatch(a) {
      const next = reducer(state, a);
      if (next === state) return;
      state = next;
      persist();
      subs.forEach((f) => f(state));
    },
    subscribe(fn) {
      subs.add(fn);
      return () => subs.delete(fn);
    },
    async hydrate() {
      try {
        const raw = await storage.getItem(key);
        state = raw ? migrateState(JSON.parse(raw)) : initialState();
      } catch {
        state = initialState();
      }
      subs.forEach((f) => f(state));
      return state;
    },
    flush: () => pending,
    async clearAll() {
      await pending;
      state = initialState();
      await storage.removeItem(key).catch(() => undefined);
      subs.forEach((f) => f(state));
    },
  };
}

export class MissingOnboardingError extends Error {
  constructor() {
    super('Chưa có hồ sơ và lựa chọn onboarding để lập tuần');
    this.name = 'MissingOnboardingError';
  }
}

/** Lập tuần từ state hiện tại (hàm đồng bộ, thuần; app gọi trong worker/InteractionManager để không chặn UI). */
export function generatePlan(state: AppState, data: Dataset, start_date: string, seed: number): WeekPlan {
  const prefs = effectivePreferences(state);
  if (!state.profile || !prefs) throw new MissingOnboardingError();
  return planWeek({ targets: computeTargets(state.profile), prefs, data, start_date, seed });
}
