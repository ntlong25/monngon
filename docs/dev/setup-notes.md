# Dev setup notes (lượt 0 — chuẩn bị, chưa scaffold)

Ngày kiểm tra: 2026-11-06. Nguồn: spec "Mealbird — Đặc tả chức năng chi tiết" (mục 4.8, 4.9, 5, 6, 7) + khung hình `docs/video-frames/`.
Không cài gì toàn cục; chỉ chạy lệnh đọc (`-v`, `npm view`, liệt kê thư mục).

## 1. Môi trường máy

| Hạng mục | Kết quả |
|---|---|
| OS / phần cứng | Windows 11 Pro, i5-12400F, RAM ~15.7 GB, ổ F: trống ~54 GB |
| Node | v24.11.1 (npm 11.6.2, npx 11.6.2) |
| git | 2.52.0.windows.1 (thư mục dự án **chưa** là repo) |
| pnpm / yarn | không có (dùng npm là đủ) |
| expo / eas CLI | không cài toàn cục — không cần: dùng `npx create-expo-app` và `npx expo` |
| npm registry | https://registry.npmjs.org/ truy cập được (`npm view expo version` → 58.0.23) |
| Java | OpenJDK 21.0.9 (JBR của Android Studio), `JAVA_HOME=C:\Program Files\Android\Android Studio\jbr` |
| Android SDK | Có tại `%LOCALAPPDATA%\Android\Sdk` (build-tools 34–37, cmdline-tools, emulator, platform-tools, system-image android-36 Google Play x86_64). `ANDROID_HOME` **chưa** đặt; `adb`/`emulator` chưa nằm trong PATH |
| AVD | `Pixel_7`, `DiDau_Test` đã có sẵn |
| Chưa xác minh | Hyper-V/HAXM bật hay chưa (cần quyền admin để kiểm tra) — cần để emulator chạy mượt |

Kết luận: đủ để dev và chạy thử trên Android emulator. Chỉ cần đặt biến môi trường theo phiên khi cần
(`$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"` và thêm `platform-tools`, `emulator` vào PATH của phiên) — không sửa cấu hình hệ thống.
iOS không build được trên Windows; iOS/iPad chỉ kiểm tra qua Expo Go trên thiết bị thật hoặc EAS Build (cloud) về sau.

## 2. Khả thi stack Expo React Native + TypeScript

- **Khả thi.** Node 24 + npm đủ; `create-expo-app` chạy qua `npx` không cần cài toàn cục. Expo mới nhất trên registry: 58.x, RN 0.88.x.
- Khi scaffold: dùng đúng phiên bản TypeScript/Jest mà template Expo đi kèm (registry hiện có TypeScript 7.x, vitest 5.x — **đừng** tự nâng lên bản mới nhất, dễ lệch với Metro/babel của Expo). Cần smoke-test `npx expo start` + `npx expo export --platform web` ngay ở task scaffold.
- Chạy thử: (a) Expo web (`expo start --web`) — nhanh nhất cho vòng lặp UI, tiện cho Playwright/browser pane; (b) Android emulator Pixel_7 (dùng được ngay); (c) Expo Go trên điện thoại/iPad thật.
- Rủi ro: Expo Go đôi khi chậm hỗ trợ SDK mới nhất → dùng development build hoặc web nếu gặp; Windows path dài (đặt dự án gần gốc ổ đĩa — `F:\WORKING\outside\mon-ngon` ổn); đường dẫn có dấu cách thì tránh.
- NFR-06 (giữ màn hình sáng) → `expo-keep-awake`. NFR-03 đa ngôn ngữ → `i18next` + `expo-localization`; định dạng `Intl.NumberFormat('vi-VN')` (600.000 ₫, 1.350 kcal) — lưu ý Hermes cần Intl đầy đủ, kiểm tra trên Android. NFR-07 tạo tuần chạy nền → engine là hàm thuần, chạy trong worker/JS thread chia nhỏ (`await` nhường luồng) hoặc `InteractionManager`.
- Lưu trữ MVP: offline-first, `expo-sqlite` (hoặc MMKV + JSON) trên máy; dữ liệu seed (nguyên liệu, món, giá) đóng gói trong app dạng JSON. Chưa cần backend/AI online ở MVP (engine tất định, F-ENG-03/04). Backend (Supabase hoặc tự dựng) để sau cho đồng bộ/paywall.
- Điều hướng: `expo-router`. State: Zustand. Form/validate: zod (dùng chung schema cho dữ liệu seed và hồ sơ người dùng).

