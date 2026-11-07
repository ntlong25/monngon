// Hồ sơ tạm tự định nghĩa (dùng khi chạy `engine-report -- --profiles tmp`). Mặc định đọc data/test-profiles.json.
import { PreferencesSchema, type Preferences, type Profile } from '../types/profile.ts';
import type { ReportProfile } from '../data/testProfiles.ts';

export type { ReportProfile };

const ALL_EQ = ['bep', 'noi_com_dien', 'lo_vi_song', 'noi_chien_khong_dau', 'lo_nuong', 'noi_ap_suat', 'may_xay'];
const SLOTS_3 = { breakfast: 'on', lunch: 'on', dinner: 'on', snack_am: 'skip', snack_pm: 'skip' } as const;
const SLOTS_5 = { breakfast: 'on', lunch: 'on', dinner: 'on', snack_am: 'on', snack_pm: 'on' } as const;
const SLOTS_LD = { breakfast: 'self', lunch: 'on', dinner: 'on', snack_am: 'skip', snack_pm: 'skip' } as const;

const prefs = (o: Record<string, unknown>): Preferences =>
  PreferencesSchema.parse({ store_id: 'winmart', weekly_budget_vnd: 800_000, slots: SLOTS_3, equipment: ALL_EQ, ...o });

const man = (p: Partial<Profile>): Profile => ({
  goal: 'hold', sex: 'male', age: 30, height_cm: 170, weight_kg: 70, activity: 'moderate', target_mode: 'formula', ...p,
});

export const REPORT_PROFILES: ReportProfile[] = [
  { name: 'spec-nam-giam-mo', note: 'Ví dụ spec: 2.200 kcal / 175 g, 3 bữa', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 30, height_cm: 177.8, weight_kg: 81.6 }), prefs: prefs({ weekly_budget_vnd: 900_000 }) },
  { name: 'spec-nam-5-bua', note: 'Ví dụ spec nhưng 5 bữa (có 2 bữa phụ)', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 30, height_cm: 177.8, weight_kg: 81.6 }), prefs: prefs({ slots: SLOTS_5, weekly_budget_vnd: 900_000 }) },
  { name: 'nu-nho-can-giam-mo', note: 'Nữ nhỏ cân, chạm trần 35% (~1.050–1.350 kcal)', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', sex: 'female', age: 40, height_cm: 158, weight_kg: 54, activity: 'light' }), prefs: prefs({ weekly_budget_vnd: 600_000 }) },
  { name: 'nam-tang-co-5-bua', note: 'Tăng cơ, 5 bữa, kcal cao', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'build', age: 25, height_cm: 175, weight_kg: 72, activity: 'high' }), prefs: prefs({ slots: SLOTS_5, weekly_budget_vnd: 1_200_000 }) },
  { name: 'nu-giu-can', note: 'Giữ cân, vận động nhẹ', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'hold', sex: 'female', age: 35, height_cm: 160, weight_kg: 58, activity: 'light' }), prefs: prefs({ weekly_budget_vnd: 700_000 }) },
  { name: 'chay-co-trung-sua', note: 'Chay (không thịt/cá), giảm mỡ', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', sex: 'female', age: 28, height_cm: 162, weight_kg: 62 }), prefs: prefs({ diet: 'vegetarian' }) },
  { name: 'thuan-chay', note: 'Thuần chay — khắt khe về protein', expect_all_days_pass: false, forbidden_ingredient_ids: [],
    profile: man({ goal: 'hold', age: 32, height_cm: 172, weight_kg: 68 }), prefs: prefs({ diet: 'vegan', weekly_budget_vnd: 700_000 }) },
  { name: 'chay-co-ca', note: 'Chay có cá (pescatarian)', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 34, height_cm: 168, weight_kg: 75 }), prefs: prefs({ diet: 'pescatarian' }) },
  { name: 'khat-khe-di-ung', note: 'Không lợn, không gluten, không lạc, không hải sản có vỏ, không trứng', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 38, height_cm: 172, weight_kg: 80 }),
    prefs: prefs({ exclusions: ['no_pork', 'no_gluten', 'no_peanut', 'no_shellfish', 'no_egg'], weekly_budget_vnd: 900_000 }) },
  { name: 'it-tinh-bot', note: 'Ít tinh bột (low-carb trưa/tối)', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 36, height_cm: 175, weight_kg: 85 }), prefs: prefs({ low_carb: true, weekly_budget_vnd: 900_000 }) },
  { name: 'gia-dinh-2-lon-1-be', note: 'Hộ 2 người lớn + 1 trẻ em', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 33, height_cm: 176, weight_kg: 82 }), prefs: prefs({ adults: 2, children: 1, weekly_budget_vnd: 1_800_000 }) },
  { name: 'chi-trua-toi-sang-tu-lo', note: 'Sáng tự lo, chỉ lên trưa + tối', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'hold', age: 29, height_cm: 170, weight_kg: 66 }), prefs: prefs({ slots: SLOTS_LD }) },
  { name: 'ngan-sach-thap', note: 'Ngân sách 350.000 ₫/tuần', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'hold', sex: 'female', age: 30, height_cm: 158, weight_kg: 52, activity: 'light' }), prefs: prefs({ weekly_budget_vnd: 350_000 }) },
  { name: 'chi-co-bep', note: 'Chỉ có bếp', expect_all_days_pass: true, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 31, height_cm: 170, weight_kg: 72 }), prefs: prefs({ equipment: ['bep'] }) },
  { name: 'cuc-ky-khat-khe', note: 'Thuần chay + không đậu nành + ít tinh bột', expect_all_days_pass: false, forbidden_ingredient_ids: [],
    profile: man({ goal: 'lose', age: 30, height_cm: 170, weight_kg: 70 }), prefs: prefs({ diet: 'vegan', exclusions: ['no_soy'], low_carb: true }) },
];
