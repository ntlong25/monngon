# Backlog MVP — FitPro - Mâm đủ

> **v0.2 · 2026-11-06 · PM.** Đi kèm [prd.md](prd.md) (quyết định ở §10) và [adr-001-engine-location.md](adr-001-engine-location.md).
> **Thay đổi so với v0.1:** stack đổi thành **Flutter (mobile) + ASP.NET Core .NET 10 (API + engine C#)**, web ReactJS để sau. Task UI Expo (T-001, T-013…T-028) **bị hủy** và thay bằng task backend T-060…T-069 và Flutter T-080…T-093. Engine TS (T-002…T-012) đã xong; nó trở thành **bản tham chiếu và đóng băng** sau T-051/T-052. Dải calo ±5%. Ghép mâm (hợp đồng dữ liệu v0.2). Ảnh placeholder. T-029 viết lại thành freemium.

## Quy ước
- **Owner:** `DEV` hoặc `RESEARCH`. **Ưu tiên:** P0 (bắt buộc cho MVP) · P1 (MVP đầy đủ) · P2 (sau MVP).
- **Trạng thái:** `TODO` · `DONE` · `CANCELLED` · `PARTIAL` (có sản phẩm, còn việc). Session nhận task báo session chính khi xong, kèm đường dẫn file + cách kiểm. Session chính chịu trách nhiệm giao task.
- **Quyền ghi file** (PRD §6.4): DEV ghi `src/`, `golden/`, `backend/`, `mobile/`, `web/`, `docs/dev/`, cấu hình gốc. RESEARCH ghi `data/`, `content/`, `docs/research/`, `docs/qa/`. PM ghi `docs/pm/`.
- **Done chung (DEV):**
  - Backend: `dotnet build` không cảnh báo mới; `dotnet test` xanh.
  - Mobile: `flutter analyze` sạch; `flutter test` xanh; không hard-code chuỗi UI (dùng ARB `vi`).
  - Engine TS: `npm test` xanh.
- **Done chung (RESEARCH):** dữ liệu qua `npm run validate-data` (sau T-061 qua cả bản .NET); mọi số liệu có nguồn.

## Thứ tự làm cho DEV (tuần tự)

| # | Task | Ghi chú |
|---|---|---|
| 1 | T-051 | Dải calo ±5% trong engine TS, chạy lại engine-report làm baseline |
| 2 | T-052 | Xuất golden output từ TS, đóng băng TS |
| 3 | T-060 | Khung solution .NET |
| 4 | T-061 | Model + nạp + validate dữ liệu (C#) |
| 5 | T-062 | Port targets, mealSlots, nutrition, units |
| 6 | T-063 | Port rng, filter, scale, score, shopping |
| 7 | T-064 | Port planWeek + validate + **golden parity** + engine-report C# |
| 8 | T-065 | API v1 + OpenAPI |
| 9 | T-066 | Ghép mâm (engine C#) |
| 8b | T-071 | Tráng miệng trưa/tối (D-DES-01): **gộp vào T-066 nếu chưa chốt**, nếu không thì làm ngay sau T-066 |
| 9a | T-070 | Bổ sung API cho màn Flutter (P0, **phải xong trước T-087**; phần schema số nên làm ngay vì ảnh hưởng client Dart ở T-080) |
| 9b | T-069 | DONE (ước tính theo D-BUD-02) |
| 9c | T-072 | Hoàn thiện budget-range theo D-BUD-02 (việc nhỏ) |
| 9c2 | T-076 | Xu hướng không làm rớt chỉ tiêu cứng (P0, D-HLT-02) |
| 9c3 | T-077 | Nâng tỉ lệ ghép mâm khi ngân sách eo hẹp (P1, sau khi có canh/rau rẻ từ T-053) |
| 9c4 | T-078 | Đi chợ: nhà có sẵn + quy cơm ra gạo (P0; phần pantry làm ngay, phần gạo chờ T-042c) |
| 9d | T-073 | Danh sách trắng xu hướng sức khỏe (việc nhỏ, P1) |
| 9e | T-074 | Chuyển nguồn chuỗi sang `content/i18n/vi.json` (ngay khi Research xong T-055) |
| — | T-075 | Làm sạch schema `budget-range` (P2) |
| 10 | T-080 | Khung Flutter (cần Flutter SDK, xem PRD §9.5) |
| 11 | T-081 → T-089 | Flutter: design system → state/API → onboarding → Kế hoạch → công thức → đi chợ |
| 12 | T-067 | Engine: đổi món, đổi nguyên liệu, ăn ngoài, lên lại (C#) |
| 13 | T-090 → T-093 | Flutter: thay đổi tuần, Tab Bạn, hoàn thiện |
| 14 | T-068 | Docker + hướng dẫn chạy/triển khai |
| — | T-029, T-100 | P2: freemium, web ReactJS |

Có thể song song nếu sau này có 2 dev: Flutter T-080…T-084 bắt đầu ngay sau T-065 (chỉ cần OpenAPI), song song với T-066.

## Thứ tự cho RESEARCH
**T-056 phần kiểm tra tên (làm sớm, việc nhỏ)** → **T-058 (tráng miệng, lô đầu ~8 món càng sớm càng tốt)** → **T-055 (i18n chính thức — Dev đang chờ)** → **T-059 (thẻ sức khỏe)** → **T-042c (gạo sống, việc nhỏ)** → T-053 (món phụ cho ghép mâm) → T-054 (bổ sung dữ liệu theo engine-report) → T-042b (giá theo cửa hàng) → T-057 (kịch bản test) → T-056 phần giá → T-050 (kiểm thử chấp nhận).

---

## Hợp đồng dữ liệu (v0.2)

Giữ nguyên v0.1 (đã hiện thực ở `src/types/schema.ts`), **cộng thêm** các điểm sau. Mọi điểm mới đều tương thích ngược: dữ liệu cũ không có trường mới vẫn hợp lệ.

Nhắc lại v0.1 (rút gọn; chi tiết xem `src/types/schema.ts` và `docs/dev/engine-notes.md`):
- `data/ingredients.json`: `id`, `name`, `aliases`, `aisle`, `per_100g {kcal, protein_g, carb_g, fat_g, fiber_g}`, `source {db: VN_FCT_2007|USDA_FDC, code, note}`, `allergen_tags`, `diet_tags`, `household_units`, `edible_portion`, `default_pantry`.
- `data/recipes.json`: `id`, `name`, `meal_types`, `lunch_style`, `snack_style`, `cuisine_tags`, `health_tags`, `equipment`, `cook_minutes`, `batchable`, `is_low_carb`, `ingredients [{ingredient_id, grams, role, min_g, max_g, swap_group}]`, `steps`, `image`. `grams` = gram **ăn được** của 1 khẩu phần chuẩn.
- `data/stores.json`, `data/prices.json` (`pack_g`, `price_vnd`, `shelf_life_days`, `source_url`, `surveyed_on`; bắt buộc có `cho_khac`), `data/test-profiles.json`.

**Mới ở v0.2 (ghép mâm, Q4):**
```json
{
  "id": "canh_cai_ngot_thit_bam",
  "name": "Canh cải ngọt thịt băm",
  "dish_role": "soup",
  "meal_types": ["lunch", "dinner"],
  "pairs_with": ["kho", "rang", "xao"],
  "ingredients": [ { "ingredient_id": "cai_ngot", "grams": 100, "role": "veg", "min_g": 100, "max_g": 100, "swap_group": "rau_canh" } ]
}
```
- `dish_role` ∈ `full_meal | main | soup | side_veg | carb_base`. **Mặc định `full_meal`** nếu thiếu (137 công thức hiện có giữ nguyên).
  - `full_meal`: trọn suất (có thể đã gồm cơm), dùng cho mọi bữa.
  - `main`: món mặn **không gồm cơm**, chỉ trưa/tối, có ≥ 1 dòng `role: protein`.
  - `soup` (canh), `side_veg` (rau luộc/xào/nộm): chỉ trưa/tối, gram cố định hoặc biên hẹp. Món phụ được phép có đạm nhẹ (vd canh thịt băm).
  - `carb_base`: cơm trắng, cơm gạo lứt, bún… dòng `role: carb` có biên rộng (vd 0–300 g) để engine scale.
- `pairs_with` (tùy chọn): danh sách `cuisine_tags` của món chính hợp với món phụ này. Đây là điểm mềm, không phải ràng buộc.
- **Quy tắc mâm** (engine C#, T-066): trưa/tối = `full_meal` **hoặc** `main` + 0–1 `soup` + 0–1 `side_veg` + 0–1 `carb_base` (bắt buộc 0 nếu Ít tinh bột). Chỉ tiêu bữa tính trên **tổng mâm**. Danh sách đi chợ gộp mọi món của mâm. Ràng buộc cứng áp cho **từng món** trong mâm.
- **Tráng miệng (D-DES-01):** thêm `dish_role: "dessert"`.
  - `meal_types` gồm `lunch`, `dinner` (có thể thêm `snack_*` để dùng lại làm bữa phụ).
  - Cờ mới, chỉ có nghĩa với dessert, mặc định `false`: `portable` (mang đi được) và `low_carb_ok` (dùng được khi Ít tinh bột).
  - Dòng nguyên liệu chính có `role: "carb"` hoặc `"fat"`… tùy món, nhưng được engine scale trong [`min_g`, `max_g`] hẹp (vd chuối 100–150 g).
  - `household_units` của nguyên liệu tráng miệng phải có đơn vị mua ("quả", "hộp 180 ml") để hiển thị.
  - `steps` 1–3 bước ("Rửa, gọt, cắt miếng").
  - Quy tắc mâm cập nhật: trưa/tối = (`full_meal` **hoặc** mâm) **+ đúng 1 `dessert`**. Không có ứng viên thì `dessert_missing`.
- **Quy đổi khi mua (D-SHP-02):** nguyên liệu có thể có `purchase_as: { "ingredient_id": "gao_te", "factor": 0.36 }`, nghĩa là 1 g nguyên liệu này cần `factor` g nguyên liệu đích khi đi chợ. Chỉ ảnh hưởng danh sách đi chợ và chi phí; dinh dưỡng vẫn tính theo nguyên liệu gốc.
- `image`: luôn `null` ở MVP (Q5). Ảnh do người dùng cung cấp sau, theo quy ước `assets/recipes/<recipe_id>.jpg`.

**Dải calo (Q3):** `kcal_band = [target × 0.95, target × 1.05]`; protein là sàn.

---

## Task DEV

### Đã xong (engine TS, nay là bản tham chiếu)
| Task | Trạng thái | Ghi chú |
|---|---|---|
| T-002 Schema + nạp + validate | DONE | `src/types/`, `src/data/` |
| T-003 Chỉ tiêu | DONE | `src/engine/targets.ts` |
| T-004 Phân bổ bữa | DONE | `mealSlots.ts` |
| T-005 Macro + trace + đơn vị bếp | DONE | `nutrition.ts`, `units.ts` |
| T-006 Lọc cứng | DONE | `filter.ts` (đối chiếu `allergen-rules.md`) |
| T-007 Scale | DONE | `scale.ts` |
| T-008 Chấm điểm | DONE | `score.ts` |
| T-009 Chi phí + đi chợ | DONE | `shopping.ts` |
| T-010 Lập tuần + validator | DONE | `planWeek.ts`, `validate.ts`; có món phụ `extras`, `polishDay`, `unfilled_slots` |
| T-011 Test chất lượng / engine-report | DONE | `docs/dev/engine-report-final.md`: 12/14 hồ sơ đạt 7/7, 0 vi phạm cứng, 166 test |
| T-012 Store | DONE (không dùng nữa) | `src/store/` viết cho Expo; Flutter sẽ làm lại ở T-082 |

### Hủy (stack Expo)
T-001 (khởi tạo Expo), T-013…T-028 (UI Expo): **CANCELLED**, thay bằng T-080…T-093. Acceptance criteria của từng màn vẫn lấy theo user story trong PRD.

### T-051 — Dải calo ±5% + baseline engine-report · DEV · P0
- **Mô tả:** Đổi mặc định `bandAbovePct` thành `0.05` trong `src/engine/targets.ts`, kiểm mọi chỗ khác giả định trần = mục tiêu (`validate.ts`, `scale.ts`, `planWeek.ts`, report). Cập nhật test. Chạy `npm run engine-report` và lưu thành `docs/dev/engine-report-v1-baseline.md`.
- **Phụ thuộc:** không.
- **AC:** `npm test` xanh. Có test dải [0,95; 1,05] với ví dụ 2.200 kcal → [2.090; 2.310]. Báo cáo baseline ghi số hồ sơ đạt, ngày đạt, vi phạm cứng (phải là 0) và so sánh với bản −5%/0%.

### T-052 — Golden output + đóng băng engine TS · DEV · P0
- **Mô tả:** Script `npm run export-golden` ghi ra `golden/`. Với mỗi hồ sơ trong `data/test-profiles.json` × seed {1, 2, 3}: đầu vào, `targets`, phân bổ slot, `WeekPlan` đầy đủ (món, gram, macro chưa làm tròn, extras, substitutions, shortfalls) và danh sách đi chợ. Thêm vector nhỏ cho từng hàm thuần (targets, scale, rng 1.000 giá trị đầu từ seed 1 và 42, deriveSeed). Ghi `golden/README.md` (phiên bản dữ liệu = hash SHA-256 của `data/*.json`, ngày, lệnh tạo lại). Ghi chú "TS đóng băng" vào `docs/dev/engine-notes.md`.
- **Phụ thuộc:** T-051.
- **AC:** Chạy lại hai lần ra file giống hệt từng byte. JSON được sắp khóa ổn định. Kích thước hợp lý (< 20 MB). Từ đây không sửa logic `src/engine/`; chỉ sửa lỗi nếu có và khi đó phải xuất lại golden.

### T-060 — Khung solution .NET · DEV · P0
- **Mô tả:** Tạo `backend/MonNgon.sln` (.NET 10) gồm: `MonNgon.Engine` (class library, không phụ thuộc ASP.NET), `MonNgon.Api` (Minimal API), `MonNgon.Engine.Tests` + `MonNgon.Api.Tests` (xUnit). Bật `Nullable`, `TreatWarningsAsErrors`, `.editorconfig`. Thêm `backend/README.md` (build/test/run). Khởi tạo git cho repo nếu chưa có (`.gitignore` cho node/dotnet/flutter).
- **Phụ thuộc:** không (song song T-051 được).
- **AC:** `dotnet build` và `dotnet test` xanh với 1 test mẫu. `dotnet run --project backend/MonNgon.Api` trả `GET /health` 200.

### T-061 — Model, nạp và validate dữ liệu (C#) · DEV · P0
- **Mô tả:** Record C# cho hợp đồng dữ liệu v0.2 (gồm `dish_role`, `pairs_with`), dùng `System.Text.Json` snake_case. `DataStore` nạp `data/*.json` khi khởi động và lập index. Port **mọi quy tắc** của `src/data/validate.ts`. Thêm lệnh `dotnet run --project backend/MonNgon.Tools -- validate-data [dir]`.
- **Phụ thuộc:** T-060.
- **AC:** Kết quả validate trên `data/` và `src/engine/__fixtures__/` giống bản TS (cùng lỗi/cảnh báo). Port test của `validate.test.ts`. API không khởi động được nếu dữ liệu lỗi, và log chỉ rõ file + id + trường.

### T-062 — Port targets, mealSlots, nutrition, units · DEV · P0
- **Phụ thuộc:** T-061, T-052.
- **AC:** Port 1-1 test TS tương ứng. Khớp vector golden của từng hàm. Làm tròn dùng helper `JsRound` (tương đương `Math.round` JS, có test với .5 và số âm). Không dùng `Math.Round` mặc định.

### T-063 — Port rng, filter, scale, score, shopping · DEV · P0
- **Phụ thuộc:** T-062.
- **AC:**
  - `Mulberry32` dùng `uint`/`unchecked`; 1.000 giá trị đầu khớp golden tuyệt đối; `DeriveSeed` cũng khớp.
  - Sort ổn định: dùng `OrderBy`/`ThenBy`, không dùng `List.Sort` khi có khóa bằng nhau.
  - Thứ tự duyệt tập hợp giữ như TS.
  - Port test tương ứng.

### T-064 — Port planWeek + validator + golden parity · DEV · P0
- **Mô tả:** Port `planWeek.ts` (gồm `refineDay`, `addExtras`, `polishDay`, `repairs`, `unfilled`) và `validate.ts`. Test parity duyệt toàn bộ `golden/`. Port `engine-report` sang lệnh `MonNgon.Tools engine-report`, xuất cùng định dạng markdown.
- **Phụ thuộc:** T-063.
- **AC:**
  - 100% ca golden: cùng `recipe_id` từng slot, cùng gram, cùng extras/substitutions, cùng trạng thái/shortfall.
  - Macro sai số ≤ 1e-6. Chi phí khớp tuyệt đối.
  - Engine-report C# trùng số liệu với `engine-report-v1-baseline.md`.
  - Port test của `planWeek.test.ts` và `profiles.test.ts`.
  - Thời gian một tuần ≤ 200 ms (p95) trên máy dev.
  - Nếu lệch, ghi nguyên nhân vào `docs/dev/port-notes.md`. Chỉ được chấp nhận lệch khi PM đồng ý qua session chính.

### T-065 — API v1 + OpenAPI · DEV · P0
- **Mô tả:** Endpoint stateless, JSON snake_case, lỗi theo RFC 7807, có CORS cho dev:
  - `GET /v1/reference`: cửa hàng, dụng cụ, lựa chọn kiêng/loại trừ, thẻ vuốt, phiên bản dữ liệu.
  - `GET /v1/ingredients?q=`: tìm không dấu, phục vụ ô "không muốn thấy".
  - `POST /v1/targets`: chỉ tiêu + các bước trung gian.
  - `POST /v1/slots/preview`: phân bổ theo bữa.
  - `POST /v1/budget-range`.
  - `POST /v1/plans`: tạo tuần, đầu vào là hồ sơ + lựa chọn + `start_date` + `seed`; đầu ra là `WeekPlan` + danh sách đi chợ + trace "Cách chúng mình tính".
  - `GET /v1/recipes/{id}`.

  Xuất `openapi.json` vào `backend/openapi/` để sinh client.
- **Phụ thuộc:** T-064.
- **AC:** Test tích hợp (`WebApplicationFactory`) cho từng endpoint. `POST /v1/plans` với hồ sơ p01 ra đúng kết quả golden. Đầu vào sai thì trả 400 kèm trường lỗi. `openapi.json` sinh được client Dart không lỗi.

### T-066 — Ghép mâm (engine C#) · DEV · P0
- **Mô tả:** Theo quy tắc mâm trong hợp đồng v0.2. Chọn món chính như cũ, sau đó chọn canh/rau theo điểm (`pairs_with`, đa dạng rau trong tuần, chi phí) và scale `carb_base` cùng `protein` của món chính cho khớp chỉ tiêu tổng mâm. `full_meal` vẫn là ứng viên. Thay `extras` cơm bằng `carb_base` khi có dữ liệu. Giữ `extras` đạm làm phương án cuối. `PlanMeal` có `dishes[]` (role, recipe_id, gram, macro) và `macros` tổng. Đi chợ gộp mọi món. Tham số `meal_style`: `auto` (mặc định) | `full_meal_only` | `mam_only`.
- **Phụ thuộc:** T-064, T-065; dữ liệu T-053 (trước đó dùng fixture tự viết vài món phụ).
- **AC:**
  - Golden parity vẫn đạt với `meal_style=full_meal_only` (không hồi quy).
  - Với dữ liệu T-053: ≥ 60% bữa trưa/tối là mâm có ≥ 2 món; 0 vi phạm ràng buộc cứng.
  - Tỉ lệ đạt hồ sơ ≥ baseline.
  - Không có 2 món đạm chính trong một mâm.
  - Canh không lặp quá 2 lần/tuần.
  - Engine-report thêm cột "% bữa ghép mâm".

### T-071 — Món tráng miệng ở bữa trưa/tối (D-DES-01) · DEV · P0
- **Ghi chú giao việc:** nếu Dev chưa chốt T-066 thì **gộp luôn vào T-066** (cùng chỗ `dishes[]`), và AC dưới đây thành AC bổ sung của T-066. Nếu T-066 đã xong thì làm ngay sau T-066, trước T-070.
- **Mô tả:** Theo PRD §10 D-DES-01.
  - Đọc `dish_role: dessert`, `portable`, `low_carb_ok` (cập nhật model + validate-data C#; nếu cần thì cả schema TS nhưng không sửa logic TS đã đóng băng).
  - Với mỗi bữa trưa/tối được lên thực đơn: trừ trước phần kcal dự kiến của tráng miệng, chọn món chính/mâm như cũ, rồi chọn 1 dessert theo điểm. Điểm gồm: hợp lệ cứng, `portable` nếu trưa mang đi, `low_carb_ok` nếu Ít tinh bột, không lặp trong ngày, đa dạng trong tuần, hạn dùng hợp vị trí ngày, chi phí, xu hướng tiểu đường.
  - Dùng gram dessert trong biên làm núm tinh chỉnh ở `refineDay`/`polishDay`.
  - `PlanMeal.dishes[]` có phần tử `role: dessert`. Thêm cờ `dessert_missing` khi không có ứng viên.
  - Danh sách đi chợ gộp dessert. `ShoppingItem` thêm `display_qty` (vd "3 quả", "1 lốc") suy từ `pack_label`/`household_units`.
  - Engine-report thêm cột "% bữa có tráng miệng".
  - Tham số `include_dessert` (mặc định `true`; `false` để chạy golden parity).
- **Phụ thuộc:** T-066 (hoặc gộp vào); dữ liệu T-058. Trước khi có dữ liệu thì dùng fixture tự viết khoảng 5 món (chuối, cam, sữa chua không đường, sữa đậu nành, chè đậu xanh).
- **AC:**
  - Golden parity vẫn đạt với `include_dessert=false` + `meal_style=full_meal_only`.
  - Với dữ liệu T-058: 100% bữa trưa/tối được lên thực đơn có đúng 1 dessert, hoặc có `dessert_missing` kèm lý do.
  - 0 vi phạm ràng buộc cứng. Test riêng: thuần chay → không sữa bò; không sữa; ít tinh bột → chỉ `low_carb_ok`; trưa mang đi → chỉ `portable`.
  - Không trùng dessert trong cùng ngày. ≥ 3 dessert khác nhau/tuần khi có ≥ 3 ứng viên.
  - Tỉ lệ hồ sơ đạt 7/7 không thấp hơn kết quả T-066 quá 1 hồ sơ; nếu thấp hơn thì ghi nguyên nhân vào `docs/dev/`.
  - Dải ±5% và sàn protein tính trên tổng có dessert.

### T-072 — Hoàn thiện budget-range theo D-BUD-02 · DEV · P0 (việc nhỏ, trước T-084)
- **Mô tả:** Theo PRD §10 D-BUD-02. Giữ cách ước tính bằng mô phỏng engine, thêm:
  - kẹp `estimate_vnd` vào [min, max];
  - cache trong bộ nhớ theo hash đầu vào + `data_version`;
  - ước tính gồm tráng miệng (`include_dessert` mặc định);
  - thay test ±15% bằng tiêu chí mới;
  - viết `docs/dev/budget-range-check.md` (mỗi hồ sơ: min, ước tính, max, chi phí thật khi ngân sách = min và = ước tính, có vượt không).
- **Phụ thuộc:** T-069, T-071.
- **AC:**
  - `min ≤ estimate ≤ max` với mọi hồ sơ (có test).
  - Ngân sách = ước tính: ≥ 90% hồ sơ không vượt, và chi phí thật ≥ 70% ước tính.
  - Ngân sách = min: ≥ 90% hồ sơ không vượt (giữ từ T-069).
  - p95 ≤ 300 ms khi chưa có cache, ≤ 20 ms khi trúng cache.
  - Chạy lại sau khi có dữ liệu T-058 và cập nhật bảng.

### T-069 — Sửa công thức khoảng ngân sách (D-BUD-01) · DEV · P0 · **DONE** (ước tính đổi theo D-BUD-02, phần còn lại ở T-072)
- **Mô tả:** Sửa `BudgetEstimator` và `POST /v1/budget-range` theo PRD §10, D-BUD-01:
  - Request thêm `targets` (bắt buộc: `kcal_target`, `protein_g`) và `preferences` (tùy chọn; có thì lọc món theo kiêng/ghét/dụng cụ trước khi tính).
  - Chi phí theo slot dùng món đã scale theo chỉ tiêu slot. Người khác trong nhà tính bằng khẩu phần chuẩn × hệ số.
  - Ước tính = trung vị.
  - Min = phân vị 20% × 7 × 1,10, làm tròn lên.
  - Max = max(ước tính × 2,5; min + 500.000), làm tròn lên. Bước 50.000.
  - Bậc trả `key` (`economy | moderate | comfortable`) kèm `from_vnd`/`to_vnd`. Bỏ nhãn tiếng Việt khỏi API.
  - Response thêm `basis: "week_food_cost"` để UI ghi rõ đây là chi phí món ăn, không phải tiền trả tại quầy.
- **Phụ thuộc:** T-065.
- **AC:**
  - Test: với mọi hồ sơ trong `data/test-profiles.json`, tạo tuần với `weekly_budget_vnd` = min trả về thì ≥ 90% hồ sơ có `budget_over_vnd = 0`.
  - Ước tính lệch ≤ 15% so với `week_food_cost` của tuần sinh ra (ngân sách không giới hạn) ở ≥ 80% hồ sơ.
  - Tăng số người hoặc số bữa thì min, ước tính và max không giảm.
  - Thiếu `targets` thì trả 400.
  - Golden parity của `POST /v1/plans` không bị ảnh hưởng.
  - Ghi bảng kết quả theo từng hồ sơ vào `docs/dev/budget-range-check.md`.

### T-070 — Bổ sung API cho màn Flutter (D-API-01) · DEV · P0
- **Mô tả:**
  1. **Schema số:** OpenAPI hiện khai các trường số là `["number","string"]` (do `JsonNumberHandling.AllowReadingFromString`). Bỏ chế độ này, hoặc thêm schema transformer, để số chỉ là `number`/`integer`. Như vậy client Dart/TS sinh đúng kiểu.
  2. **`POST /v1/plans` trả kèm dữ liệu để xem offline:**
     - `recipes`: map `id →` Recipe đầy đủ (gồm `steps`, `cook_minutes`, `dish_role`, `image`) cho mọi món trong tuần;
     - `ingredients`: map `id → {name, aisle, household_units, default_pantry}` cho mọi nguyên liệu xuất hiện (cả extras/substitutions).

     App không phải gọi N lần `GET /v1/recipes/{id}`.
  3. **Đơn vị bếp:** thêm `household_units` vào `IngredientDto` và vào map ở mục 2, hoặc trả sẵn `hint` ("≈ 1 thìa canh") trên từng dòng nguyên liệu của bữa. Chọn một cách và ghi vào `docs/dev/`.
  4. **`GET /v1/reference` bổ sung:**
     - `health_leanings` (Nhiều chất xơ, Hợp người tiểu đường…);
     - `dislike_suggestions` (≥ 6 nguyên liệu hay bị ghét);
     - `aisles` (id → tên quầy);
     - `description` cho từng `OptionDto` (vd "Không hạt cây: không gồm lạc và hạt hướng dương");
     - `group` cho các lựa chọn kiêng (`diet | exclusion | health`).
  5. **`POST /v1/shopping-list`** (stateless): đầu vào là các bữa của tuần (gram của bạn + khẩu phần chuẩn, bỏ bữa `eaten_out`), hộ, cửa hàng, `pantry_ids`; đầu ra là `ShoppingList`. Dùng khi đánh dấu "nhà có sẵn" hoặc ăn ngoài. Thêm `is_default_pantry` vào `ShoppingItem`.
  6. **Placeholder ảnh:** thêm `image_group` vào Recipe (kho, xào, canh, luộc/hấp, cơm, sáng, phụ), suy ra từ `dish_role`/`cuisine_tags`/`meal_types`.
- **Phụ thuộc:** T-065. Mục 1 làm trước T-080 (sinh client). Mục 2–6 xong trước T-085/T-087/T-089. Khi T-066 (mâm) thêm `dishes[]` vào `PlanMeal`, map `recipes` phải gồm cả món phụ.
- **AC:**
  - `openapi.json` không còn kiểu số dạng union với `string`.
  - Client Dart sinh từ OpenAPI biên dịch được, và các trường số có kiểu `num`/`int`.
  - Test tích hợp cho từng bổ sung.
  - Response `POST /v1/plans` đủ để render tab Kế hoạch, trang công thức, "Cách chúng mình tính" và tab Đi chợ khi không còn gọi thêm API nào. Kiểm bằng test: duyệt mọi `recipe_id`/`ingredient_id` trong plan đều có trong map.
  - Golden parity giữ nguyên (chỉ thêm trường).

### T-073 — Danh sách trắng xu hướng sức khỏe (D-ONB-03) · DEV · P1 (việc nhỏ)
- **Mô tả:** `GET /v1/reference.health_leanings` chỉ trả các id trong danh sách trắng `nhieu_xo | it_duong | tot_cho_tim | it_beo` có ≥ 10 món mang thẻ. Engine chấm điểm mềm theo đúng 4 id này; thẻ nội bộ (`giau_dam`, `omega3`, `chay`, `low_carb`) không nhận từ `preferences.health_leanings` (trả 400 nếu gửi id lạ). Màn onboarding lấy nhãn/mô tả từ i18n theo id và hiện dòng miễn trừ y tế.
- **Phụ thuộc:** dữ liệu T-059 để 2 thẻ mới xuất hiện.
- **AC:** Có test API cho danh sách trắng và ngưỡng 10 món. Gửi `health_leanings: ["giau_dam"]` thì nhận 400. Màn onboarding không hiện thẻ nội bộ.

### T-076 — Xu hướng không được làm rớt chỉ tiêu cứng (D-HLT-02) · DEV · P0
- **Mô tả:** Sửa chấm điểm/chọn món trong engine C# để xu hướng sức khỏe và khẩu vị chỉ phân hạng giữa các phương án cùng đạt sàn protein, dải kcal ±5%, ngân sách và ràng buộc cứng. Không còn phương án đạt thì bỏ qua xu hướng cho slot/ngày đó.
- **Phụ thuộc:** không (dữ liệu ngưỡng `nhieu_xo` ≥ 4 g do Research cập nhật song song).
- **AC:**
  - Với mọi hồ sơ test, số ngày đạt khi bật xu hướng ≥ số ngày đạt khi tắt hết xu hướng (cùng seed). Đây là test tham số hóa.
  - p01 (có `nhieu_xo`) đạt 7/7.
  - Golden parity giữ được ở chế độ tương thích (`meal_style=full_meal_only`, `include_dessert=false`), hoặc ghi rõ lý do lệch vào `docs/dev/port-notes.md`.
  - Engine-report cập nhật.

### T-077 — Nâng tỉ lệ ghép mâm khi ngân sách eo hẹp (D-MAM-01) · DEV · P1
- **Mô tả:**
  - Khi chọn bữa trưa/tối, nếu một mâm (main + món phụ rẻ + cơm) có chi phí ≤ `full_meal` + 5% và vẫn đạt chỉ tiêu thì ưu tiên mâm.
  - Ở bước sửa ngân sách (`repairs`), thử thay món phụ đắt bằng món phụ rẻ hơn **trước** khi đổi cả mâm thành `full_meal`.
  - Engine-report thêm cột lý do không ghép mâm (`budget` / `no_side_candidate` / `equipment`).
- **Phụ thuộc:** dữ liệu canh/rau rẻ từ T-053.
- **AC:**
  - p14 đạt ≥ 40% bữa ghép mâm mà vẫn 7/7 ngày, không vượt ngân sách, đủ tráng miệng. Nếu không đạt thì engine-report phải chỉ ra lý do chính.
  - Toàn bộ hồ sơ ≥ 60%.
  - Từng hồ sơ ≥ 40%, trừ hồ sơ bậc "Tiết kiệm" hoặc ít dụng cụ (≥ 20%).
  - Không hồi quy số ngày đạt.

### T-078 — Đi chợ: đồ nhà có sẵn + quy cơm ra gạo (D-SHP-01, D-SHP-02) · DEV · P0
- **Mô tả:**
  - (1) `pantry_ids` mặc định = danh sách `default_pantry` khi request không gửi trường này; `[]` nghĩa là không coi gì là có sẵn. `till_cost` bỏ các dòng có sẵn. Thêm `pantry_cost_if_buy_vnd` và mục "Có thể nhà đã có" (`by_aisle` riêng hoặc cờ). `week_food_cost` vẫn tính gram đã dùng của mọi nguyên liệu.
  - (2) Đọc `purchase_as {ingredient_id, factor}` (model + validate-data C#/TS schema: `factor` trong (0, 1], nguyên liệu đích phải tồn tại và có giá). Danh sách đi chợ gộp nhu cầu quy đổi vào nguyên liệu đích (cơm → gạo), tính gói/giá/phần dư theo nguyên liệu đích. Dòng nguyên liệu của bữa có thêm gợi ý "≈ X g gạo".
  - (3) Flutter tab Đi chợ: mục "Có thể nhà đã có" với nút bỏ đánh dấu; nhớ lựa chọn qua các tuần.
- **Phụ thuộc:** T-089 (tab Đi chợ đã có); dữ liệu T-042c cho phần (2). Phần (1) làm được ngay.
- **AC:**
  - Golden parity giữ được với `pantry_ids: []` và dữ liệu không có `purchase_as`.
  - Có test: cơm 1.000 g → 360 g gạo (factor 0,36, D-SHP-03) → 1 bao theo quy cách trong dữ liệu.
  - Không gửi `pantry_ids` thì `till_cost` không gồm dầu/nước mắm/gạo.
  - `week_food_cost` không đổi khi bật hay tắt pantry.
  - Bảng tỉ lệ tại quầy / món ăn trên 16 hồ sơ được ghi vào `docs/dev/` (kỳ vọng ≤ 1,5 ở đa số hồ sơ).

### T-079 — Nhiều quy cách bao bì cho một nguyên liệu – cửa hàng (D-SHP-04) · DEV · P2
- **Mô tả:**
  - Schema giá cho phép nhiều dòng cùng (`ingredient_id`, `store_id`), khác `pack_g`.
  - Engine đi chợ chọn tổ hợp gói rẻ nhất đủ lượng cần (bài toán nhỏ, vét cạn ≤ 3 quy cách).
  - Validate-data cảnh báo `purchase_as` lệch kcal > 5% (D-SHP-03). Phần cảnh báo này có thể làm sớm, độc lập với phần nhiều quy cách.
- **Bước đầu:** Dev ước lượng công, ghi vào `docs/dev/`.
- **AC:** Test gạo 1/2/5 kg chọn đúng tổ hợp rẻ nhất. Golden parity giữ được khi dữ liệu chỉ có một quy cách.

### T-074 — Chuyển nguồn chuỗi UI sang `content/i18n/vi.json` (D-ONB-04) · DEV · P0 (sau T-055)
- **Mô tả:** `mobile/tool/gen_arb.py` đọc `content/i18n/vi.json` làm nguồn duy nhất; xóa `mobile/tool/arb_extra.json` sau khi đối chiếu đủ key; script báo lỗi khi code dùng key không có trong nguồn.
- **Phụ thuộc:** T-055.
- **AC:** Sinh ARB từ nguồn chính thức không thiếu key nào đang dùng trong `mobile/lib`. `flutter analyze`/`flutter test` xanh. Câu chờ ở màn Tổng kết là "chỉ vài giây" (theo chuỗi Research).

### T-075 — Làm sạch schema `budget-range` (D-ONB-05) · DEV · P2
- **Mô tả:** Các trường cấp ngoài (`store_id`, `adults`, `children`, `slots`) thành tùy chọn và chỉ dùng khi không có `preferences`. Phải có ít nhất một nguồn, nếu không trả 400. Mô tả rõ trong OpenAPI. Client Flutter bỏ gửi trường thừa.
- **AC:** Test cả hai dạng request. `openapi.json` cập nhật, client sinh lại biên dịch được.

### T-067 — Engine + API: thay đổi tuần · DEV · P1
- **Mô tả:** Endpoint và logic C#:
  - `POST /v1/plans/swap-suggestions`: 2–3 món/mâm thay thế giữ ngày đạt.
  - `POST /v1/plans/apply-swap`.
  - `POST /v1/plans/swap-ingredient`: cùng `swap_group`, giữ protein ±5%.
  - `POST /v1/plans/eat-out`: đánh dấu, ngày không tính thiếu, rút đi chợ.
  - `POST /v1/plans/regenerate-rest`: giữ ngày đã qua và hôm nay.

  Cả 5 endpoint stateless: máy khách gửi kèm tuần hiện tại.
- **Phụ thuộc:** T-066.
- **AC:** Đúng AC của US-5.1…5.5 phía engine. Unit test + test tích hợp. Không bao giờ gợi ý món vi phạm ràng buộc cứng.

### T-068 — Docker + hướng dẫn chạy/triển khai · DEV · P1
- **Mô tả:** `backend/Dockerfile` (multi-stage, chạy non-root), mount hoặc copy `data/` vào image, `docker-compose.yml` cho local, `docs/dev/deploy.md` (biến môi trường, health check, cập nhật dữ liệu không build lại app).
- **Phụ thuộc:** T-065.
- **AC:** `docker compose up` thì `/health` 200 và `POST /v1/plans` chạy được. Image < 250 MB.

### T-080 — Khung Flutter · DEV · P0
- **Mô tả:** `mobile/` (Flutter stable, Android + iOS), `flutter_lints` nghiêm, `go_router`, `flutter_riverpod`, `dio`, `freezed`/`json_serializable`. Sinh client Dart từ `backend/openapi/openapi.json` (openapi-generator hoặc viết tay + test hợp đồng). Cấu hình base URL theo môi trường (emulator `10.0.2.2`). 3 tab placeholder: Kế hoạch · Đi chợ · Bạn. `mobile/README.md`.
- **Phụ thuộc:** T-065. **Cần Flutter SDK trên máy** (PRD §9.5). Nếu chưa có thì báo session chính, không tự cài toàn cục.
- **AC:** `flutter analyze`/`flutter test` xanh. Chạy được trên Android emulator Pixel_7 và gọi được `/health`.

### T-081 — Design system + placeholder ảnh + i18n · DEV · P0
- **Mô tả:** Theme (nhận diện riêng, theo tên "FitPro - Mâm đủ"; **không** dùng màu/linh vật Mealbird). Component: Button, Chip, SelectCard, Stepper, Toggle, SegmentedControl, ProgressSegments, MacroChip, Banner, ListRow, BottomCTA, DishCard (thẻ món trong mâm). Placeholder ảnh theo nhóm món (kho, xào, canh, luộc/hấp, cơm, sáng, phụ) bằng minh họa/biểu tượng tự vẽ. Script chuyển `content/i18n/vi.json` thành `lib/l10n/app_vi.arb`.
- **Phụ thuộc:** T-080; T-055 (khi chưa có thì dùng key).
- **AC:** Trang gallery (chỉ ở debug) hiển thị mọi component. Vùng chạm ≥ 44. Tương phản AA. `image: null` không lỗi.

### T-082 — State, lưu cục bộ, cache offline · DEV · P0
- **Mô tả:** Riverpod provider cho profile, preferences, onboarding step, current plan, saved plans, shopping checks, blocked recipes, cooked steps. Lưu bằng `hive`/`shared_preferences` có `schemaVersion` và migrate. Cache tuần + công thức để xem offline. Đếm số lần đổi món (phục vụ đo freemium, chưa chặn).
- **Phụ thuộc:** T-080.
- **AC:** Tắt rồi mở app giữ nguyên trạng thái. Ở chế độ máy bay vẫn xem được tuần/công thức/đi chợ. Có unit test cho provider.

### T-083 — Onboarding 1: khung wizard + mục tiêu & cơ thể + màn chỉ tiêu · DEV · P0
- **Phụ thuộc:** T-081, T-082.
- **AC:** Đúng US-1.1 (AC5 = ±5%). Chỉ tiêu lấy từ `POST /v1/targets` (debounce). Quay lại giữ lựa chọn. Tắt app giữa chừng thì mở lại đúng bước.

### T-084 — Onboarding 2: cửa hàng, ngân sách, người ăn · DEV · P0
- **Phụ thuộc:** T-083, T-069. **AC:** đúng US-1.2 (gồm AC2b); min/max/bậc lấy từ `POST /v1/budget-range` (gửi kèm `targets`); nhãn bậc lấy từ i18n theo `key`.

### T-085 — Onboarding 3: bữa ăn, kiêng/dị ứng, không muốn thấy · DEV · P0
- **Phụ thuộc:** T-083. **AC:** đúng US-1.3, US-1.4; phân bổ bữa lấy từ `/v1/slots/preview`; tìm nguyên liệu không dấu qua `/v1/ingredients`.

### T-086 — Onboarding 4: thẻ vuốt, dụng cụ, tổng kết + tạo tuần · DEV · P0
- **Phụ thuộc:** T-083, T-069. **AC:** đúng US-1.5, US-1.6; màn tổng kết gọi lại `budget-range` kèm `preferences` và cảnh báo nếu ngân sách < min (US-1.2 AC2c). Vuốt có nút thay thế + hoàn tác. Màn checklist gọi `POST /v1/plans`. Mất mạng hoặc lỗi API thì hiện màn lỗi thân thiện + thử lại.

### T-087 — Tab Kế hoạch · DEV · P0
- **Phụ thuộc:** T-086. **AC:** đúng US-3.1. Bữa ghép mâm hiển thị tên các món dạng "Cá kho + canh cải + cơm". Banner `partial` nêu đúng ngày + mức thiếu.

### T-088 — Màn bữa/mâm, công thức, chế độ nấu, "Cách chúng mình tính" · DEV · P0
- **Phụ thuộc:** T-087. **AC:** đúng US-3.2 (AC6 mâm, AC7 placeholder) và US-3.3. `wakelock_plus` bật/tắt theo vòng đời màn. Phần của bạn / cả nồi. Tổng bảng trace bằng chip macro.

### T-089 — Tab Đi chợ · DEV · P0
- **Phụ thuộc:** T-087. **AC:** đúng US-4.1. Chia sẻ qua `share_plus`. Đánh dấu đã mua / nhà có sẵn được lưu lâu dài.

### T-090 — Thay đổi tuần (UI) · DEV · P1
- **Phụ thuộc:** T-067, T-088. **AC:** đúng US-5.1…5.5. Sau mỗi thay đổi, validator chạy lại và danh sách đi chợ cập nhật. Hoàn tác được.

### T-091 — Tab Bạn · DEV · P1
- **Phụ thuộc:** T-083…T-086 (dùng lại màn onboarding ở chế độ sửa), T-055. **AC:** đúng Epic 6. Xóa dữ liệu có xác nhận 2 bước. Có miễn trừ y tế và nguồn dữ liệu.

### T-092 — Trợ năng + hiệu năng + build Android · DEV · P1
- **AC:** Font lớn (text scale 1.3) không vỡ bố cục. Có nhãn semantics cho nút icon. Mở tab ≤ 300 ms. Có APK release ký debug để test nội bộ.

### T-093 — Sửa lỗi theo QA (đợt 1, từ T-050) · DEV · **P0**
- **Phụ thuộc:** T-050 (`docs/research/acceptance-T050.md`). Quyết định ở PRD §10 D-QA-01…07.
- **Danh sách việc, làm theo thứ tự:**

| # | Lỗi | Việc | Ưu tiên | Kiểm |
|---|---|---|---|---|
| 1 | L-03 | `no_seed` cấm cả `seed` và `sesame`; giữ `no_sesame` riêng; sửa `description`/nhãn "Không hạt giống & vừng" (D-QA-01) | P0 (an toàn dị ứng) | Unit test `Filter`; `POST /v1/plans` với `no_seed` × 5 seed không có `vung` |
| 2 | L-09 | Điều tra tab Bạn không phản hồi trên emulator; sửa nếu lỗi app; nếu do emulator thì ghi cách tái hiện/khắc phục vào `docs/dev/` | P0 (chặn kiểm thử UI) | Widget test chuyển tab; kiểm tay trên Pixel_7 |
| 3 | L-01 | Scale tráng miệng/món không chạm dòng cố định; kẹp mọi gram vào [min, max] (D-QA-04) | P0 | Test bất biến: mọi dòng của mọi bữa ở 16 hồ sơ × 3 seed nằm trong [min, max]; dòng cố định = gram công thức |
| 4 | L-02 **(ĐÓNG 2026-11-07: TC-1-17/TC-E-02 đã sửa thành "tắt cả sáng, trưa, tối → 400")** | API 400 khi không còn bữa chính được lên thực đơn hoặc `equipment` không có thiết bị nấu; app khóa nút Tiếp tục kèm lời nhắc (D-QA-05) | P0 | Test API + widget test 2 bước onboarding |
| 5 | L-08 | Câu chữ trạng thái ngân sách nêu rõ "chi phí món ăn"; thêm dòng thông tin khi tiền tại quầy > ngân sách (D-QA-02; chuỗi lấy từ i18n, Research bổ sung key) | P1 | Widget test 2 trạng thái |
| 6 | L-05 | Kiểm nhanh điểm của món chứa lạc có bị phạt bất thường không; thêm unit test: "Không hạt cây" giữ món lạc trong tập hợp lệ (D-QA-06) | P2 | Ghi kết luận vào `docs/dev/` |

- **AC:**
  - Mục 1–4 xong, `dotnet test` và `flutter test` xanh. Số test .NET ổn định giữa các lần chạy (Dev đang điều tra).
  - Golden parity giữ được, hoặc lệch có giải thích (L-01 có thể đổi gram tráng miệng; khi đó xuất lại golden).
  - Báo session chính để Research chạy T-050b.

### T-094 — Lượng cơm theo thói quen người dùng (engine + API) · DEV · **P0**
- **Phụ thuộc:** PRD §10 D-COM-01 (thay D-MAM-02). Số gram mỗi mức dùng bảng D-COM-01; nếu T-059c đổi số thì chỉ sửa hằng số.
- **Files:** `backend/MonNgon.Engine/Mam.cs` (bỏ `CarbBaseFloorRatio`, thêm ghim cơm), bước scale trong `PlanWeek.cs`, `WeekChanges.cs` (đổi món giữ mức cơm), `Shopping.cs` (gạo theo cơm thực tế cả nhà), model/OpenAPI (`preferences.rice_habit`, `meal.rice`, `meal.notes`), `golden/`, `docs/dev/engine-report-*.md`.
- **Mô tả:**
  - `preferences.rice_habit` ∈ `it` | `vua` | `nhieu` | `rat_nhieu` (75 / 150 / 300 / 450 g cơm chín cho người dùng chính); thiếu trường = `vua`.
  - Ghim cơm của bữa mâm theo mức (±10 g). Món chính, canh, rau, tráng miệng co giãn trong [min_g, max_g] của dòng scalable; dòng cố định không đổi.
  - Không vừa: đổi tổ hợp mâm → giảm cơm bước 25 g đến sàn max(50% mức, 60 g) → `full_meal` → không đạt (US-2.2).
  - Bữa giảm cơm trả `notes[{code:"rice_reduced", target_g, actual_g, reason}]`; mọi bữa mâm trả `rice{habit, target_g, actual_g}`.
  - Hộ gia đình: người lớn khác mức `vua`, trẻ em 0,6 × `vua`. Đổi món (US-5.1) giữ nguyên mức cơm.
  - Engine-report thêm cột cho mỗi hồ sơ: `rice_habit`, cơm thực tế min / trung vị mỗi bữa mâm, % bữa có ghi chú `rice_reduced`, gạo sống cần mua cả tuần.
- **AC (đo được):**
  1. 16 hồ sơ × 3 seed (mức mặc định `vua`): **mọi** bữa mâm có cơm thỏa một trong hai: `actual_g` ∈ [target − 10, target + 10], hoặc có ghi chú `rice_reduced` với `actual_g` ≥ sàn. **0 bữa dưới sàn; 0 bữa giảm cơm mà không có ghi chú.** Viết thành test bất biến.
  2. p01, mức `vua`: mỗi bữa mâm có cơm **≥ 140 g chín**, trừ bữa có ghi chú. Chạy lại it-05 và chụp màn mới.
  3. Ma trận p01 × 4 mức: cơm trung vị mỗi bữa tăng đúng thứ tự `it` < `vua` < `nhieu` < `rat_nhieu`; gạo cần mua cả tuần cũng tăng theo.
  4. Vẫn **16/16 hồ sơ đạt 7/7**, kcal ±5%, protein ≥ sàn, 0 vi phạm cứng; ≥ 60% bữa trưa/tối ghép mâm (ngưỡng D-MAM-01).
  5. Mức `vua`: tỉ lệ bữa có ghi chú `rice_reduced` ghi trong engine-report cho từng hồ sơ. Hồ sơ nào > 20% thì báo session chính kèm số liệu (không tự đổi mức gram); PM quyết.
  6. Golden xuất lại (thiếu `rice_habit` = `vua`), ghi lý do lệch trong `docs/dev/`. OpenAPI cập nhật, client Dart sinh lại.

### T-095 — Bước "Thói quen ăn cơm" + ghi chú giảm cơm (Flutter) · DEV · **P0**
- **Phụ thuộc:** T-094 (API), T-059c (chuỗi i18n). PRD US-1.4b, D-COM-01.
- **Files:** `mobile/` onboarding (sau bước kiêng/dị ứng), màn tổng kết, màn bữa/mâm, tab Bạn.
- **Mô tả:**
  - Màn câu hỏi 4 lựa chọn, nhãn chính là số chén, gram trong ngoặc ("½ chén (~75 g)", "1 chén (~150 g)", "2 chén (~300 g)", "3 chén trở lên (~450 g)"), `vua` chọn sẵn; bỏ qua khi `low_carb`; cảnh báo > 45% kcal bữa (US-1.4b AC3).
  - Màn bữa/mâm: thẻ cơm hiện theo chén, gram trong ngoặc ("Cơm gạo lứt · 1 chén (150 g)"); gram thực tế quy ra chén làm tròn ½ chén, nhỏ nhất ½ chén (PRD D-COM-01); bữa có `rice_reduced` hiện ghi chú theo chuỗi i18n.
  - Tab Bạn: sửa mức cơm → hộp xác nhận → lên lại các ngày còn lại của tuần (US-5.5) → danh sách đi chợ cập nhật.
- **AC:**
  1. Widget test: 4 lựa chọn với nhãn đúng định dạng "N chén (~X g)"; mặc định `vua`; unit test quy gram → chén (75→½, 90→½, 150→1, 225→1½, 450→3); bước bị bỏ qua khi `low_carb`; dòng cảnh báo hiện/ẩn đúng ngưỡng.
  2. Request `POST /v1/plans` có `rice_habit` đúng lựa chọn (test với API giả).
  3. Widget test màn mâm: thẻ cơm hiện "… · N chén (X g)"; có `rice_reduced` → hiện ghi chú ghi theo chén; không có → không hiện.
  4. Tab Bạn: đổi `vua` → `nhieu` rồi xác nhận → tuần mới có cơm các ngày còn lại tăng, ngày đã qua giữ nguyên; kiểm tay trên emulator, chụp màn hình vào `docs/dev/screens/`.
  5. `flutter test` xanh.

### T-096 — Giữ cơm khi chọn mâm (p01 bị giảm cơm 92%) · DEV · **P0** (làm song song T-095 được: chỉ đụng engine)
- **Phụ thuộc:** T-094 xong. PRD §10 D-COM-02 (phân tích nguyên nhân + quyết định).
- **Files:** bước chọn/chấm điểm mâm trong `backend/MonNgon.Engine/PlanWeek.cs`, `Mam.cs`, `WeekChanges.cs` (đổi món dùng cùng luật), test engine, `docs/dev/engine-report-rice.md`, golden nếu lệch. Không đụng `mobile/`.
- **Mô tả:**
  - Khi chấm ứng viên mâm: tính chỗ trống kcal = kcal bữa − kcal cơm theo mức − tráng miệng; kiểm món chính + canh + rau đạt đạm bữa trong chỗ trống. Ứng viên phải giảm cơm xếp **sau** mọi ứng viên giữ được cơm (thứ tự từ điển), bất kể điểm khẩu vị/xu hướng/chống lặp.
  - Khẩu vị và xu hướng chỉ xếp hạng trong nhóm giữ được cơm.
  - Mâm không có 2 món vai trò canh (món chính dạng canh tính là canh).
  - Engine-report thêm cột: % bữa mâm khớp khẩu vị "thích" của hồ sơ, số loại tráng miệng trong tuần.
- **AC (đo được, seed 1 và 2 seed thêm):**
  1. **p01 mức `vua`: ≤ 20% bữa mâm có ghi chú `rice_reduced`; cơm trung vị ≥ 140 g.** (Hiện 92%, 88 g.)
  2. Mức `vua`: **không hồ sơ nào > 20%** bữa có ghi chú (p02 hiện 23%); trung bình 16 hồ sơ ≤ 5%.
  3. Mức `nhieu` và `rat_nhieu`: trung bình không tăng so với T-094 (34% / 64%). Hồ sơ mà mức cơm không bị cảnh báo onboarding (kcal cơm ≤ 45% kcal bữa chính, US-1.4b AC3) phải ≤ 20%.
  4. Khẩu vị vẫn được tôn trọng: p01 ≥ 50% bữa mâm khớp khẩu vị "thích" (xào hoặc canh). Ghi số trước/sau.
  5. **Khôi phục test:** p01 tráng miệng ≥ 3 loại/tuần; `Tuan_14` p04 ≥ 10, p10 ≥ 9 bữa mâm (nếu không đạt, ghi số đo và báo session chính, không tự nới thêm).
  6. Giữ nguyên: 16/16 hồ sơ 7/7, kcal ±5%, protein ≥ sàn, 0 vi phạm cứng, 0 bữa dưới sàn cơm hoặc giảm cơm mà không ghi chú, ≥ 60% bữa trưa/tối ghép mâm, chi phí ≤ ngân sách.
  7. Chạy lại màn it-05 (p01, mức vừa) và chụp vào `docs/dev/screens/`.
- **Quan sát phụ (P1, làm nếu nhỏ):** p01 có bữa phụ chiều chỉ 3 kcal (`khoai_tay_luoc_muoi`). Bữa phụ được lên món phải ≥ 40 kcal; không vừa thì bỏ trống bữa phụ đó kèm lý do, không hiện món gần như 0 g.

### T-097 — Sửa lỗi QA đợt 2 (L-12, L-13 từ T-050b mục 14) · DEV · P1 (sau T-096)
- **Phụ thuộc:** T-096. PRD §10 D-QA-08, D-QA-09. Nguồn: `docs/research/acceptance-T050b.md` mục 14.
- **Danh sách việc:**

| # | Lỗi | Việc | Ưu tiên | Kiểm |
|---|---|---|---|---|
| 1 | L-12 | Tìm nguyên nhân hai mức tối thiểu (650k ở bước ngân sách, 700k ở tổng kết). Cùng lựa chọn mà khác số → sửa về một hàm (`budget-range` server). Khác do các bước sau đổi lựa chọn → giữ, đổi câu cảnh báo nêu lý do và cả hai con số (D-QA-08). Ghi kết luận nguyên nhân vào `docs/dev/`. | P1 | Unit/API test: cùng `preferences` thì bước ngân sách và tổng kết cho cùng mức tối thiểu. Widget test: tổng kết có mức cao hơn → câu cảnh báo có lý do + 2 con số; bằng hoặc thấp hơn → không cảnh báo. Kiểm lại đúng hồ sơ của L-12. |
| 2 | L-13 | Lưu chỉ tiêu mỗi ngày trên máy khi tạo/sửa; tab Bạn đọc số đã lưu khi offline; chưa có số lưu → thông báo mạng + nút Thử lại (D-QA-09). | P2 | Widget test offline: có số lưu → hiện "120 g protein · 1.400 kcal"; không có → thông báo + Thử lại; không bao giờ hiện "…". Kiểm tay trên emulator theo các bước của L-13. |

- **AC:** 2 mục xong; `dotnet test` và `flutter test` xanh; báo session chính để Research chạy lại TC-1-09, TC-1-33, TC-E-04 (gộp vào T-050c).

### T-098 — Mức 2 chén/3+ chén có đủ bữa có cơm; API thẻ tinh bột · DEV · **P0** (trước T-097)
- **Phụ thuộc:** T-096. PRD §10 D-COM-03, D-COM-04, D-DIV-02.
- **Files:** chấm/xếp hạng bữa trưa/tối trong `backend/MonNgon.Engine/PlanWeek.cs`, `Mam.cs`, `WeekChanges.cs`; phân bổ kcal theo bữa; model/OpenAPI (`rice.kind`, `rice.rice_equiv_g`, số chén khả thi); `MonNgon.Tools` engine-report; golden nếu lệch. Không đụng `mobile/`.
- **Mô tả:**
  - Xếp hạng bữa trưa/tối: mâm đủ cơm → mâm bớt cơm (≥ sàn, có ghi chú) → `full_meal` có cơm (dòng cơm theo mức) → `full_meal` không cơm (tính cơm 0 g).
  - Mức `nhieu`/`rat_nhieu`: cho dồn tối đa 15% kcal ngày từ sáng/phụ sang trưa/tối.
  - API: `rice.kind` (`com` | `other`), `rice.rice_equiv_g`; số chén khả thi mỗi bữa theo chỉ tiêu + đạm (cho cảnh báo onboarding).
  - Engine-report thêm cột: số bữa trưa/tối có cơm mỗi tuần (mâm + `full_meal` có cơm), gạo sống/tuần theo 4 mức trên một dòng, "món trưa/tối khi nới ngân sách 20%".
- **AC (16 hồ sơ, seed 1 + 2 seed thêm):**
  1. **Gạo sống cần mua mỗi tuần không giảm khi mức tăng:** với mọi hồ sơ không Ít tinh bột, `it` ≤ `vua` ≤ `nhieu` ≤ `rat_nhieu`. p01 hiện 575 / 678 / 429 g, không đạt.
  2. Hồ sơ lên thực đơn cả trưa và tối: số bữa có cơm/tuần ở `nhieu` và `rat_nhieu` **≥ 12/14** (p01 hiện 5 và 2). Không đạt ở hồ sơ nào thì ghi số và báo session chính, không tự nới.
  3. Không bữa `full_meal` không cơm nào được chọn khi còn mâm bớt cơm hợp lệ (test bất biến trên log xếp hạng).
  4. Mọi hồ sơ có > 20% bữa bị ghi chú bớt cơm ở một mức thì ở mức đó cờ cảnh báo onboarding phải bật (số chén khả thi < mức chọn). Test chéo trên 16 hồ sơ × 4 mức.
  5. Mâm khoai lang/bún: `rice.kind = other`, `rice.rice_equiv_g` đúng kcal tương đương cơm trắng (±5 g).
  6. Không lùi: kết quả T-096 ở `it`/`vua` (≤ 20% ghi chú mỗi hồ sơ, p01 cơm trung vị ≥ 140 g, tráng miệng ≥ 3 loại); 16/16 hồ sơ 7/7, kcal ±5%, đạm ≥ sàn, chi phí ≤ ngân sách, 0 vi phạm cứng, ≥ 60% bữa trưa/tối ghép mâm ở `vua`.
  7. Đa dạng: hồ sơ bình thường ≥ 10 món trưa/tối, trừ ngoại lệ D-DIV-01/D-DIV-02 (ghi rõ hồ sơ nào thuộc ngoại lệ nào).
- **Cập nhật AC sau lượt 1 (2026-11-08, D-COM-05):**
  - AC1: đo bằng tổng `rice_equiv_g` cả tuần, không giảm khi tăng mức (sai số làm tròn ≤ 2%); miễn cho ô thuộc ngoại lệ ngân sách AC2.
  - AC2: ngoại lệ "ngân sách sát" cho p02 (3+ chén), p09 (3+ chén), p14 (2 chén, 3+ chén); report ghi ngân sách cần để đạt.
  - AC4: bắt buộc 64/64; ước lượng chén khả thi tính cả ngân sách; p14 2 chén phải bật cảnh báo; API trả lý do (`kcal_protein` | `budget`) và ngân sách cần.
  - AC7: ở `nhieu`/`rat_nhieu` ngưỡng ≥ 6 món trưa/tối.
  - Ngoại lệ trong Rice98Tests là danh sách tường minh (hồ sơ, mức, lý do), không nới ngưỡng chung. Không nâng ngân sách hồ sơ test; không nới luật 1 canh/1 món chính.

### T-099 — Thẻ tinh bột theo tên món + cảnh báo số chén khả thi (Flutter) · DEV · P1 (sau T-097, cùng vùng `mobile/`)
- **Phụ thuộc:** T-098 (API), T-097. PRD D-COM-03, D-COM-04.
- **Mô tả:**
  - Thẻ tinh bột màn mâm: `rice.kind = com` → "Cơm gạo lứt · 1 chén (150 g)"; `other` → "Khoai lang hấp · ~115 g (thay ½ chén cơm)" (chén lấy từ `rice_equiv_g`). Ghi chú bớt cơm dùng cùng dạng.
  - Bước thói quen ăn cơm: dòng cảnh báo hiện số chén khả thi do server trả.
- **AC:**
  1. Widget test 3 trường hợp: cơm, khoai lang, bún; không còn chữ "chén cơm" làm nhãn chính cho món không phải cơm.
  2. Widget test cảnh báo: có số chén khả thi < mức chọn → hiện câu kèm số; ngược lại không hiện.
  3. Chạy lại luồng it-10 (4 mức) và chụp màn mâm khoai lang vào `docs/dev/screens/`. `flutter test` xanh.

### T-057c — Sửa TC-E-04 theo hành vi đúng (D-QA-10) · RESEARCH · P1 (việc nhỏ)
- **Mô tả:** Trong `docs/research/test-scenarios.md`, TC-E-04 sửa kết quả mong đợi thành: "Hiện 'Chưa tạo được thực đơn' + thông báo không có mạng + nút Thử lại; dữ liệu trên máy giữ nguyên; có mạng lại thì Thử lại tạo được tuần". Thêm TC: tuần đã tạo xem được offline (Kế hoạch, công thức, Đi chợ). Kiểm các TC khác có giả định "chạy offline" tương tự thì sửa luôn.
- **AC:** TC-E-04 khớp ADR-001 và `docs/dev/qa-automation.md`; ghi ngày sửa và lý do (D-QA-10).

### T-101 — Hiệu năng lập tuần ở mức cơm cao · DEV · **P0** (việc tiếp theo của Dev)
- **Trạng thái (2026-11-10):** p95 tổng 13,9 s → 1,3–1,7 s; ít/vừa ~0,1 s; app ≤ 2,0 s. **AC sửa theo D-PERF-01:** ít/vừa p95 ≤ 1 s (đạt); nhiều/3+ chén p95 ≤ 2 s, max ≤ 3 s (đạt); **thêm CPU mỗi lần lập p95 ≤ 2 s** (chưa đạt: max 7,1 s); lên lại 6 ngày theo cùng ngưỡng theo mức. **Thêm AC tất định:** 18 × 4 × 3 ô, mỗi ô 20 lần có song song → 100% cùng kết quả (P0 nếu không đạt). **XONG (2026-11-10, D-PERF-02):** tất định 216×20 = 0 khác; thời gian thực đạt mọi mức (3+ chén p95 1,89 s); điều kiện CPU chuyển sang T-105.
- **Phụ thuộc:** PR T-098/T-099. PRD §7 (hiệu năng), D-COM-06.
- **Mô tả:** Đo và giảm thời gian `POST /v1/plans` ở mức `nhieu`/`rat_nhieu` (hiện ~17 s ở 3+ chén). Gợi ý (Dev chọn): cắt tỉa sớm ứng viên mâm không vừa kcal/đạm/ngân sách trước khi scale; cache theo bữa trong một lần lập; giới hạn số vòng lặp lại ngân sách; tính chén khả thi một lần dùng chung cho onboarding và lập tuần. Kết quả phải giữ nguyên (cùng seed → cùng tuần), hoặc lệch có giải thích.
- **AC:**
  1. Bench (`MonNgon.Tools` hoặc test riêng) 18 hồ sơ × 4 mức × 3 seed, build Release: **p95 ≤ 1 s, max ≤ 3 s** mỗi lần lập tuần phía server. Ghi bảng trước/sau vào `docs/dev/`.
  2. Đổi món / lên lại phần còn lại của tuần: p95 ≤ 1 s cùng ma trận.
  3. Không đổi timeout 30 s của app để che; app hiển thị tổng ≤ 5 s trên emulator ở p01 mức 3+ chén.
  4. Tất cả AC T-094/T-096/T-098 (theo D-COM-05) vẫn đạt; golden khớp hoặc lệch có lý do.
  5. CI/check-tests có test hiệu năng chặn hồi quy (ngưỡng nới cho máy CI, ghi rõ).

### T-105 — CPU mỗi lần lập tuần + tối ưu hiệu năng mức cơm cao · DEV · **P1 (điều kiện phát hành)**
- **Phụ thuộc:** T-101. PRD D-PERF-01.
- **Mô tả (D-PERF-02):** Giảm CPU mỗi lần lập ở mức nhiều/3+ chén (hiện p95 2,7 s / 5,2 s); nguồn chính là ~12k lần thử `RescueDayWithDessert` ở phương án nặng. **Được đổi thuật toán** (vd cắt tỉa sớm, giới hạn số lần cứu ngày, chọn tráng miệng trước khi scale), đổi golden có giải thích.
- **AC:**
  1. **CPU mỗi lần lập p95 ≤ 2 s ở mọi mức** (18 hồ sơ × 4 mức × 3 seed, Release).
  2. Thời gian thực không lùi (ít/vừa p95 ≤ 1 s; nhiều/3+ ≤ 2 s); tất định 100% (mỗi ô 20 lần).
  3. Mọi AC sản phẩm T-094/T-096/T-098 theo D-COM-05/07 giữ nguyên (danh sách ngoại lệ không được dài thêm).
  4. Đo trên cấu hình máy chủ dự kiến (số lõi thật), ghi `docs/dev/`; app tổng p95 ≤ 5 s ở mọi mức.

### T-102 — Nhãn "TINH BỘT" + dọn chuỗi cũ · DEV · P2 (sau T-101; cần chuỗi từ T-057d)
- **Mô tả:** Danh sách mâm: vai trò hiện "CƠM" khi `rice.kind = com`, "TINH BỘT" khi `other` (D-COM-06). Xóa `onboardingRiceWarning` cũ và mọi chỗ dùng.
- **AC:** Widget test 3 trường hợp (cơm, khoai lang, bún); không còn key `onboardingRiceWarning` trong i18n và code (grep); `flutter test` xanh.

### T-057d — Thêm 2 hồ sơ test hộ đông người + ngân sách sát; chuỗi "TINH BỘT" · RESEARCH · P1 (việc tiếp theo của Research)
- **Mô tả:**
  - Thêm vào `data/test-profiles.json`:
    - **p17**: hộ 2 người lớn + 2 trẻ em, mức cơm `vua`, ngân sách = mức tối thiểu của `budget-range` cho hồ sơ đó (làm tròn lên 50k), đủ dụng cụ cơ bản.
    - **p18**: hộ 3 người lớn, mức `nhieu`, ngân sách sát tối thiểu, ít dụng cụ (bếp + nồi cơm điện).
  - Ghi `expect` (7/7 ngày, ghép mâm, cảnh báo cơm nếu có) và ghi chú lý do (bắt hồi quy T-098).
  - Chuỗi i18n "TINH BỘT" cho T-102.
- **AC:** 2 hồ sơ qua validator dữ liệu; báo session chính để Dev đưa vào check-tests/engine-report (AC engine áp dụng 18 hồ sơ). Nếu hồ sơ nào trượt 7/7 trên build hiện tại, ghi số đo, không sửa hồ sơ cho xanh.

### T-103 — Đưa thẻ vuốt lên bước 2 của onboarding (Flutter) · DEV · P1 (sau T-101, T-102)
- **Phụ thuộc:** T-101, T-102; chuỗi từ T-057e (**đã có**: `onboardingSwipeSoft` sửa câu, `onboardingSwipeSkipAll` = "Bỏ qua", `onboardingSummaryTasteNone` = "Khẩu vị: chưa chọn"; chạy `gen_arb.py`; xem `docs/research/content-i18n-T057e.md`). TC kiểm: TC-1-27…30, 39, 49, 50, 51. PRD D-ONB-06, US-1.5 AC4, US-1.6 AC4.
- **Files:** `mobile/lib/features/onboarding/onboarding_nav.dart` (`OnboardingStep`), `onboarding_flow.dart`, `step_swipe.dart`, màn tổng kết, lưu trạng thái onboarding, integration test onboarding.
- **Mô tả:**
  - Thứ tự mới: Mục tiêu → **Khẩu vị (thẻ vuốt)** → Cơ thể → Vận động → Chỉ tiêu → Cửa hàng → Hộ gia đình → Ngân sách → Bữa ăn → Chế độ ăn (kiêng/dị ứng) → Thói quen ăn cơm → Không muốn thấy → Dụng cụ → Tổng kết.
  - Màn vuốt: dòng "không ảnh hưởng calo, đạm hay dị ứng" + nút "Bỏ qua". Bỏ qua → không gửi `cuisine_likes`/`cuisine_less`; tổng kết "Khẩu vị: chưa chọn".
  - Lưu bước đang làm theo tên bước; trạng thái lưu từ bản cũ (theo số) được chuyển sang tên.
  - Sửa integration test/automation theo thứ tự mới, chụp lại ảnh onboarding vào `docs/dev/screens/`.
- **AC:**
  1. Widget/integration test: từ màn Mục tiêu bấm Tiếp tục → màn kế là thẻ vuốt; đi hết 14 bước đúng thứ tự trên; Back từ mọi bước về đúng bước trước, giữ lựa chọn.
  2. Bỏ qua thẻ vuốt: request `POST /v1/plans` không có khẩu vị; tổng kết hiện "Khẩu vị: chưa chọn".
  3. Thích thẻ món thịt rồi chọn Chay: tuần tạo ra 0 món có thịt (test API với hồ sơ đó).
  4. Tiếp tục dở dang: lưu ở từng bước (ít nhất Vuốt, Ngân sách, Cơm), tắt app, mở lại → về đúng bước, đủ lựa chọn. Có test chuyển trạng thái cũ (lưu theo số) sang thứ tự mới mà không nhảy sai bước.
  5. Đo thời gian từ mở app tới màn vuốt trên emulator: ≤ 2 thao tác (Mục tiêu → Tiếp tục). Ghi số đo tổng thời gian onboarding trước/sau (mục tiêu G1 ≤ 5 phút).
  6. Tab Bạn (chế độ sửa) vẫn mở đúng từng màn; `flutter test` và integration xanh.
- **Phụ (P1, L-16, D-DATA-01):** thẻ cửa hàng ở bước Cửa hàng và tab Đi chợ hiện "Giá ước lượng, chưa khảo sát tại cửa hàng này" khi `price_survey_date` là `null`; widget test 2 trạng thái. Thêm `source_note` vào validator dữ liệu nếu Research đề xuất.
- **Phụ (P2, nếu nhỏ):** kiểm lệch "Cả nồi" ở TC-3-08 (thịt heo xay 145→305 so với bí 200→520) Research nêu trong `ux-review-swipe-first.md` §7; ghi kết luận vào `docs/dev/`.

### T-106 — Sửa màn vuốt thẻ khẩu vị: căn giữa + cử chỉ quẹt (Flutter) · DEV · **P1** (làm ngay sau T-103; người dùng báo lỗi giao diện)
- **Phụ thuộc:** T-103. PRD D-ONB-07, US-1.5 AC5. Thiết kế chi tiết: `docs/research/swipe-tinder-ux.md`.
- **Files:** `mobile/lib/features/onboarding/step_swipe.dart` (bỏ `Dismissible`, tự viết thẻ kéo), widget test, ảnh `docs/dev/screens/`.
- **Mô tả và AC (đo được):**
  1. **Căn giữa:** thẻ rộng = chiều rộng màn hình − 2 × 16 dp, tối đa 400 dp, căn giữa ngang. Widget test ở 3 cỡ màn (360, 412, 600 dp): `|lề trái − lề phải| ≤ 1 dp`.
  2. **Hình thẻ:** bo góc 20 dp, có bóng; ảnh minh họa chiếm phần trên, tên/nhãn nhóm món ở dưới; chữ không bị cắt ở cỡ chữ 1.3.
  3. **Xếp chồng:** sau thẻ đang xem thấy tối đa 2 thẻ, scale 0,95 và 0,90, lệch xuống 8/16 dp. Thẻ sau "tiến lên" khi thẻ trước đi.
  4. **Kéo đa trục:** thẻ đi theo ngón tay (cả ngang và dọc); **xoay** theo độ kéo ngang, tối đa ±12°.
  5. **Nhãn kéo:** "Thích" (kéo phải) / "Ít hơn" (kéo trái), độ mờ tăng dần từ 0 theo độ kéo, đầy đủ khi tới ngưỡng. Nhãn có chữ, không chỉ dựa vào màu.
  6. **Ngưỡng:** quyết định khi kéo ngang ≥ 35% chiều rộng thẻ **hoặc** vận tốc ngang ≥ 700 dp/s. Dưới ngưỡng thì bật về giữa trong 300 ms. Vượt ngưỡng thì bay ra ngoài màn trong 250–300 ms rồi gọi logic thích/ít hơn hiện có. Widget test: kéo 30% → bật về, không ghi trọng số; kéo 40% → ghi đúng hướng; ném nhanh 20% với vận tốc 800 dp/s → ghi đúng hướng.
  7. **Nút thay thế** giữ nguyên thứ tự và `Key` (`swipe-undo`, `swipe-dislike`, `swipe-replace`, `swipe-like`), nút ≥ 48 dp. Bấm ♥/✕ chạy cùng hoạt ảnh bay ra như vuốt. **Hoàn tác:** thẻ quay lại từ phía đã bay ra (250 ms) và trả lại trọng số cũ.
  8. **Trợ năng:** `Semantics` cho thẻ (tên nhóm món + hành động "Thích", "Ít hơn"); TalkBack thao tác được mà không cần vuốt. **Giảm chuyển động** (`MediaQuery.disableAnimations`): không xoay, không scale, đổi thẻ ngay.
  9. Hết thẻ → màn kết quả hiện có (giữ "Vuốt lại"); "Bỏ qua" và dòng "không ảnh hưởng calo, đạm hay dị ứng" (T-103) giữ nguyên.
  10. Không thêm dependency mới (`pubspec.yaml` không đổi). Nếu tự viết vượt 2 ngày công thì dừng và báo PM, không tự thêm package.
  11. Chụp lại ảnh màn vuốt (thẻ đầu, đang kéo phải có nhãn, đang kéo trái, sau khi hết thẻ) trên emulator, đặt cạnh ảnh cũ `it-02-onb-11-vuot-the-dau.png` để so. `flutter test` và integration onboarding xanh.

### T-057e — Cập nhật TC theo thứ tự onboarding mới + kiểm lại · RESEARCH · P1
- **Trạng thái (2026-11-09):** phần tài liệu **xong** (TC-1-27…32, 36/37, 39, E-05 theo tên/vị trí bước mới; thêm TC-1-49/50/51; chuỗi trong `vi.json`, ghi ở `docs/research/content-i18n-T057e.md`). Còn: kiểm lại sau T-103 → `acceptance-T103.md`.
- **Phụ thuộc:** D-ONB-06. Phần kiểm lại chờ T-103.
- **Mô tả:**
  - Sửa `docs/research/test-scenarios.md`: TC-1-27…30 (vuốt, nút thay thế, hoàn tác, Vuốt lại) ghi vị trí bước 2; TC-1-39 sửa "sau bước Kiêng/Ghét/Vuốt" thành "ngay sau Chế độ ăn, trước Không muốn thấy"; rà mọi TC onboarding có đánh số/vị trí bước.
  - Thêm TC: nút Bỏ qua (US-1.5 AC4); thích món thịt rồi chọn Chay → không có thịt; tiếp tục dở dang sau cập nhật thứ tự.
  - Rà câu `onboarding.swipe.soft` và chuỗi nút "Bỏ qua", "Khẩu vị: chưa chọn" (gửi Dev cho T-103).
  - Sau T-103: chạy lại các TC trên, ghi kết quả vào `docs/research/acceptance-T103.md` kèm ảnh.
- **AC:** Không còn TC nào ghi thứ tự cũ (grep "bước 12", "sau bước Kiêng/Ghét/Vuốt"); mỗi TC mới có kết quả mong đợi đo được; biên bản kiểm lại có bảng đạt/không đạt.

### T-054c — Đợt dữ liệu D2: sửa giá thịt heo xay (L-14) + kiểm mẫu giá BHX · RESEARCH · P1
- **Trạng thái (2026-11-09): XONG** (`price-audit-D2.md`). L-14 rút lại; 4/4 dòng BHX được kiểm (chỉ có 4); sửa `thit_heo_nac_dui` 34.500 ₫. Việc tiếp chuyển sang T-054d (D-DATA-01).
- **Phụ thuộc:** PRD D-P2-03. Nguồn: báo cáo T-110 lượt 2.
- **Mô tả:**
  - Mở trang BHX bằng trình duyệt, xác định đúng sản phẩm thịt heo xay nạc (quy cách, giá, ngày) và sửa dòng `thit_heo_xay_nac` trong `data/prices.json`.
  - Kiểm mẫu ≥ 15 dòng giá BHX khác (ưu tiên nguyên liệu dùng ≥ 5 công thức): tên sản phẩm trên trang khớp nguyên liệu, quy cách, giá. Ghi bảng đúng/sai vào `docs/research/price-audit-D2.md`.
  - Sai thì sửa luôn trong cùng đợt; sai > 3/15 thì báo PM để mở rộng kiểm toàn bộ.
- **AC:** dữ liệu qua validator; mỗi dòng sửa có `source_url` và `surveyed_on` mới; báo session chính để Dev regen golden/fixture một lần (chạy sau T-103 nếu Dev đang giữa task) và chạy lại engine-report so chi phí trước/sau.

### T-054d — Nguồn cho giá ước lượng + giá thường (L-15, L-16) · RESEARCH · P1
- **Trạng thái (2026-11-09): XONG** (`price-audit-D2.md` mục 6). 4 dòng BHX về giá thường (25.500 / 35.700 / 46.200 / 63.400 ₫); 69/69 dòng `cho_khac` có `source_note` (25 có nguồn, **44 "chưa có nguồn"** → T-054e); `stores.json` WinMart/Co.opmart `price_survey_date = null`; chuỗi `priceEstimateNotSurveyed`. Đổi `data/prices.json`, `data/stores.json`, `content/i18n/vi.json`.
- **Phụ thuộc:** PRD D-DATA-01.
- **Mô tả:**
  - `thit_heo_xay_nac` sửa về giá thường 25.500 ₫; kiểm 3 dòng BHX còn lại có phải giá khuyến mãi không, sửa về giá thường.
  - Thêm `source_note` cho 69 dòng `cho_khac` (cách ước tính + nguồn tham chiếu + ngày); không nêu được thì `"chưa có nguồn"`. Đề xuất Dev thêm `source_note` vào hợp đồng dữ liệu/validator (bắt buộc với `cho_khac`).
  - `stores.json`: `price_survey_date` = `null` cho WinMart, Co.opmart (0 dòng giá). Chuỗi i18n "Giá ước lượng, chưa khảo sát tại cửa hàng này".
- **AC:** 69/69 dòng `cho_khac` có `source_note`; ghi số dòng "chưa có nguồn"; dữ liệu qua validator; báo session chính để Dev regen golden **một lần** gộp với T-054c (sau T-103 nếu Dev đang giữa task).

### T-104 — Regen golden sau đợt giá D2 + validator `source_note` · DEV · P1 (**làm ngay**, việc nhỏ, chen trước phần còn lại của T-101)
- **Phụ thuộc:** T-054c, T-054d xong (dữ liệu đã đổi trong cây làm việc, `data_version` đã đổi nên golden/fixture đang lệch).
- **Mô tả:** Regen golden, `manifest.json`, fixture mobile **một lần**. Validator dữ liệu: `source_note` bắt buộc với dòng `cho_khac` (giá trị `"chưa có nguồn"` hợp lệ nhưng đếm và in cảnh báo). Chạy engine-report so chi phí trước/sau đợt D2.
- **AC:** `dotnet test`, `flutter test` xanh; validator báo đúng số dòng "chưa có nguồn" (44); bảng chi phí trước/sau 18 hồ sơ ghi vào `docs/dev/`; hồ sơ nào vượt ngân sách sau khi đổi giá thì liệt kê (không tự nâng ngân sách hồ sơ test), báo session chính.

### T-054e — Tìm nguồn cho 44 dòng giá ước lượng · RESEARCH · P2 (trước phát hành)
- **Mô tả:** Khảo sát tay (trình duyệt hoặc chợ) cho 44 dòng `cho_khac` đang "chưa có nguồn", ưu tiên nguyên liệu dùng nhiều công thức. Xem lại 2 dòng lệch khoảng tham khảo (`thit_bo_nac`, `gao_te`). `com_trang` giữ dòng deprecated theo D-SHP-05, chỉ ghi chú.
- **AC:** số dòng "chưa có nguồn" giảm còn ≤ 10, mỗi dòng sửa có `source_note` + ngày; báo Dev regen golden một lần.

### T-050b — Kiểm thử lại + phần UI chưa kiểm · RESEARCH · P0 (sau T-093 mục 1–4)
- **Mô tả:**
  - Chạy lại các TC không đạt của T-050 (TC-1-17, 1-23, 1-31, 2-04, 2-04b) cùng TC đã sửa.
  - Kiểm phần UI chưa kiểm: onboarding (TC-1-08…1-38), tab Bạn, trang công thức (TC-3-06…3-10), đổi món/đổi nguyên liệu, mất mạng, xóa dữ liệu.
  - Ghi `docs/research/acceptance-T050b.md`.
- **AC:** Mọi TC P0 có Pass/Fail. Lỗi mới đánh số tiếp từ L-10.

### T-057b — Sửa tài liệu test theo T-050 · RESEARCH · P0 (việc nhỏ, làm ngay)
- **Mô tả:** Sửa `docs/research/test-scenarios.md`:
  - TC-1-07: dải ±5% (D-QA-03); rà mọi TC còn ghi dải cũ.
  - TC-2-04b: chỉ dòng scale được làm tròn 5 g (D-QA-04).
  - TC-1-22: kiểm ở cấp lọc (D-QA-06).
  - TC-1-23: "Không hạt giống & vừng" loại cả vừng (D-QA-01).

  Thêm key i18n cho câu ngân sách mới (D-QA-02) vào `content/i18n/vi.json`. File này là nội dung, không thuộc dữ liệu đóng băng.
- **AC:** Không còn TC mâu thuẫn với PRD v0.2 §5/§10.

### T-054b — Đợt mở băng dữ liệu D1 · RESEARCH · P1 (sau khi Dev xong T-093 mục 1–4)
- **Mô tả:** Gộp các thay đổi dữ liệu đang chờ vào **một** đợt (D-QA-07):
  - (1) L-04: thêm `rau_muong` (dinh dưỡng có nguồn, giá, `aliases` gồm "rau muong") và ≥ 3 món dùng rau muống (luộc, xào tỏi, canh chua);
  - (2) T-042c: gạo sống + `purchase_as`;
  - (3) ngưỡng `nhieu_xo` ≥ 4 g (D-HLT-02), nếu chưa áp dụng;
  - (4) đếm và báo số món có lạc (D-QA-06).
- **AC:**
  - Qua validate-data.
  - Dev xuất lại golden và chạy engine-report: vẫn 16/16 hồ sơ 7/7, 0 vi phạm cứng.
  - `GET /v1/ingredients?q=rau muong` trả "Rau muống".
  - Ghi danh sách thay đổi vào `docs/research/data-batch-D1.md`.

### Thứ tự ưu tiên sau T-050
**Thứ tự Dev đã chốt (2026-11-10):** kiểm tất định (P0 nếu lỗi) → T-101 phần còn lại (ngoại lệ p01, BudgetTests, CPU ≤ 2 s) → T-103 → **T-106 (sửa màn vuốt, người dùng báo lỗi)** → **T-106 (sửa màn vuốt)** → phase 2: T-112 (độ tươi) và T-115 (tự sửa giá) → T-113 (nguồn giá BHX) → T-114 (UI giá). T-105 (CPU ≤ 2 s, đổi thuật toán được; **P1, điều kiện phát hành**) xếp sau T-103, trước hoặc song song phase 2 tùy Dev (khác file với T-112/T-115 Flutter).

1. **Dev:** xong việc điều tra số test .NET dao động → T-093 mục 1 (L-03) → 2 (L-09) → 3 (L-01) → 4 (L-02) → T-078 phần pantry → **T-094 (lượng cơm theo thói quen, D-COM-01, xong) → T-095 (Flutter) ∥ T-096 (giữ cơm khi chọn mâm, D-COM-02; song song được vì khác file)** → **T-098 (2–3 chén đủ bữa có cơm, D-COM-04)** → T-097 (L-12, L-13) → T-099 (thẻ tinh bột, Flutter, xong PR #2) → **T-104 (regen golden sau đợt giá D2, làm ngay)** → **T-101 (hiệu năng mức cơm cao, P0)** → T-102 (nhãn TINH BỘT, P2) → **T-103 (thẻ vuốt lên bước 2, D-ONB-06)** → T-093 mục 5 (L-08) → mục 6 (L-05).
2. **Research:** **T-110 lượt 3 (robots.txt + ánh xạ sản phẩm BHX HCM, D-P2-06)** · T-054d xong · **T-054e (nguồn cho 44 dòng giá, P2)** · (sau T-057d: T-110/T-111 phase 2, mức thấp) · **T-057e (TC theo thứ tự onboarding mới + chuỗi cho T-103)**, **T-057d (2 hồ sơ test hộ đông người + ngân sách sát, chuỗi TINH BỘT)**; T-057c (sửa TC-E-04, TC-E-09) bất cứ lúc nào; **T-059c ngay (số liệu chén cơm, dữ liệu `max_g`, chuỗi; Dev cần trước T-095)**, T-057b (tài liệu, không chạm dữ liệu) → chờ Dev xong mục 1–4 → T-050b → T-050c (sau T-094/T-095/T-096) → T-054b (mở băng D1) → các task dữ liệu còn lại (T-053, T-054…).

### T-029 — Freemium (viết lại) · DEV · P2
- **Mô tả:** Theo PRD §12.
  - Tài khoản: đăng nhập Google/Apple, hoặc ẩn danh trước rồi liên kết sau.
  - Lưu tuần và đếm lượt đổi món ở server (DB: PostgreSQL hoặc SQL Server, người dùng chọn).
  - Entitlement service: free hoặc premium, trial 7 ngày.
  - Áp giới hạn ở API: 1 tuần đang chạy, 3 lần đổi/tuần; premium mới có giá theo cửa hàng, hộ nhiều người, lên lại tuần và tuần đã lưu.
  - Paywall Flutter (sau tổng kết onboarding và khi chạm giới hạn).
  - In-App Purchase (`in_app_purchase`), xác minh biên nhận ở server.
- **Phụ thuộc:** MVP xong; người dùng chốt giá (T-056) và DB.
- **AC:** Giới hạn được kiểm ở server (không vượt được bằng cách sửa app). Hết trial thì về free mà không mất tuần đang chạy. Khôi phục giao dịch được.

### T-100 — Web ReactJS · DEV · P2
- **Mô tả:** `web/` ReactJS + TypeScript, client TS sinh từ OpenAPI, cùng luồng và màn như mobile. Thanh toán web qua MoMo/ZaloPay/VNPay (kèm T-029).
- **Phụ thuộc:** mobile MVP xong (T-093).

---

## Task RESEARCH

### Trạng thái task cũ
| Task | Trạng thái | Sản phẩm |
|---|---|---|
| T-040 Kho nguyên liệu | PARTIAL | `data/ingredients.json` có 46/≥110 nguyên liệu → phần còn lại chuyển vào T-054 |
| T-041 Quy tắc dị ứng | DONE | `docs/research/allergen-rules.md` |
| T-042 Giá & bao bì | PARTIAL | `data/prices.json`: chủ yếu giá `cho_khac`; theo cửa hàng còn thiếu → T-042b |
| T-043 Công thức | DONE (lô 1) | 137 công thức `full_meal` |
| T-044 Ảnh món | CANCELLED | Q5: dùng placeholder; người dùng cung cấp ảnh sau |
| T-045 Nội dung UI | PARTIAL | Nháp ở `docs/research/content-draft/i18n-vi.json` → T-055 |
| T-046 Thẻ vuốt | PARTIAL | Nháp ở `docs/research/content-draft/swipe-cards.json` → T-055 |
| T-047 Pháp lý | DONE (nháp) | `docs/research/legal-notes.md`; cần thêm điều khoản freemium khi làm T-029 |
| T-048 Hồ sơ test | DONE | `data/test-profiles.json` (14 hồ sơ) |
| T-049 Kịch bản test | DONE (v0.1) | `docs/research/test-scenarios.md` → cập nhật ở T-057 |

### T-058 — Món tráng miệng (D-DES-01) · RESEARCH · P0 (cần sớm, chặn T-071)
- **Mô tả:** Thêm khoảng **20 công thức `dish_role: dessert`** vào `data/recipes.json`, cùng nguyên liệu và giá còn thiếu:
  - ≥ 9 **trái cây** phổ biến quanh năm: chuối, cam, ổi, dưa hấu, đu đủ, thanh long, táo, bưởi, xoài/dứa;
  - ≥ 4 **sữa**: sữa tươi không đường, sữa chua không đường, sữa chua có đường, sữa chua Hy Lạp;
  - ≥ 3 cho **thuần chay / không sữa**: sữa đậu nành không đường, sữa hạt, …;
  - ≥ 3 **chè ít đường**: đậu xanh, đậu đỏ, hạt sen/khoai;
  - 1–2 món khác: thạch rau câu ít đường, sữa chua nếp cẩm.
  - Mỗi món có khẩu phần chuẩn 50–180 kcal, `min_g`/`max_g` hẹp cho dòng chính, gắn đúng `portable`, `low_carb_ok` (≤ 10 g carb/khẩu phần), `health_tags` (vd `it_duong`), `equipment` (chè cần `bep`).
- **Nguyên liệu:**
  - Dinh dưỡng có nguồn (Bảng TPDD VN 2007 / USDA).
  - `allergen_tags`/`diet_tags` đúng (sữa bò `dairy`, sữa đậu nành `soy` + `plant`, sữa hạt `tree_nut`).
  - `edible_portion` cho trái cây (bỏ vỏ/hạt).
  - `household_units` có đơn vị mua: "quả" (gram trung bình), "hộp 180 ml", "hũ 100 g".
- **Giá (`data/prices.json`):**
  - Trái cây theo quả (`pack_g` = gram/quả, `pack_label` "1 quả") hoặc theo kg (bước 100 g, `pack_label` "theo cân").
  - Sữa/sữa chua theo hộp/lốc (`pack_label` "lốc 4 hộp 180 ml").
  - `shelf_life_days` thực tế (chuối 4, dưa hấu đã cắt 2, cam 14, sữa tươi tiệt trùng 30…). Có `cho_khac` và ≥ 1 siêu thị; có ngày khảo sát.
- **Phụ thuộc:** hợp đồng dữ liệu v0.2 (mục tráng miệng). DEV cập nhật schema để validate được cờ mới.
- **AC:**
  - Qua validate-data.
  - Với mỗi hồ sơ trong `data/test-profiles.json` còn ≥ 3 dessert hợp lệ; riêng thuần chay + ít tinh bột ≥ 2.
  - Ghi chú nguồn và giả định ở `docs/research/desserts-notes.md`.
  - Giao lô đầu khoảng 8 món (5 trái cây, 2 sữa chua, 1 sữa đậu nành) trước để Dev tích hợp sớm.

### T-059 — Tiêu chí và gắn thẻ xu hướng sức khỏe (D-HLT-01, D-ONB-03) · RESEARCH · **P0** (màn onboarding đã có, đang chỉ hiện được 2/4 thẻ)
- **Mô tả:**
  - Viết `docs/research/health-tags.md` định nghĩa tiêu chí **khách quan, tính được trên khẩu phần chuẩn** cho 4 thẻ: `nhieu_xo`, `it_beo`, `it_duong` (mới), `tot_cho_tim` (mới). Ví dụ `it_duong`: không đường/mật ong/sữa đặc thêm vào; tinh bột chủ yếu nguyên cám hoặc khoai/đậu, hoặc carb ≤ 45 g; xơ ≥ 4 g. `tot_cho_tim`: có cá béo (omega-3) hoặc xơ ≥ 5 g, không chiên ngập dầu, không thịt chế biến sẵn, chất béo chủ yếu từ dầu thực vật.
  - Mỗi tiêu chí ghi nguồn tham khảo (WHO, Bộ Y tế/Viện Dinh dưỡng, ADA, AHA…).
  - Áp tiêu chí, rà lại thẻ hiện có cho toàn bộ `data/recipes.json` (cả tráng miệng T-058).
  - Không dùng tên bệnh làm thẻ, không viết tuyên bố y tế.
  - Đề xuất câu chữ UI cho 4 lựa chọn + miễn trừ y tế (key `onboarding.health.*` trong `content/i18n/vi.json`).
- **Phụ thuộc:** T-058 (để gắn thẻ cả tráng miệng). Có thể gắn trước trên món hiện có.
- **AC:**
  - Mỗi thẻ có ≥ 10 món, để `GET /v1/reference` hiển thị được.
  - Bảng kiểm 10 món mẫu tính tay theo tiêu chí, ghi trong `health-tags.md`.
  - Qua validate-data.
  - Không có `health_tags` nào ngoài danh sách đã định nghĩa.

### T-059c — Số liệu chén cơm, dữ liệu tinh bột, chuỗi i18n (D-COM-01) · RESEARCH · **P0**
- **Mô tả:**
  - Kiểm lại 1 chén cơm trắng chín ≈ 150 g ≈ 195 kcal và gạo lứt chín (nguồn: bảng thành phần thực phẩm Việt Nam/USDA, cỡ chén ăn cơm phổ biến). Chốt **số gram của 1 chén** (một hằng số; ½/1/2/3 chén nhân theo). Lưu ý: ví dụ của người dùng "3 chén cơm (300g)" ngầm hiểu ~100 g/chén, khác giả định 150 g; Research đo cỡ chén ăn cơm phổ biến rồi chốt, ghi rõ nguồn.
  - Dữ liệu: nâng `max_g` các công thức `carb_base` (cơm trắng, gạo lứt, cơm hâm, cơm/gạo lứt mang đi, bún, khoai) đủ cho mức `rat_nhieu` (cơm ≥ 450 g; bún, khoai theo kcal tương đương).
  - Chuỗi i18n (hiển thị theo chén, gram trong ngoặc): câu hỏi, 4 nhãn "N chén (~X g)" + dòng phụ cho ½ chén, nhãn thẻ cơm màn mâm, dòng cảnh báo > 45%, ghi chú `rice_reduced`, dòng tổng kết "Ít tinh bột: mâm không có cơm".
  - Bổ sung TC vào `docs/research/test-scenarios.md` cho US-1.4b và AC T-094/T-095.
- **AC:** Ghi nguồn số liệu; dữ liệu qua validator dữ liệu; key i18n đủ cả tiếng Việt; TC mới có mã và kết quả mong đợi đo được.

### T-050c — Kiểm thử lại lượng cơm (sau T-094, T-095) · RESEARCH · P0
- **Mô tả:** Chạy TC của T-059c trên API và emulator. Kiểm p01 với 4 mức; một hồ sơ kcal thấp chọn `rat_nhieu` (phải thấy ghi chú, không thấy cơm dưới sàn); hồ sơ `low_carb` (không có bước, không có cơm); đổi mức ở tab Bạn.
- **AC:** Ghi `docs/research/acceptance-T050c.md` với bảng TC đạt/không đạt và ảnh màn mâm; mọi lỗi có mã L-xx và mức ưu tiên đề xuất.

### T-042c — Gạo sống và hệ số nấu (D-SHP-02) · RESEARCH · P0 (việc nhỏ)
- **Mô tả:**
  - Thêm nguyên liệu `gao_te` (gạo tẻ sống) và `gao_lut` (gạo lứt sống), có dinh dưỡng và nguồn, `aisle: gao_do_kho`, `default_pantry: true` cho gạo tẻ, `shelf_life_days` khoảng 180.
  - Thêm giá: bao 1 kg / 2 kg / 5 kg ở `cho_khac` và ≥ 1 siêu thị, có ngày khảo sát.
  - Thêm `purchase_as` cho `com_trang` (→ `gao_te`, factor **0,36**) và `gao_lut_nau_chin` (→ `gao_lut`, factor **0,34**), theo D-SHP-03.
  - Ghi căn cứ hệ số (tỉ lệ nở, nguồn tham khảo) vào `docs/research/prices-small-packs-notes.md`.
  - ~~Bỏ dòng giá "cơm nấu chín"~~ → **giữ** hai dòng `com_trang`, `gao_lut_nau_chin` và đánh dấu deprecated, vì golden TS cần (D-SHP-05).
- **Phụ thuộc:** schema `purchase_as` (Dev thêm trong T-078 phần 2; nếu chưa có thì vẫn soạn dữ liệu theo hợp đồng này).
- **AC:**
  - Qua validate-data.
  - Kcal/100 g của gạo sống so với cơm chín khớp hệ số ±10% (vd gạo 365 kcal × 0,36 ≈ 131 so với cơm 130). Quy tắc chung ≤ 5% theo D-SHP-03. **DONE trong đợt D1.**.

### T-053 — Món phụ cho ghép mâm · RESEARCH · P0
- **Bổ sung 2026-11-08 (D-COM-05):** ưu tiên món chính rẻ hợp mâm cơm (đạm nạc, kcal vừa) để người chọn 2–3 chén với ngân sách sát vẫn có mâm cơm và đủ đa dạng.
- **Mô tả:** Theo hợp đồng v0.2, thêm vào `data/recipes.json`:
  - ≥ 15 `soup` (canh rau, canh chua, canh bí, canh mồng tơi, canh cải; ≥ 6 món chay **không nước mắm**);
  - ≥ 12 `side_veg` (rau muống luộc/xào, cải xào, su su, đậu cô ve, nộm…; ≥ 6 món chay);
  - 3–4 `carb_base` (cơm trắng, cơm gạo lứt, bún, khoai lang hấp);
  - ≥ 20 `main` không cơm (tách từ món mặn hiện có hoặc món mới: kho, rang, rim, hấp; ≥ 6 món chay/đậu phụ đạm cao; ≥ 6 món chỉ cần lò vi sóng hoặc nồi cơm điện).

  Gắn `pairs_with`. Thêm nguyên liệu thiếu vào `data/ingredients.json` (có nguồn).
- **Phụ thuộc:** không (hợp đồng v0.2 đã có). DEV cập nhật schema TS/C# để validate được.
- **Bổ sung (D-MAM-01):** trong số canh/rau, ≥ 8 món có chi phí ≤ 8.000 ₫/khẩu phần chuẩn (giá `cho_khac`), ≥ 4 món chỉ cần nồi cơm điện hoặc lò vi sóng.
- **AC:**
  - Qua validate-data.
  - Món phụ có `meal_types` ⊂ {lunch, dinner}; `main` không chứa nguyên liệu cơm/bún.
  - Mỗi tag cuisine của món chính có ≥ 3 món phụ hợp (`pairs_with`).
  - Ghi chú `docs/research/recipes-mam-notes.md`.

### T-054 — Bổ sung dữ liệu theo engine-report · RESEARCH · P0
- **Mô tả:** Theo mục "Món Research cần bổ sung" của `docs/dev/engine-report-final.md`:
  - món chỉ cần lò vi sóng/không cần dụng cụ (≥ 6 mỗi bữa sáng/trưa/tối/phụ chiều);
  - ≥ 6 món trưa mang đi đạm cao;
  - món thuần chay không nước mắm, đạm cao;
  - bữa phụ có đạm 6–10 g (≥ 6 mặn);
  - món ≥ 35% kcal từ protein;
  - món ≥ 700 kcal cho tăng cơ.

  Nâng kho nguyên liệu lên ≥ 110, có nguồn.
- **Phụ thuộc:** T-053 (tránh trùng).
- **AC:** Chạy lại engine-report (nhờ DEV qua session chính, hoặc tự chạy `npm run engine-report`): p09 và p14 chuyển sang đạt hoặc chỉ thiếu ≤ 1 ngày; mọi bữa có ≥ 6 ứng viên với mỗi hồ sơ test.

### T-042b — Giá theo cửa hàng · RESEARCH · P1
- **Mô tả:** Bổ sung giá + quy cách gói ở Bách hóa Xanh, WinMart, Co.opmart cho mọi nguyên liệu (trang công khai, không đăng nhập). Có ngày khảo sát.
- **AC:** ≥ 80% nguyên liệu có giá ở ≥ 2 cửa hàng. Đây là dữ liệu cho tính năng premium "đi chợ theo cửa hàng".

### T-055 — Chuyển nội dung vào `content/` · RESEARCH · P0
- **Mô tả:**
  - Chuyển nháp sang `content/i18n/vi.json` và `content/swipe-cards.json`.
  - Bổ sung chuỗi cho màn mâm (nhãn món chính/canh/rau/cơm), placeholder ảnh, lỗi mạng/offline, giới hạn freemium (soạn sẵn, chưa dùng ở MVP) và đề xuất tên app (dùng biến `{{app_name}}`, không hard-code tên).
  - Kiểm `sample_recipe_ids` của thẻ vuốt còn tồn tại.
  - Tự viết toàn bộ; không dùng câu chữ của Mealbird.
- **Bổ sung (D-ONB-04):** gộp **mọi key** trong `mobile/tool/arb_extra.json` (chuỗi tạm Dev đã dùng cho onboarding) vào `content/i18n/vi.json`, viết lại câu chữ nếu cần nhưng giữ nguyên key. Câu chờ ở màn Tổng kết dùng "chỉ vài giây", không dùng "mất một phút". Thêm nhãn và mô tả cho 4 xu hướng sức khỏe (`health.nhieu_xo`, `health.it_duong`, `health.tot_cho_tim`, `health.it_beo`) và các bậc ngân sách (`budget.tier.economy|moderate|comfortable`).
- **AC:** Đủ key cho mọi màn trong PRD Epic 1–6, và đủ mọi key có trong `arb_extra.json`. Nút ≤ 40 ký tự. Mọi tag thẻ vuốt có ≥ 4 công thức. Sau khi giao, báo session chính để Dev làm T-074.

### T-056 — Kiểm tra tên "FitPro - Mâm đủ" + giá freemium · RESEARCH · **P0 phần tên** / P1 phần giá
- **Mô tả:**
  - **Làm sớm:** kiểm tra "FitPro - Mâm đủ", "FitPro" và "Mâm đủ": trùng tên trên Google Play/App Store, tên miền `.vn`/`.app` còn trống không, tra cứu nhãn hiệu sơ bộ (cơ sở dữ liệu công khai của Cục SHTT; WIPO Global Brand Database). "FitPro" là chữ phổ biến nên rủi ro trùng cao; báo ngay cho session chính nếu có trùng ở nhóm app sức khỏe/thể hình (nhóm 9, 41, 44).
  - Khảo sát giá gói của các app dinh dưỡng/thực đơn tại VN và đề xuất giá tháng/năm.

  Ghi `docs/research/naming-pricing.md`.
- **AC:** Bảng 3 dòng (FitPro - Mâm đủ / FitPro / Mâm đủ) với cột trùng tên store / tên miền / nhãn hiệu / mức rủi ro / khuyến nghị; phần tên giao trước, tách riêng khỏi phần giá. Đề xuất giá có ≥ 5 app tham chiếu kèm nguồn và ngày truy cập.

### T-057 — Cập nhật kịch bản test cho Flutter + API · RESEARCH · P0
- **Mô tả:** Cập nhật `docs/research/test-scenarios.md`:
  - dải ±5%;
  - ca ghép mâm (đủ chất trên tổng mâm, Ít tinh bột thì không có cơm, chay thì món phụ không nước mắm);
  - ca offline/mất mạng;
  - ca lỗi API;
  - ca placeholder ảnh;
  - ca freemium P2 (đánh dấu để sau).

  Thêm bộ ca API (đầu vào → kỳ vọng) cho `POST /v1/plans`.
- **AC:** Mọi AC trong PRD v0.2 Epic 1–4 có ≥ 1 ca. Mỗi ca có ID `TC-…` ↔ `US-…`.

### T-050 — Kiểm thử chấp nhận & báo lỗi · RESEARCH · P1
- **Mô tả:** Khi DEV báo xong (T-065: API; T-089: luồng P0 Flutter; T-091: P1), chạy kịch bản T-057 và ghi `docs/qa/test-report.md`. API test bằng HTTP request; app test trên Android emulator hoặc nhờ người dùng chạy trên máy thật.
- **AC:** Mọi ca P0 có kết quả Pass/Fail. Mỗi Fail có bước tái hiện.

---

## Tổng hợp v0.2
| Owner | DONE | CANCELLED | Còn mở P0 | Còn mở P1 | Còn mở P2 |
|---|---|---|---|---|---|
| DEV | 11 (T-002…T-012) | 17 (T-001, T-013…T-028) | 31 (T-051, T-052, T-060…T-066, T-069…T-072, T-074, T-076, T-078, T-080…T-089, T-093…T-098, T-101) + T-104, T-105 (P1) | 10 (T-067, T-068, T-073, T-077, T-099, T-103, T-106, T-090…T-092) | 5 (T-029, T-075, T-079, T-100, T-102) |
| RESEARCH | 5 (T-041, T-043, T-047, T-048, T-049) | 1 (T-044) | 12 (T-058, T-053, T-054, T-055, T-057, T-059, T-059c, T-042c, T-050b, T-050c, T-057b, T-057c) | 7 (T-042b, T-056, T-054b, T-054c, T-054d, T-057d, T-057e) · P2: T-054e · T-050 DONE | 0 |

Ghi chú: các task RESEARCH PARTIAL (T-040, T-042, T-045, T-046) đã được gộp vào T-054, T-042b, T-055.

## Phase 2 (sau T-101…T-103): giá theo siêu thị, độ tươi, bảo quản

Nguồn: PRD §13, ADR-002 (đề xuất). **Task DEV ở đây chưa giao** cho tới khi T-101, T-102, T-103 xong; Epic 7 còn chờ người dùng quyết PRD §13.4.

### T-110 — Khảo sát khả thi nguồn giá siêu thị + pháp lý · RESEARCH · P1 (làm ngay, không chen việc P0)
- **T-110 XONG (duyệt 2026-11-10):** `ingredient-sku-map-draft.json` 69 dòng: `verified_page` 49, `khong_ban` 11 (đạt AC: 60/69 = 87%), `khong_khop` 6, `chua_co_gia` 2, `chua_kiem` 1, `bulk_only` 2; không URL nào thuộc đường dẫn bị robots.txt cấm. 9 dòng còn lại dùng giá ước lượng (fallback). Dòng `khong_ban`/`khong_khop` có sản phẩm gần (vd ức gà có da) **có thể** hiện liên kết "Sản phẩm gần nhất tại BHX" nhưng không dùng giá đó cho chi phí (quyết ở T-114).
- **Lượt 5 (giao 2026-11-09):** dùng sitemap khai báo trong robots.txt (`/sitemapnew`) để tìm URL sản phẩm/danh mục cho 53 nguyên liệu `chua_kiem` (đọc sitemap bằng trình duyệt hoặc tải một lần, không crawl trang). Có URL rồi mới mở trang sản phẩm để lấy JSON-LD. Sitemap không đủ thì mới gửi câu hỏi cho người dùng **qua PM → session chính**. AC giữ ≥ 80%; không chặn việc khác (T-113 còn chờ T-101…T-104). Lượt 4 kết quả: 15/69 `verified_page`, sữa tươi `bulk_only`, nấm rơm hộp `khong_khop`.
- **Lượt 4 (D-P2-07, giao 2026-11-09):** tìm trang sản phẩm cho 59 nguyên liệu `chua_kiem` bằng công cụ tìm kiếm bên ngoài (`site:bachhoaxanh.com …`) hoặc liên kết từ danh mục đã mở được (không dùng `/tim-kiem`). Quy cách và giá lấy từ trang sản phẩm (JSON-LD), không lấy từ thẻ. Chọn SKU nhỏ nhất phù hợp hộ gia đình; chỉ có gói lớn thì `bulk_only`. Ghi nguyên liệu BHX không bán. **AC:** ≥ 80% nguyên liệu có `verified_page` hoặc ghi rõ "BHX không bán"; mỗi dòng có URL, quy cách, giá thường, ngày.
- **Lượt 3 xong một phần (2026-11-09):** robots.txt không cấm trang sản phẩm; giá có trong JSON-LD; khu vực cần đăng nhập (xử lý ở D-P2-07); map 10/69 đã kiểm.
- **Lượt 3 (D-P2-06, giao 2026-11-09):** chỉ BHX TP.HCM. (1) Đọc `robots.txt` của bachhoaxanh.com bằng trình duyệt, ghi nguyên văn + ngày; đường dẫn sản phẩm có bị `Disallow` không. (2) Cách chọn khu vực TP.HCM trên trang (có cần cookie/tham số không), giá thường và giá khuyến mãi hiển thị ở đâu. (3) Lập `ingredient_sku_map` nháp cho các nguyên liệu: URL trang sản phẩm BHX, tên sản phẩm, quy cách, nguyên liệu nào không có ở BHX. Không viết script thu thập (việc của Dev ở T-113). **AC:** `docs/research/bhx-hcm-mapping.md` + bản nháp `docs/research/ingredient-sku-map-draft.json`; nếu robots.txt cấm trang sản phẩm thì báo PM ngay (T-113 sẽ không làm adapter tự động).
- **Trạng thái (2026-11-09):** lượt 1 xong (`price-sources-feasibility.md`): không chuỗi nào có kênh được phép (D-P2-01). **Lượt 2:** đọc điều khoản website bán hàng 5 chuỗi bằng trình duyệt (không tự động), trích dẫn + ngày; quan sát tay giá ~10 mặt hàng trong 1–2 tuần tại 2 chuỗi.
- **Mô tả:** Với Bách hóa Xanh, WinMart, Co.opmart (Co.op Online), Emart, GO!/Big C, và Lotte Mart nếu có:
  - Có API công khai, chương trình đối tác/affiliate, feed sản phẩm, hay dữ liệu mở không? Ai liên hệ, điều kiện gì.
  - Điều khoản sử dụng website/app: có cấm thu thập tự động, sao chép giá, dùng thương mại không? Trích điều khoản kèm link và ngày đọc. **Không thử thu thập tự động.**
  - Rủi ro pháp lý khi hiển thị giá/khuyến mãi của bên thứ ba (sở hữu dữ liệu, cạnh tranh, quảng cáo so sánh theo luật VN). Ghi rõ điểm cần luật sư xem.
  - Giá có khác theo khu vực/cửa hàng không; tần suất đổi giá và khuyến mãi (quan sát tay 1–2 tuần trên vài mặt hàng).
  - Liên kết sản phẩm (deep link) được phép không.
- **AC:** `docs/research/price-sources-feasibility.md` có bảng mỗi siêu thị × (kênh dữ liệu, điều kiện, điều khoản trích dẫn + link + ngày, rủi ro, tần suất giá, khuyến nghị: dùng được / cần đối tác / không). Kết luận đề xuất siêu thị làm đầu tiên. Không có kết luận nào dựa trên giả định scrape được.

### T-111 — Dữ liệu hạn dùng và bảo quản nguyên liệu VN · RESEARCH · P1 (làm ngay, song song T-110)
- **Lượt 2 (2026-11-09):** tài liệu cập nhật ngưỡng/status; nháp 69 dòng ở `docs/research/storage-draft.json` (giữ ngoài `data/` tới T-112, D-P2-03).
- **Trạng thái (2026-11-09):** lượt 1 xong (`shelf-life-ingredients.md`), 69/69 "chưa có nguồn" vì FoodKeeper trả 403. PM duyệt ngưỡng (sửa) và `storage.json` ở D-P2-02. **XONG (lượt 5, 2026-11-09):** 69 dòng: ok 9, gan_dung 32, uoc_tinh_vn 17, chưa nguồn 11; đồ tươi 50/50 đạt điều kiện, có mẹo + dấu hiệu hỏng; 22 dòng chỉ có DOP hạ `gan_dung`. Bản nháp `docs/research/storage-draft.json` chờ Dev chuyển vào `data/` ở T-112. **Lượt 4 xong (2026-11-09):** ok 30, gan_dung 10, uoc_tinh_vn 16, chưa nguồn 13; đồ tươi 50 có mẹo + dấu hiệu hỏng. **Lượt 5 nhỏ (D-P2-05):** sữa tươi/sữa đậu nành theo bao bì UHT; hạ dòng chỉ có DOP xuống `gan_dung`. Sau lượt 5 → T-111 XONG. **Lượt 3 (2026-11-09):** `storage-draft.json` 69 dòng (ok 9, uoc 43, chưa nguồn 17), báo cáo `storage-draft-report.md`. **Lượt 4 theo D-P2-04:** xác nhận DOP = ngày mua; tách `gan_dung`; xử lý 7 dòng chặn; cận dưới; quy tắc khí hậu VN; `freezable`; mẹo và dấu hiệu hỏng cho đồ tươi. ~~Chờ người dùng tải FoodKeeper~~ **Đã có (2026-11-09):** người dùng tải `docs/research/sources/foodkeeper-20261109.xls` (USDA FSIS, Excel 97–2003). Sau đó: tạo `data/storage.json`, điền theo FoodKeeper, nhóm nhiệt độ phòng dùng `uoc_tinh_vn`; Dev thêm `storage.json` vào validator (`MonNgon.Tools`) khi mở T-112.
- **Mô tả:** Cho toàn bộ nguyên liệu trong `data/ingredients.json`:
  - Số ngày dùng tốt ở nhiệt độ phòng / ngăn mát / ngăn đông sau khi mua; có cấp đông được không; mẹo bảo quản ngắn; dấu hiệu hỏng.
  - Nguồn: tài liệu an toàn thực phẩm (Bộ Y tế/Cục ATTP, USDA FoodKeeper, FAO…), ghi nguồn từng dòng. Điều chỉnh cho khí hậu nóng ẩm VN nếu nguồn cho phép.
  - Đề xuất ngưỡng 4 nhãn độ tươi (US-8.1 AC1) và đối chiếu `shelf_life_days` đang có trong `prices.json`.
  - Đề xuất hợp đồng dữ liệu (trường mới trong `ingredients.json` hoặc file `storage.json`); PM duyệt trước khi Dev dùng.
- **AC:** 100% nguyên liệu có dữ liệu hoặc ghi "chưa có nguồn"; mỗi dòng có nguồn; dữ liệu qua validator; câu miễn trừ và chuỗi i18n cho thẻ "Bảo quản".

### T-112 — Độ tươi + thứ tự nấu + thẻ bảo quản · DEV · P1 phase 2 (**chưa giao**; sau T-103 và T-111)
- **Việc kèm khi mở (D-P2-03):** chuyển `docs/research/storage-draft.json` → `data/storage.json`, thêm vào validator, regen golden/fixture một lần.
- **Điều kiện mở (D-P2-02, sửa ở D-P2-04):** mọi nguyên liệu tươi trong `storage.json` có `status` ∈ `ok` | `gan_dung` | `uoc_tinh_vn` và có mẹo + dấu hiệu hỏng; nấm rơm đóng hộp không tính là tươi. Mở sau T-103. **Điều kiện dữ liệu ĐÃ ĐẠT** (T-111 xong 2026-11-09). Chỉ còn chờ T-103. Nhãn theo ngưỡng D-P2-02 (không tính ngăn đông); "Cấp đông được" là huy hiệu riêng. Việc kèm: thêm `storage.json` vào validator dữ liệu.
- **Mô tả:** US-8.1, US-8.2, US-8.3: nhãn độ tươi trên danh sách đi chợ; ưu tiên mềm xếp bữa hạn ngắn đầu tuần; gợi ý cấp đông; thẻ Bảo quản; chọn ngày đi chợ.
- **AC:** theo US-8.1…8.3 (đặc biệt US-8.2 AC2 đo trên 18 hồ sơ); không lùi AC engine hiện có (7/7, kcal ±5%, đạm, cơm, ngân sách, hiệu năng T-101).

### T-113 — Nền nguồn giá: adapter, kho giá có phiên bản, fallback · DEV · P1 phase 2 (**chưa giao**; mọi điều kiện đầu vào đã đủ: T-110 xong, ADR-002 chấp nhận, D-P2-06/07/08)
- ~~Tạm dừng (D-P2-01)~~ **Mở lại theo D-P2-06** (người dùng chấp nhận thu thập trang công khai). **Chưa giao**; giao sau T-101…T-103 (và T-104).
- **Dữ liệu đầu vào:** chuyển `docs/research/ingredient-sku-map-draft.json` → `data/ingredient_sku_map.json` khi mở task (regen golden/fixture một lần, như `storage.json` ở T-112); thêm vào validator (URL không thuộc đường dẫn robots cấm; `bhx_status` hợp lệ).
- **Phạm vi:** chỉ BHX TP.HCM. `IPriceSource`; `ManualSurveyPriceSource` (đọc `prices.json`); `BhxPublicPageSource` theo **11 quy tắc bắt buộc** trong ADR-002 mục "Adapter thu thập trang công khai"; `ingredient_sku_map` (Research cung cấp ở T-110 lượt 3); hosted service 1 đợt/ngày; snapshot giá trong DB; cờ `PriceSources:Bhx:Enabled`; API `GET /v1/shopping/prices`.
- **AC bổ sung:**
  1. Test với robots.txt giả: đường dẫn bị `Disallow` → không request; không đọc được robots.txt → không chạy đợt.
  2. Gặp 403/429/captcha (giả lập) → dừng cả đợt, không thử lại trong ngày, API trả fallback.
  3. Request tuần tự, khoảng cách ≥ 5 s (đo trong test bằng đồng hồ giả); chỉ URL trong `ingredient_sku_map`.
  4. Tắt cờ lúc đang chạy → đợt kế không chạy, API trả giá ước lượng ngay, không cần deploy.
  5. Trang đổi cấu trúc (fixture HTML khác) → > 20% không đọc được → dừng, cảnh báo, giữ snapshot cũ.
  6. Snapshot > 7 ngày → fallback `prices.json`/`cho_khac`, trường trạng thái giá đúng.
  7. Engine và golden không đổi khi bật/tắt nguồn (chi phí so ngân sách dùng snapshot cố định của tuần đã lập).
  8. Test chạy trên fixture HTML đã lưu, **không gọi BHX thật trong CI**.
  9. (D-P2-07) Đọc giá từ JSON-LD (`price`, `lowPrice`, `priceValidUntil`); trang thiếu JSON-LD tính là lỗi cấu trúc. Không gọi `/tim-kiem`, `/sp/*`, `/sieu-thi-*`; kiểm robots.txt cho từng URL. Không đặt cookie khu vực, không đăng nhập; nhãn nguồn cố định "Giá website Bách hóa Xanh" (D-P2-08, không có cờ đổi nhãn).
  10. (D-P2-08) User-agent `FitProMamDu-PriceBot/<phiên bản> (+mailto:<email>)`, email đọc từ `PriceSources:Bhx:ContactEmail` (appsettings/biến môi trường), không viết cứng; thiếu cấu hình → adapter không chạy (có test).
- **Mô tả:** Theo ADR-002: `IPriceSource`, `ManualSurveyPriceSource` (đọc `prices.json`), adapter siêu thị đầu tiên, `ingredient_sku_map`, job cập nhật, snapshot giá, engine nhận `price_snapshot_id`, API `GET /v1/shopping/prices`.
- **AC:** cùng đầu vào + snapshot → cùng tuần (golden); nguồn lỗi/cũ → fallback, ghi trạng thái; không adapter nào bật khi chưa có cơ sở pháp lý ghi trong repo.

### T-114 — UI giá BHX, khuyến mãi, liên kết sản phẩm · DEV · P1 phase 2 (**chưa giao**; sau T-113)
- **Mô tả:** US-7.1, US-7.2, US-7.4 trên tab Đi chợ (Flutter), một siêu thị BHX TP.HCM. US-7.3 (so sánh) để sau (D-P2-06). Thuộc gói miễn phí.
- **AC:** theo US-7.1, 7.2, 7.4; dòng ghi chú cố định "Chi tiết chương trình khuyến mãi vui lòng truy cập vào trang chủ siêu thị" (chuỗi i18n từ Research, D-P2-08) hiện dưới khối giá; 3 trạng thái giá (BHX cập nhật lúc … / ước lượng / không có) có widget test; dòng ghi nguồn + thời điểm; bấm liên kết mở trang sản phẩm BHX bằng trình duyệt ngoài; khuyến mãi hết hạn trước ngày đi chợ không tính.

### T-115 — Tự sửa giá đã mua (US-7.5) · DEV · P1 phase 2 (**chưa giao**; sau T-103, không phụ thuộc T-113)
- **Mô tả:** Trên tab Đi chợ, sửa "giá tôi đã trả" từng dòng; lưu trên máy; tổng "đã chi thực tế" cạnh tổng ước tính. Không gửi server, không đổi engine/ngân sách.
- **AC:** theo US-7.5 AC1–AC4; widget test sửa/xóa giá, tổng cập nhật; kiểm request mạng không chứa giá tự sửa; xóa dữ liệu (US-6.3) xóa cả giá tự sửa.

