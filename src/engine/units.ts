// T-005 — Quy đổi gram → đơn vị bếp gần nhất ("≈ 1 thìa canh") từ household_units của nguyên liệu.
import type { Ingredient } from '../types/schema.ts';

export interface HouseholdQuantity {
  unit: string;
  count: number; // bội số của 0.5
  text: string; // "≈ 1 1/2 thìa canh"
}

const FRACTION = (n: number): string => {
  const whole = Math.floor(n);
  const half = n - whole >= 0.5;
  return whole === 0 ? '1/2' : half ? `${whole} 1/2` : `${whole}`;
};

/**
 * Chọn đơn vị cho số lượng làm tròn bội 0.5 sát gram thật nhất (sai số tương đối ≤ maxError, mặc định 15%),
 * ưu tiên số đếm gọn (< 10). Không có đơn vị phù hợp → null (UI chỉ hiện gram).
 */
export function toHouseholdUnit(
  grams: number, units: Ingredient['household_units'], maxError = 0.15,
): HouseholdQuantity | null {
  if (grams <= 0) return null;
  let best: { unit: string; count: number; err: number } | null = null;
  for (const u of units) {
    const raw = grams / u.grams;
    const count = Math.round(raw * 2) / 2;
    if (count < 0.5 || count >= 10) continue;
    const err = Math.abs(count * u.grams - grams) / grams;
    if (err > maxError) continue;
    if (!best || err < best.err - 1e-9 || (Math.abs(err - best.err) <= 1e-9 && count < best.count))
      best = { unit: u.unit, count, err };
  }
  return best && { unit: best.unit, count: best.count, text: `≈ ${FRACTION(best.count)} ${best.unit}` };
}
