// T-003 — Chỉ tiêu calo/protein theo spec mục 4.8. Hàm thuần, trả cả các bước trung gian để UI hiển thị.
import type { Activity, Goal, Profile } from '../types/profile.ts';

export const ACTIVITY_FACTOR: Record<Activity, number> = {
  sedentary: 1.2, light: 1.375, moderate: 1.55, high: 1.725, athlete: 1.9,
};
export const GOAL_KCAL_FACTOR: Record<Goal, number> = { lose: 0.8, hold: 1.0, build: 1.1 };
export const PROTEIN_G_PER_KG: Record<Goal, number> = { lose: 2.2, hold: 1.8, build: 2.0 };
export const PROTEIN_CAP_KCAL_SHARE = 0.35;
/** Sàn protein: giảm mỡ 1.76 g/kg cân tham chiếu; còn lại 1.2 g/kg cân thật. */
export const PROTEIN_FLOOR_G_PER_KG = { lose: 1.76, other: 1.2 } as const;

export interface TargetOptions {
  /** Dải calo lập tuần = [target × (1 − bandBelowPct), target × (1 + bandAbovePct)]. Mặc định ±5% (Q3). */
  bandBelowPct?: number;
  bandAbovePct?: number;
}

export interface Targets {
  mode: 'formula' | 'manual';
  kcal_target: number;
  kcal_min: number;
  kcal_max: number;
  /** Protein tối thiểu mỗi ngày mà validator đòi hỏi (đã áp trần/sàn). */
  protein_g: number;
  /** Các bước trung gian (null khi nhập tay). */
  steps: {
    bmr: number;
    activity_factor: number;
    tdee: number;
    goal_factor: number;
    kcal_unrounded: number;
    reference_weight_kg: number;
    protein_g_per_kg: number;
    protein_raw_g: number;
    protein_cap_g: number;
    protein_floor_g: number;
    /** Kết quả cuối do sàn thắng trần hay trần cắt xuống. */
    protein_limited_by: 'none' | 'cap' | 'floor';
  } | null;
}

export const roundTo = (x: number, step: number): number => Math.round(x / step) * step;
const floorTo = (x: number, step: number): number => Math.floor(x / step) * step;

export function mifflinStJeorBmr(p: Pick<Profile, 'sex' | 'age' | 'height_cm' | 'weight_kg'>): number {
  return 10 * p.weight_kg + 6.25 * p.height_cm - 5 * p.age + (p.sex === 'male' ? 5 : -161);
}

export function referenceWeightKg(p: Pick<Profile, 'goal' | 'height_cm' | 'weight_kg'>): number {
  if (p.goal !== 'lose') return p.weight_kg;
  const m = p.height_cm / 100;
  return Math.min(p.weight_kg, 25 * m * m);
}

export function calorieBand(kcal: number, opts: TargetOptions = {}): { kcal_min: number; kcal_max: number } {
  const below = opts.bandBelowPct ?? 0.05;
  const above = opts.bandAbovePct ?? 0.05;
  return { kcal_min: Math.round(kcal * (1 - below)), kcal_max: Math.round(kcal * (1 + above)) };
}

export function computeTargets(profile: Profile, opts: TargetOptions = {}): Targets {
  if (profile.target_mode === 'manual') {
    const { manual_kcal: kcal, manual_protein_g: protein } = profile;
    if (!kcal || !protein) throw new Error('Chế độ tự nhập cần manual_kcal và manual_protein_g');
    return { mode: 'manual', kcal_target: kcal, ...calorieBand(kcal, opts), protein_g: protein, steps: null };
  }

  const bmr = mifflinStJeorBmr(profile);
  const activity_factor = ACTIVITY_FACTOR[profile.activity];
  const tdee = bmr * activity_factor;
  const goal_factor = GOAL_KCAL_FACTOR[profile.goal];
  const kcal_unrounded = tdee * goal_factor;
  const kcal_target = roundTo(kcal_unrounded, 50);

  const reference_weight_kg = referenceWeightKg(profile);
  const protein_g_per_kg = PROTEIN_G_PER_KG[profile.goal];
  const protein_raw_g = roundTo(protein_g_per_kg * reference_weight_kg, 5);
  const protein_cap_g = floorTo((PROTEIN_CAP_KCAL_SHARE * kcal_target) / 4, 5);
  const floorPerKg = profile.goal === 'lose' ? PROTEIN_FLOOR_G_PER_KG.lose : PROTEIN_FLOOR_G_PER_KG.other;
  const protein_floor_g = Math.round(floorPerKg * (profile.goal === 'lose' ? reference_weight_kg : profile.weight_kg));

  // Sàn thắng trần: max(sàn, min(mục tiêu, trần)).
  const capped = Math.min(protein_raw_g, protein_cap_g);
  const protein_g = Math.max(protein_floor_g, capped);
  const protein_limited_by = protein_floor_g > capped ? 'floor' : capped < protein_raw_g ? 'cap' : 'none';

  return {
    mode: 'formula',
    kcal_target,
    ...calorieBand(kcal_target, opts),
    protein_g,
    steps: {
      bmr, activity_factor, tdee, goal_factor, kcal_unrounded, reference_weight_kg, protein_g_per_kg,
      protein_raw_g, protein_cap_g, protein_floor_g, protein_limited_by,
    },
  };
}