## 3. Cấu trúc thư mục đề xuất

```
mon-ngon/
  app/                      # expo-router: (onboarding)/, (tabs)/week, recipe/[id], shopping, settings, paywall
  src/
    domain/                 # THUẦN TS, không import react/expo → test bằng node
      types.ts              # User, Profile, Preferences, Ingredient, Recipe, WeekPlan, PlanMeal, ShoppingList (spec mục 5)
      nutrition/
        targets.ts          # BMR, kcal ngày, cân nặng tham chiếu, protein, trần 35%, sàn (mục 4.8)
        macros.ts           # Σ gram × per_100g / 100, kèm dấu vết fdc_id (F-ENG-04, NFR-01)
      engine/
        filters.ts          # lọc cứng: dị ứng, chay, loại trừ, dụng cụ (F-ENG-02)
        scoring.ts          # điểm mềm: khẩu vị, cuisine, tái sử dụng (F-ENG-06/07)
        planner.ts          # lập tuần: chọn món → gán bữa → co giãn khẩu phần → sửa
        scaler.ts           # co giãn gram theo ngày (bài toán nhỏ, xem §4)
        cost.ts             # giá theo gói (pack) + dư thừa
        validator.ts        # kiểm 7 ngày: ≥ sàn protein, trong dải kcal, ≤ ngân sách (F-ENG-05)
        rng.ts              # PRNG có seed (mulberry32)
      shopping.ts           # gộp nguyên liệu → danh sách đi chợ (need_g, packs, leftover)
      units.ts              # cốc/thìa/tép → gram; metric/imperial
    data/
      seed/                 # ingredients.vi.json, recipes.vi.json, prices.vi.json (+ schema zod)
      db.ts                 # expo-sqlite / repository
    features/               # onboarding, swipe-taste, week, recipe, shopping, paywall (UI + hooks)
    i18n/                   # vi.json, en.json, format.ts
    ui/                     # theme tokens, component dùng chung
  tests/                    # fixtures + golden + property tests (hoặc đặt *.test.ts cạnh file)
  scripts/                  # validate-seed.ts, simulate-week.ts (chạy engine hàng loạt hồ sơ giả)
  docs/
```

Nguyên tắc: `src/domain` không phụ thuộc UI → test chạy nhanh bằng Jest/Vitest trên Node, tái dùng nếu sau này có backend.

## 4. Thiết kế kỹ thuật engine lập tuần

### 4.1 Chỉ tiêu (mục 4.8) — `targets.ts`
Công thức đã đối chiếu với ví dụ spec (nam 30 tuổi, 177.8 cm, 81.6 kg, vận động vừa, giảm mỡ):
- BMR = Mifflin-St Jeor: `10·kg + 6.25·cm − 5·tuổi + (nam +5 / nữ −161)` → 1782.25 (spec: 1.783 ✓).
- kcal = round50(BMR × hệ số vận động × {0.8, 1.0, 1.1}) → 2.763 → 2.210 → **2.200** ✓.
- Cân nặng tham chiếu: giảm mỡ → `min(kg, 25·m²)` = 79.0; còn lại = kg thật.
- Protein mục tiêu = round5(g/kg × cân tham chiếu) = 2.2 × 79 → **175 g** ✓. Trần = floor5(0.35·kcal/4); sàn = 1.76 × cân tham chiếu (giảm mỡ) hoặc 1.2 × cân thật; **sàn thắng trần**.
- Dải kcal tuần: `[0.95·target, target]` (giả định −5%…0% của spec, [S]) — để thành tham số cấu hình.
- Câu hỏi mở cần PM chốt: công thức BMR (Mifflin có vẻ đúng nhưng spec không nêu tên), "nữ" dùng −161, làm tròn lúc nào (floor/round), và giá trị "Mục tiêu" nào cho nhóm "Săn chắc hơn".
- Test vàng: ví dụ trên + ca nữ nhỏ cân (110 g/1.350 kcal chạm trần 35%) + các biên activity/goal.

