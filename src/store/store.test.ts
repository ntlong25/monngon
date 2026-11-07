import { describe, expect, it } from 'vitest';
import { boughtIdsOf, effectivePreferences, initialState, migrateState, migrations, pantryIdsOf, reducer, STATE_VERSION } from './state.ts';
import { createStore, generatePlan, MissingOnboardingError, STORAGE_KEY, type KeyValueStorage } from './store.ts';
import { basePrefs, fixtureDataset, specProfile } from '../engine/__fixtures__/index.ts';

const memory = (): KeyValueStorage & { data: Map<string, string> } => {
  const data = new Map<string, string>();
  return {
    data,
    getItem: async (k) => data.get(k) ?? null,
    setItem: async (k, v) => void data.set(k, v),
    removeItem: async (k) => void data.delete(k),
  };
};
const ds = fixtureDataset();
const prefs = basePrefs({ weekly_budget_vnd: 1_500_000 });

describe('reducer / selector', () => {
  it('đặt hồ sơ, lựa chọn, bước onboarding', () => {
    let s = reducer(initialState(), { type: 'setProfile', profile: specProfile });
    s = reducer(s, { type: 'setPreferences', preferences: prefs });
    s = reducer(s, { type: 'setOnboardingStep', step: 4.7 });
    expect(s).toMatchObject({ profile: specProfile, preferences: prefs, onboardingStep: 4 });
  });

  it('chặn / bỏ chặn món, không trùng; gộp vào preferences cho engine', () => {
    let s = reducer({ ...initialState(), preferences: prefs }, { type: 'blockRecipe', recipe_id: 'a' });
    s = reducer(s, { type: 'blockRecipe', recipe_id: 'a' });
    expect(s.blockedRecipes).toEqual(['a']);
    expect(effectivePreferences(s)!.blocked_recipe_ids).toEqual(['a']);
    s = reducer(s, { type: 'unblockRecipe', recipe_id: 'a' });
    expect(s.blockedRecipes).toEqual([]);
  });

  it('đánh dấu đã mua / nhà có sẵn theo tuần hiện tại; không có tuần thì bỏ qua', () => {
    const s0 = initialState();
    expect(reducer(s0, { type: 'toggleShoppingCheck', ingredient_id: 'x', field: 'bought' })).toBe(s0);
    const plan = generatePlan({ ...s0, profile: specProfile, preferences: prefs }, ds, '2026-11-07', 1);
    let s = reducer(s0, { type: 'setPlan', plan });
    s = reducer(s, { type: 'toggleShoppingCheck', ingredient_id: 'dau_an', field: 'have_at_home' });
    s = reducer(s, { type: 'toggleShoppingCheck', ingredient_id: 'trung_ga', field: 'bought' });
    expect(pantryIdsOf(s)).toEqual(['dau_an']);
    expect(boughtIdsOf(s)).toEqual(['trung_ga']);
    s = reducer(s, { type: 'toggleShoppingCheck', ingredient_id: 'trung_ga', field: 'bought' });
    expect(boughtIdsOf(s)).toEqual([]);
  });

  it('setPlan lưu tuần cũ vào "Tuần đã lưu"', () => {
    const p1 = generatePlan({ ...initialState(), profile: specProfile, preferences: prefs }, ds, '2026-11-07', 1);
    const p2 = generatePlan({ ...initialState(), profile: specProfile, preferences: prefs }, ds, '2026-11-14', 1);
    let s = reducer(initialState(), { type: 'setPlan', plan: p1 });
    expect(s.savedPlans).toEqual([]);
    s = reducer(s, { type: 'setPlan', plan: p2 });
    expect(s.currentPlan).toBe(p2);
    expect(s.savedPlans).toEqual([p1]);
  });

  it('reset trả về trạng thái sạch', () => {
    const s = reducer({ ...initialState(), profile: specProfile, blockedRecipes: ['a'] }, { type: 'reset' });
    expect(s).toEqual(initialState());
  });
});

