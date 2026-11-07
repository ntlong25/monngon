// PRNG có seed (mulberry32) — để lập tuần tất định.
export type Rng = () => number;

export function createRng(seed: number): Rng {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Trộn seed gốc với số vòng để mỗi vòng thử có chuỗi ngẫu nhiên riêng nhưng vẫn tất định. */
export const deriveSeed = (seed: number, n: number): number => Math.imul((seed ^ Math.imul(n + 1, 0x9e3779b1)) >>> 0, 0x85ebca6b) >>> 0;