### 4.2 Dữ liệu đầu vào
Ingredient (per_100g, dị ứng, tag chế độ ăn, giá theo gói), Recipe (RecipeIngredient: grams_per_serving, role, swappable_group), Preferences. Món Việt/mâm cơm: cơm là một nguyên liệu thật (gạo/cơm trắng) để macro đúng. Macro **chỉ** tính từ gram × per_100g (không nhập tay, không do AI sinh) và lưu dấu vết fdc_id/nguồn bảng VN.

### 4.3 Thuật toán (tất định, theo seed, 5 pha)
1. **Lọc cứng** (F-ENG-02): loại món có nguyên liệu dị ứng/loại trừ/không muốn, trái chế độ chay/pesc, thiếu dụng cụ, `blocked_recipes`. Không có điểm mềm nào được phép phá lọc này. Nếu còn quá ít món → trả lỗi rõ ràng "không đủ món" thay vì nới lọc.
2. **Chọn nhóm món ~11 món / 21 bữa** (F-ENG-06): theo meal_slots. Điểm mềm = khẩu vị (SwipeEvent/cuisine_likes) + mật độ protein (g protein/kcal) + chi phí/phần + dùng chung nguyên liệu (giảm số gói phải mua) + thời gian nấu ≤ ~7 giờ/tuần. Chọn tham lam có ngẫu nhiên có seed (top-k) để tạo nhiều ứng viên.
3. **Gán món vào 21 bữa** (`batch_group_id`): mỗi món nấu 1 lần, ăn 2–3 bữa; sắp xếp để tổng protein/kcal ngày tương đối cân bằng, hot/cold và slot đúng.
4. **Co giãn khẩu phần theo từng ngày** (`scaler.ts`): với món đã gán, mỗi bữa có hệ số `s ∈ [0.6, 1.6]` (có thể giới hạn theo role: chỉ co giãn tinh bột/protein/rau, không co gia vị) và tùy chọn "booster" (trứng, đậu phụ, ức gà, sữa chua…) ≤ N gram. Ràng buộc mỗi ngày d:
   - `Σ protein ≥ sàn`, `kcal_min ≤ Σ kcal ≤ kcal_max` (tuyến tính theo `s`) → LP nhỏ (≈3 biến × vài ràng buộc). Giải bằng bộ giải đơn giản tự viết (vòng chiếu/hai pha) hoặc `javascript-lp-solver`; sau đó **làm tròn gram** về bội số thực tế (5 g) và kiểm lại.
   - Hàm mục tiêu: tối thiểu độ lệch khỏi khẩu phần chuẩn (ít "bẻ" món nhất) + tối thiểu chi phí.
   - Mục tiêu protein-trong-calo (vd. 175 g trong 2.200 kcal = 32% calo) có thể **không khả thi** với món đã chọn → quay lại pha 2 đổi món có mật độ protein cao hơn.
5. **Ngân sách & sửa** (`cost.ts`): chi phí = Σ gói phải mua (làm tròn lên theo `pack_grams`, giá `is_estimate`), không phải Σ gram × đơn giá. Tổng > ngân sách → local search: đổi món đắt nhất sang món rẻ cùng slot/nhóm, thay nguyên liệu trong `swappable_group`, tăng tái sử dụng; lặp tới khi hết ngân sách thời gian (vd. 2–3 s) hoặc không cải thiện.
6. **Validator** (F-ENG-05, NFR-02): hàm thuần `validate(plan, target, budget) → {ok, daysShort:[{date, proteinShortG, kcalDelta}], overBudget}`. Không đạt vẫn trả tuần với `status='partial'`, `days_missing`, `shortfall_summary`; không che ngày thiếu. Engine có chế độ "tiếp tục tối ưu nền" (generator/yield theo lát thời gian, hủy được).

