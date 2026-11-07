// T-008 — Chấm điểm mềm công thức (cao hơn = tốt hơn). Chỉ là ưu tiên mềm, xếp sau ràng buộc cứng/chỉ tiêu (F-ENG-07).
import type { Recipe } from '../types/schema.ts';

export interface ScoreWeights {
  cuisineLike: number; // mỗi thẻ cuisine khớp "thích"
  cuisineLess: number; // mỗi thẻ cuisine khớp "ít hơn" (trừ điểm)
  healthLeaning: number; // mỗi thẻ sức khỏe khớp xu hướng
  /** Điểm tối đa/thiểu của thành phần chi phí: rẻ hơn tham chiếu → cộng, đắt hơn → trừ (kẹp ở ±cost). */
  cost: number;
  /** Phạt mỗi lần dùng vượt `freeUses` trong tuần. */
  repeatOverUse: number;
  /** Số lần dùng không bị phạt (nấu 1 lần ăn 2 bữa = 2). */
  freeUses: number;
  /** Phạt khi cùng ngày đã có đúng món này (PRD US-2.3 AC3). */
  sameDay: number;
  /** Phạt mỗi bữa gần đây (trong `monotonyWindow`) có cùng nguyên liệu protein chính. */
  monotony: number;
  monotonyWindow: number;
}

export const DEFAULT_SCORE_WEIGHTS: ScoreWeights = {
  cuisineLike: 2,
  cuisineLess: 2,
  healthLeaning: 1,
  cost: 2,
  repeatOverUse: 3,
  freeUses: 2,
  sameDay: 10,
  monotony: 1.5,
  monotonyWindow: 3,
};

export interface ScoreContext {
  cuisine_likes: readonly string[];
  cuisine_less: readonly string[];
  health_leanings: readonly string[];
  /** Chi phí ước tính của suất này (₫) và mức tham chiếu (vd ngân sách/số bữa). */
  cost_vnd: number;
  cost_reference_vnd: number;
  /** Số lần công thức này đã dùng trong tuần. */
  uses_this_week: number;
  /** Công thức đã có trong cùng ngày. */
  same_day_recipe_ids: readonly string[];
  /** Protein chính của các bữa gần nhất (mới nhất ở cuối). */
  recent_main_proteins: readonly string[];
}

export interface ScoreBreakdown {
  total: number;
  likes: number;
  less: number;
  health: number;
  cost: number;
  repeat: number;
  sameDay: number;
  monotony: number;
}

/** Nguyên liệu protein chính = nguyên liệu vai trò protein nhiều gram nhất. */
export function mainProteinId(r: Recipe): string | null {
  let best: { id: string; g: number } | null = null;
  for (const li of r.ingredients) if (li.role === 'protein' && (!best || li.grams > best.g)) best = { id: li.ingredient_id, g: li.grams };
  return best?.id ?? null;
}

const count = (tags: readonly string[], wanted: readonly string[]) => tags.filter((t) => wanted.includes(t)).length;

export function scoreRecipe(r: Recipe, ctx: ScoreContext, w: ScoreWeights = DEFAULT_SCORE_WEIGHTS): ScoreBreakdown {
  const likes = w.cuisineLike * count(r.cuisine_tags, ctx.cuisine_likes);
  const less = -w.cuisineLess * count(r.cuisine_tags, ctx.cuisine_less);
  const health = w.healthLeaning * count(r.health_tags, ctx.health_leanings);

  const ratio = ctx.cost_reference_vnd > 0 ? ctx.cost_vnd / ctx.cost_reference_vnd : 1;
  const cost = -w.cost * Math.max(-1, Math.min(1, ratio - 1));

  const repeat = -w.repeatOverUse * Math.max(0, ctx.uses_this_week - w.freeUses);
  const sameDay = ctx.same_day_recipe_ids.includes(r.id) ? -w.sameDay : 0;

  const mp = mainProteinId(r);
  const window = ctx.recent_main_proteins.slice(-w.monotonyWindow);
  const monotony = mp ? -w.monotony * window.filter((p) => p === mp).length : 0;

  return { total: likes + less + health + cost + repeat + sameDay + monotony, likes, less, health, cost, repeat, sameDay, monotony };
}

/** Xếp giảm dần theo điểm; hòa thì theo id để tất định. */
export function rankRecipes<T extends { recipe: Recipe }>(
  items: readonly T[], ctxFor: (r: Recipe) => ScoreContext, w: ScoreWeights = DEFAULT_SCORE_WEIGHTS,
): (T & { score: ScoreBreakdown })[] {
  return items
    .map((it) => ({ ...it, score: scoreRecipe(it.recipe, ctxFor(it.recipe), w) }))
    .sort((a, b) => b.score.total - a.score.total || a.recipe.id.localeCompare(b.recipe.id));
}
