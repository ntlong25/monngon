// T-052 — Xuất golden output của engine TS (bản tham chiếu) cho bản port C#.
// Hàm thuần: nhận dữ liệu + hồ sơ, trả về map đường-dẫn → nội dung văn bản. Cùng đầu vào → cùng từng byte.
import { createHash } from 'node:crypto';
import type { Dataset } from '../data/load.ts';
import type { ReportProfile } from '../data/testProfiles.ts';
import { allocateSlots } from '../engine/mealSlots.ts';
import { computeMacros, recipeBaseLines } from '../engine/nutrition.ts';
import { planWeek } from '../engine/planWeek.ts';
import { createRng, deriveSeed } from '../engine/rng.ts';
import { scaleRecipe } from '../engine/scale.ts';
import { calorieBand, computeTargets, mifflinStJeorBmr, referenceWeightKg } from '../engine/targets.ts';

export const GOLDEN_SEEDS = [1, 2, 3] as const;
export const GOLDEN_START_DATE = '2026-11-09';
export const RNG_SEEDS = [1, 42] as const;
export const RNG_COUNT = 1000;
export const DERIVE_SEEDS = [0, 1, 2, 3, 42, 4294967295] as const;
export const DERIVE_N = 16;
export const SCALE_TARGETS = [{ kcal: 450, protein_g: 30 }, { kcal: 600, protein_g: 45 }, { kcal: 800, protein_g: 60 }] as const;

/** JSON ổn định: khóa đối tượng sắp tăng dần, thụt 1 khoảng trắng, xuống dòng cuối file. */
export function stableStringify(value: unknown): string {
  const norm = (v: unknown): unknown => {
    if (Array.isArray(v)) return v.map(norm);
    if (v instanceof Map) return norm(Object.fromEntries(v));
    if (v instanceof Set) return norm([...v]);
    if (v && typeof v === 'object') {
      const o: Record<string, unknown> = {};
      for (const k of Object.keys(v).sort()) {
        const x = (v as Record<string, unknown>)[k];
        if (x !== undefined) o[k] = norm(x);
      }
      return o;
    }
    if (typeof v === 'number' && !Number.isFinite(v)) throw new Error('Golden không chấp nhận NaN/Infinity');
    return v;
  };
  return JSON.stringify(norm(value), null, 1) + '\n';
}

export const sha256 = (s: string | Uint8Array): string => createHash('sha256').update(s).digest('hex');

export interface DataFile { name: string; content: string }

/** Phiên bản dữ liệu = SHA-256 của (tên + NUL + nội dung + NUL) các file data/*.json theo thứ tự tên. */
export function dataVersion(files: readonly DataFile[]): { version: string; files: Record<string, string> } {
  const sorted = [...files].sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
  const h = createHash('sha256');
  const per: Record<string, string> = {};
  for (const f of sorted) {
    h.update(f.name + '\0' + f.content + '\0');
    per[f.name] = sha256(f.content);
  }
  return { version: h.digest('hex'), files: per };
}

const caseName = (profileId: string, seed: number) => `${profileId}.seed${seed}`;
const byId = <T extends { id: string }>(a: T, b: T) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0);

export interface GoldenInput {
  ds: Dataset;
  profiles: readonly ReportProfile[];
  dataFiles: readonly DataFile[];
  /** Ngày ghi trong README (cố định để đầu ra không đổi theo đồng hồ). */
  date: string;
}