describe('persist + hydrate', () => {
  it('tắt/mở lại: giữ nguyên trạng thái', async () => {
    const mem = memory();
    const a = createStore(mem);
    a.dispatch({ type: 'setProfile', profile: specProfile });
    a.dispatch({ type: 'setPreferences', preferences: prefs });
    a.dispatch({ type: 'setOnboardingStep', step: 3 });
    a.dispatch({ type: 'setPlan', plan: generatePlan(a.getState(), ds, '2026-11-07', 7) });
    await a.flush();

    const b = createStore(mem);
    const s = await b.hydrate();
    expect(s).toEqual(JSON.parse(JSON.stringify(a.getState())));
    expect(s.currentPlan?.days).toHaveLength(7); // hồ sơ spec (2.200 kcal/175 g) trên fixture nhỏ có thể là partial
  });

  it('subscribe nhận cập nhật; hủy đăng ký được', () => {
    const st = createStore(memory());
    const seen: number[] = [];
    const off = st.subscribe((s) => seen.push(s.onboardingStep));
    st.dispatch({ type: 'setOnboardingStep', step: 1 });
    off();
    st.dispatch({ type: 'setOnboardingStep', step: 2 });
    expect(seen).toEqual([1]);
  });

  it('dữ liệu lưu hỏng → trạng thái mặc định, không throw', async () => {
    const mem = memory();
    mem.data.set(STORAGE_KEY, '{không phải json');
    expect(await createStore(mem).hydrate()).toEqual(initialState());
  });

  it('storage lỗi ghi không làm app sập', async () => {
    const bad: KeyValueStorage = { getItem: async () => null, setItem: async () => { throw new Error('đầy'); }, removeItem: async () => {} };
    const st = createStore(bad);
    st.dispatch({ type: 'setOnboardingStep', step: 2 });
    await st.flush();
    expect(st.getState().onboardingStep).toBe(2);
  });

  it('xóa dữ liệu reset sạch cả state lẫn storage', async () => {
    const mem = memory();
    const st = createStore(mem);
    st.dispatch({ type: 'setProfile', profile: specProfile });
    await st.clearAll();
    expect(st.getState()).toEqual(initialState());
    expect(mem.data.has(STORAGE_KEY)).toBe(false);
    expect(await createStore(mem).hydrate()).toEqual(initialState());
  });
});

describe('migrateState', () => {
  it('phiên bản hiện tại: giữ nguyên', () => {
    const s = { ...initialState(), onboardingStep: 5 };
    expect(migrateState(s)).toEqual(s);
  });
  it('thiếu trường mới được bù mặc định', () => {
    expect(migrateState({ version: STATE_VERSION, onboardingStep: 2 })).toEqual({ ...initialState(), onboardingStep: 2 });
  });
  it('phiên bản mới hơn / không rõ / rác → mặc định', () => {
    expect(migrateState({ version: STATE_VERSION + 1, onboardingStep: 9 })).toEqual(initialState());
    expect(migrateState(null)).toEqual(initialState());
    expect(migrateState('x')).toEqual(initialState());
    expect(migrateState({ version: 0 })).toEqual(initialState()); // chưa có migration 0→1
  });
  it('áp dụng migration theo bậc (mô phỏng v0 → v1)', () => {
    migrations[0] = (r) => ({ ...r, onboardingStep: (r.step as number) ?? 0 });
    try {
      expect(migrateState({ version: 0, step: 3 }).onboardingStep).toBe(3);
    } finally {
      delete migrations[0];
    }
  });
});

describe('generatePlan', () => {
  it('thiếu onboarding → lỗi rõ ràng', () => {
    expect(() => generatePlan(initialState(), ds, '2026-11-07', 1)).toThrow(MissingOnboardingError);
  });
  it('dùng món bị chặn từ store', () => {
    const state = reducer({ ...initialState(), profile: specProfile, preferences: prefs }, { type: 'blockRecipe', recipe_id: 'ca_basa_kho_rau_muong' });
    const plan = generatePlan(state, ds, '2026-11-07', 1);
    expect(plan.days.flatMap((d) => d.meals).some((m) => m.recipe_id === 'ca_basa_kho_rau_muong')).toBe(false);
  });
});
