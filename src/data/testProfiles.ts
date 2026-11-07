// Hồ sơ test (data/test-profiles.json, T-048): schema + chuyển sang dạng dùng cho engine-report. Thuần TS.
import { z } from 'zod';
import { PreferencesSchema, ProfileSchema, type Preferences, type Profile } from '../types/profile.ts';

export const TestProfileSchema = z.object({
  id: z.string().min(1),
  name: z.string(),
  note: z.string().default(''),
  profile: ProfileSchema,
  preferences: PreferencesSchema,
  expect: z.object({
    expect_all_days_pass: z.boolean(),
    forbidden_ingredient_ids: z.array(z.string()).default([]),
    note: z.string().default(''),
  }),
});
export type TestProfile = z.infer<typeof TestProfileSchema>;

export interface ReportProfile {
  name: string;
  note: string;
  profile: Profile;
  prefs: Preferences;
  /** Kỳ vọng: hồ sơ này nên đạt 7/7 trên bộ dữ liệu đủ tốt. */
  expect_all_days_pass: boolean;
  /** Nguyên liệu tuyệt đối không được xuất hiện (ràng buộc cứng của hồ sơ). */
  forbidden_ingredient_ids: string[];
}

export function parseTestProfiles(raw: unknown): ReportProfile[] {
  return z.array(TestProfileSchema).parse(raw).map((t) => ({
    name: t.id, note: `${t.name}${t.expect.note ? ' — ' + t.expect.note : ''}`,
    profile: t.profile, prefs: t.preferences,
    expect_all_days_pass: t.expect.expect_all_days_pass, forbidden_ingredient_ids: t.expect.forbidden_ingredient_ids,
  }));
}
