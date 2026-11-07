// T-010 — Validator tuần (F-ENG-05, NFR-02): từng ngày protein ≥ sàn và kcal trong dải; chi phí ≤ ngân sách.
// Hàm thuần; không đọc I/O. Báo thiếu trung thực: không bao giờ ẩn ngày không đạt.

export interface DayTotals {
  date: string;
  /** Tổng protein/kcal của cả ngày (đã gồm phần dự kiến của bữa "tôi tự lo"). */
  protein_g: number;
  kcal: number;
  /** Ngày có bữa ăn ngoài/bỏ bữa (US-5.3): không tính là không đạt. */
  exempt?: boolean;
}

export interface WeekTargets {
  protein_g: number;
  kcal_min: number;
  kcal_max: number;
}

export type ShortfallKind = 'protein_low' | 'kcal_low' | 'kcal_high';

export interface Shortfall {
  date: string;
  kind: ShortfallKind;
  /** Mức thiếu/vượt (luôn dương): g protein hoặc kcal. */
  amount: number;
}

export interface DayValidation {
  date: string;
  ok: boolean;
  exempt: boolean;
  protein_short_g: number; // ≥ 0
  kcal_delta: number; // âm = dưới dải, dương = trên dải, 0 = trong dải
}

export interface WeekValidation {
  ok: boolean;
  days: DayValidation[];
  shortfalls: Shortfall[];
  /** Số ngày không đạt (không tính ngày exempt). */
  days_missing: number;
  /** Vượt ngân sách (₫), 0 nếu không vượt. */
  budget_over_vnd: number;
}

const EPS = 1e-6;

export function validateWeek(
  days: readonly DayTotals[], targets: WeekTargets, budget_vnd: number, week_food_cost: number,
): WeekValidation {
  const out: DayValidation[] = [];
  const shortfalls: Shortfall[] = [];
  for (const d of days) {
    const protein_short_g = Math.max(0, targets.protein_g - d.protein_g);
    const kcal_delta = d.kcal < targets.kcal_min ? d.kcal - targets.kcal_min : d.kcal > targets.kcal_max ? d.kcal - targets.kcal_max : 0;
    const bad = protein_short_g > EPS || Math.abs(kcal_delta) > EPS;
    out.push({ date: d.date, ok: !bad || !!d.exempt, exempt: !!d.exempt, protein_short_g, kcal_delta });
    if (bad && !d.exempt) {
      if (protein_short_g > EPS) shortfalls.push({ date: d.date, kind: 'protein_low', amount: protein_short_g });
      if (kcal_delta < -EPS) shortfalls.push({ date: d.date, kind: 'kcal_low', amount: -kcal_delta });
      if (kcal_delta > EPS) shortfalls.push({ date: d.date, kind: 'kcal_high', amount: kcal_delta });
    }
  }
  const days_missing = out.filter((d) => !d.ok).length;
  const budget_over_vnd = Math.max(0, week_food_cost - budget_vnd);
  return { ok: days_missing === 0 && budget_over_vnd === 0, days: out, shortfalls, days_missing, budget_over_vnd };
}