export function buildGolden(input: GoldenInput): Map<string, string> {
  const { ds, profiles } = input;
  const out = new Map<string, string>();
  const put = (path: string, v: unknown) => out.set(path, stableStringify(v));
  const recipes = [...ds.recipes].sort(byId);

  put('vectors/rng.json', {
    algorithm: 'mulberry32',
    seeds: Object.fromEntries(RNG_SEEDS.map((s) => {
      const r = createRng(s);
      return [String(s), Array.from({ length: RNG_COUNT }, () => r())];
    })),
    derive_seed: DERIVE_SEEDS.map((seed) => ({ seed, values: Array.from({ length: DERIVE_N }, (_, n) => deriveSeed(seed, n)) })),
  });

  put('vectors/targets.json', {
    profiles: profiles.map((p) => ({
      id: p.name, profile: p.profile, targets: computeTargets(p.profile),
      bmr: p.profile.target_mode === 'manual' ? null : mifflinStJeorBmr(p.profile),
      reference_weight_kg: referenceWeightKg(p.profile),
    })),
    calorie_band: [1000, 1350, 1800, 2000, 2200, 2500, 2800, 3001].map((kcal) => ({
      kcal, default: calorieBand(kcal), legacy_minus5_0: calorieBand(kcal, { bandAbovePct: 0 }),
    })),
    // Mốc làm tròn .5 (Math.round của JS làm tròn lên +∞)
    js_round: [0.5, 1.5, 2.5, -0.5, -1.5, -2.5, 1417.5, 1282.5, 0.49999999999999994].map((x) => ({ x, round: Math.round(x) })),
  });

  put('vectors/slots.json', profiles.map((p) => ({
    id: p.name, slots_config: p.prefs.slots, slots: allocateSlots(computeTargets(p.profile), p.prefs.slots),
  })));

  put('vectors/nutrition.json', recipes.map((r) => ({ recipe_id: r.id, result: computeMacros(recipeBaseLines(r), ds.ingredientsById) })));

  put('vectors/scale.json', recipes.flatMap((r) =>
    SCALE_TARGETS.flatMap((target) => [false, true].map((forceZeroCarb) => ({
      recipe_id: r.id, target, force_zero_carb: forceZeroCarb,
      result: scaleRecipe(r, ds.ingredientsById, target, { forceZeroCarb }),
    })))));

  const caseFiles: string[] = [];
  for (const p of profiles) {
    for (const seed of GOLDEN_SEEDS) {
      const targets = computeTargets(p.profile);
      const plan = planWeek({ targets, prefs: p.prefs, data: ds, start_date: GOLDEN_START_DATE, seed });
      const name = `cases/${caseName(p.name, seed)}.json`;
      caseFiles.push(name);
      put(name, {
        id: caseName(p.name, seed),
        input: { profile: p.profile, preferences: p.prefs, targets, start_date: GOLDEN_START_DATE, seed, options: null },
        slots: allocateSlots(targets, p.prefs.slots),
        plan,
      });
    }
  }

  const dv = dataVersion(input.dataFiles);
  const hashes = [...out.entries()].sort(([a], [b]) => (a < b ? -1 : 1)).map(([k, v]) => [k, sha256(v)] as const);
  put('manifest.json', {
    format: 1,
    engine: 'ts-reference',
    data_version_sha256: dv.version,
    data_files_sha256: dv.files,
    start_date: GOLDEN_START_DATE,
    seeds: [...GOLDEN_SEEDS],
    profiles: profiles.map((p) => p.name),
    cases: caseFiles,
    content_sha256: Object.fromEntries(hashes),
  });

  out.set('README.md', readme(input.date, dv.version, caseFiles.length, profiles.length));
  return out;
}

function readme(date: string, version: string, nCases: number, nProfiles: number): string {
  return [
    '# golden/ — đầu ra tham chiếu của engine TypeScript (T-052)',
    '',
    'Bản port C# (T-062…T-064) phải khớp các file này. **Không sửa tay.** Tạo lại bằng:',
    '',
    '```',
    'npm run export-golden',
    '```',
    '',
    `- Ngày xuất: ${date} (cố định trong script; \`--date\` để đổi). Đầu ra không phụ thuộc đồng hồ: chạy lại cho ra file giống hệt từng byte.`,
    `- Phiên bản dữ liệu (SHA-256 của \`data/*.json\` theo tên file): \`${version}\`; chi tiết từng file ở \`manifest.json\`.`,
    '- Engine TS đã đóng băng: chỉ sửa lỗi, và khi sửa phải xuất lại golden.',
    '- JSON: khóa sắp tăng dần, thụt 1 khoảng trắng; số là double đúng như JS (macro so với sai số ≤ 1e-6, chi phí/gram khớp tuyệt đối).',
    '- Nếu Research đổi `data/`, `manifest.json` sẽ lệch phiên bản dữ liệu: chạy lại lệnh trên và báo PM.',
    '',
    '## Cấu trúc',
    '| Đường dẫn | Nội dung |',
    '|---|---|',
    '| `manifest.json` | phiên bản dữ liệu, danh sách ca, SHA-256 từng file |',
    '| `vectors/rng.json` | 1.000 giá trị đầu của mulberry32 với seed 1 và 42; `deriveSeed(seed, n)` cho n = 0…15 |',
    `| \`vectors/targets.json\` | \`computeTargets\` cho ${nProfiles} hồ sơ test, dải calo (±5% và −5%/0%), mốc làm tròn .5 của \`Math.round\` |`,
    '| `vectors/slots.json` | `allocateSlots` từng hồ sơ |',
    '| `vectors/nutrition.json` | macro chưa làm tròn của khẩu phần chuẩn từng công thức (có `source` từng dòng) |',
    '| `vectors/scale.json` | `scaleRecipe` mỗi công thức × 3 mục tiêu (450/30, 600/45, 800/60) × {thường, ép ít tinh bột} |',
    `| \`cases/<hồ sơ>.seed<N>.json\` | ${nCases} ca: đầu vào (hồ sơ, tùy chọn, chỉ tiêu, ngày bắt đầu, seed), \`slots\`, \`plan\` = \`WeekPlan\` đầy đủ (món, gram, macro, extras, substitutions, unfilled, validation/shortfall, shopping) |`,
    '',
    'Seed: 1, 2, 3 · ngày bắt đầu tuần: 2026-11-09 · tùy chọn engine: mặc định.',
    '',
  ].join('\n');
}
