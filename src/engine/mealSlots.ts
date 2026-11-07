// T-004 — Phân bổ chỉ tiêu theo bữa (PRD §6.2: trưa 35, tối 35, sáng 20, phụ 5/5; chuẩn hóa theo bữa được giữ phần).
import { SLOTS, type Slot, type SlotMode, type SlotsConfig } from '../types/profile.ts';
import type { Targets } from './targets.ts';

export const DEFAULT_SLOT_SHARES: Record<Slot, number> = {
  breakfast: 0.2, lunch: 0.35, dinner: 0.35, snack_am: 0.05, snack_pm: 0.05,
};
export const MAIN_SLOTS: readonly Slot[] = ['breakfast', 'lunch', 'dinner'];

export interface SlotTarget {
  slot: Slot;
  mode: SlotMode;
  /** Tỉ lệ đã chuẩn hóa trong ngày (0 nếu skip). */
  share: number;
  kcal: number;
  protein_g: number;
  /** Chỉ `on` mới lên món; `self` giữ phần chỉ tiêu nhưng không có món. */
  planned: boolean;
}

export class NoMainMealError extends Error {
  constructor() {
    super('Cần ít nhất 1 bữa chính (sáng/trưa/tối) ở chế độ "Lên thực đơn"');
    this.name = 'NoMainMealError';
  }
}

export function allocateSlots(
  targets: Pick<Targets, 'kcal_target' | 'protein_g'>,
  cfg: Pick<SlotsConfig, Slot>,
  shares: Record<Slot, number> = DEFAULT_SLOT_SHARES,
): SlotTarget[] {
  if (!MAIN_SLOTS.some((s) => cfg[s] === 'on')) throw new NoMainMealError();
  const total = SLOTS.reduce((a, s) => a + (cfg[s] === 'skip' ? 0 : shares[s]), 0);
  return SLOTS.map((slot) => {
    const mode = cfg[slot];
    const share = mode === 'skip' ? 0 : shares[slot] / total;
    return {
      slot, mode, share,
      kcal: targets.kcal_target * share,
      protein_g: targets.protein_g * share,
      planned: mode === 'on',
    };
  });
}