AI (nếu thêm sau, F-ENG-03): chỉ đề xuất món/nguyên liệu/gram dưới dạng JSON; mọi con số vẫn qua `macros.ts` + validator, nên engine tất định là đường chính và đường dự phòng.

Độ phức tạp: 21 bữa × vài trăm món là nhỏ; mục tiêu < 1–2 s trên máy, ≪ 60 s (NFR-07).

### 4.4 Cách test
- **Unit (Jest hoặc Vitest, theo template Expo)**: `targets` (golden theo ví dụ spec + biên), `macros` (Σ gram×per_100g, làm tròn, dấu vết), `filters` (dị ứng/chay không bao giờ lọt), `cost` (làm tròn gói, dư thừa), `units`.
- **Validator**: bảng ca đúng/sai: thiếu protein 1 ngày, vượt kcal, vượt ngân sách, nhiều lỗi cùng lúc → thông báo đúng số ngày/mức thiếu.
- **Property-based (fast-check)**: với hồ sơ/preferences ngẫu nhiên và bộ seed cố định: (a) không bao giờ có món chứa dị ứng/loại trừ; (b) macro mỗi bữa luôn = tính lại từ nguyên liệu; (c) nếu `status='ready'` thì cả 7 ngày ≥ sàn, trong dải kcal, ≤ ngân sách; nếu `partial` thì `days_missing` khớp validator; (d) cùng seed → cùng kết quả; (e) không crash khi lọc còn quá ít món.
- **Mô phỏng hàng loạt** (`scripts/simulate-week.ts`): ~200 hồ sơ giả × mục tiêu × ngân sách; báo cáo tỷ lệ `ready`, thời gian, ngân sách trung bình → dùng để chỉnh dải khẩu phần và chất lượng seed.
- **Kiểm tra dữ liệu seed** (`validate-seed.ts`): schema zod, mọi RecipeIngredient trỏ tới Ingredient có per_100g, kcal ≈ 4P+4C+9F (±10%), có tag dị ứng, có giá.
- **UI**: React Native Testing Library cho form onboarding; smoke trên Expo web/Android emulator.

### 4.5 Rủi ro kỹ thuật cần PM/Research chốt
1. **Bộ seed** là nút thắt lớn nhất: số món Việt + nguyên liệu + giá (spec: 169 nguyên liệu; USDA FDC hay Bảng TPDD Việt Nam; giá Bách hóa Xanh/WinMart không có API chính thức — cần dữ liệu nhập tay/ước tính, gắn `is_estimate`). Không có seed đủ tốt thì engine không chứng minh được.
2. Khả thi của sàn protein với món Việt carb nặng (cơm, bún) và ngân sách thấp — dự kiến có ca `partial`; UI phải xử lý trung thực.
3. Ảnh món: không dùng ảnh của Mealbird; cần nguồn ảnh riêng/placeholder.
4. Bản quyền/nhãn hiệu: tên, logo, câu chữ phải khác Mealbird (đã ghi trong brief).

## 5. Đề xuất cho các task sau
Thứ tự khớp mục 7 của spec: (T0) scaffold Expo + TS + test runner + CI script; (T1) `domain/types` + `targets.ts` + test vàng; (T2) schema + seed mẫu nhỏ (~30 nguyên liệu, ~15 món) + `macros`; (T3) filters + validator; (T4) planner + scaler + cost; (T5) simulate/property tests; sau đó UI onboarding → tuần → công thức → đi chợ → đổi món/ăn ngoài → paywall. Làm engine/domain trước vì thuần TS, kiểm chứng được mà chưa cần UI.
