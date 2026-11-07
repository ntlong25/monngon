# Ghi chú T-053 (món phụ cho ghép mâm) và T-054 (bổ sung theo engine-report)

Ngày: 06/11/2026 · Owner: RESEARCH · Chỉ sửa `data/` và `docs/research/`.

Căn cứ: `docs/pm/backlog.md` (hợp đồng v0.2, mục T-053, T-054), `docs/pm/prd.md` §6.2 và AC5/AC6. Engine TS vẫn là bản tham chiếu, chưa đọc `dish_role`.

## Tổng quan số liệu

| Chỉ số | Trước | Sau |
|---|---|---|
| Công thức | 137 | **204** |
| — `full_meal` (không đổi) | 137 | 137 |
| — `main` (món chính không cơm) | 0 | **26** |
| — `soup` (canh) | 0 | **16** |
| — `side_veg` (rau) | 0 | **13** |
| — `carb_base` (cơm/bún/khoai) | 0 | **4** |
| — snack mới (T-054) | 0 | **8** |
| Nguyên liệu | 46 | **53** (+7 rau/nấm/đậu) |
| Dòng giá (`prices.json`) | 49 | **56** (+7 `cho_khac`, ước tính) |

## T-053: món phụ cho ghép mâm

Yêu cầu backlog và kết quả:

| Yêu cầu | Kết quả |
|---|---|
| ≥ 15 `soup`, ≥ 6 chay không nước mắm | 16 canh; **7** chay (không có `nuoc_mam`) |
| ≥ 12 `side_veg`, ≥ 6 chay | 13 món rau; **11** chay |
| 3–4 `carb_base` | **4**: cơm trắng, cơm gạo lứt, bún tươi luộc, khoai lang hấp |
| ≥ 20 `main` không cơm/bún | **26**, đã kiểm: không có `com_trang`, `gao_lut_nau_chin`, `bun_pho_nau_chin`, `khoai_lang` |
| ≥ 6 `main` chay/đậu phụ đạm cao | **8** chay, **9** có đậu phụ/tempeh/đậu lăng/đậu xanh |
| ≥ 6 `main` chỉ cần lò vi sóng | **7** (`equipment = [lo_vi_song]`) |
| `meal_types` ⊂ {lunch, dinner} | Đúng cho `main`, `soup`, `side_veg`, `carb_base` |
| Mỗi tag cuisine của món chính có ≥ 3 món phụ | Đã kiểm, không có tag nào thiếu |
| Gắn `pairs_with` | Có. Canh ghép với mọi tag món chính trừ `canh`; rau ghép với mọi tag |

**Cách tạo `main`:** tách từ 26 món mặn lunch/dinner đang có cơm: bỏ dòng `carb`, đặt `dish_role = main`, tính lại `is_low_carb`. Ưu tiên 7 món lò vi sóng, 8 món chay/đậu, còn lại theo đạm khác nhau. ID có hậu tố `_mam`. Các bước có nhắc "cơm" được thay bằng "Dọn nóng, ăn kèm canh và rau trong mâm."

**Món phụ mới:** canh và rau viết tay, gram cố định cho rau (`min_g = max_g = grams`), đạm nhẹ cho canh thịt/tôm/đậu hũ. Món chay không dùng nước mắm. Một món canh bị trùng ID với món `full_meal` cũ, nên đặt tên `canh_bi_xanh_tom_phu`.

**Nguyên liệu mới** (`data/ingredients.json`, tra FDC SR Legacy trên web, không dùng API vì DEMO_KEY đang bị giới hạn):

| id | Nguồn | Ghi chú |
|---|---|---|
| `rau_den` | FDC 168385 / NDB 11003 | Xơ không có trong bản ghi, để 0. Kcal lệch 26% so với 4/4/9 (đã có cảnh báo) |
| `gia_do` | FDC 169957 / NDB 11043 | Mầm đậu xanh |
| `nam_rom` | FDC 168582 / NDB 11989 | Dạng đóng hộp, đã ráo nước |
| `dau_co_ve` | FDC 169961 / NDB 11052 | Đậu que xanh |
| `dua_chuot` | FDC 168409 / NDB 11205 | Có vỏ |
| `dau_bap` | FDC 169260 / NDB 11278 | Okra |
| `cai_thao` | FDC 169979 | Pe-tsai |

Giá các nguyên liệu mới là ước tính `cho_khac`, gắn nhãn "(ước tính)".

**Chưa có trong kho:** rau muống, mồng tơi, bí đao (không có trong SR Legacy). Trong canh và rau, dùng rau dền, bí xanh, cải ngọt làm thay thế. Canh chua và nộm (me, giấm) cũng chưa làm được vì thiếu nguyên liệu.

## T-054: bổ sung theo engine-report

Mục "Món Research cần bổ sung" trong `docs/dev/engine-report-final.md` đã cũ. Lấy danh sách ô ⚠ từ ma trận phủ hiện tại (`npm run engine-report`):

| Ô ⚠ trước | Số món trước | Số món sau |
|---|---|---|
| thuần chay · snack_am | 5 | **9** |
| thuần chay · snack_pm | 3 | **6** |
| chay · snack_pm | 5 | **9** |
| không trứng · snack_pm | 5 | **11** |
| không đậu nành · snack_pm | 5 | **10** |
| không cá · snack_pm | 5 | **9** |

8 bữa phụ mới (đạm 6–10 g; tính từ gram × `per_100g`):

| id | Kiểu | Đạm (g) | Chay | Ghi chú |
|---|---|---|---|---|
| `sn_dau_lang_luoc_hanh` | mặn | 8.6 | thuần chay | đậu lăng |
| `sn_tempeh_chien_xi_dau` | mặn | 8.1 | thuần chay | tempeh, có đậu nành |
| `sn_che_dau_xanh` | ngọt | 7.2 | thuần chay | đậu xanh + đường |
| `sn_nam_rom_dau_hu_xao` | mặn | 6.9 | thuần chay | đậu hũ 40 g; nấm rơm không tính đạm |
| `sn_uc_ga_xe_nuoc_mam` | mặn | 9.0 | không | ức gà |
| `sn_bo_xao_sa_ot` | mặn | 8.3 | không | thịt bò |
| `sn_trung_op_ca_chua` | mặn | 6.3 | chay trứng | trứng |
| `sn_ca_basa_hap_gung` | mặn | 9.1 | không | cá basa, có cá |

**Chưa làm trong lượt này**
- Kho nguyên liệu: 53/≥110 theo mô tả T-054. Cần thêm khoảng 57 nguyên liệu, mỗi món tra FDC thủ công. Đây là việc lớn, chưa làm.
- Mật độ đạm ≥ 35% kcal: 55/140 món trưa/tối đã đạt. Không thêm.
- Món ≥ 700 kcal cho tăng cơ: 16 món đầy đủ trưa/tối đã đạt. Không thêm.

## Kiểm tra

- `npm run validate-data`: 0 lỗi, 1 cảnh báo (kcal của `rau_den`, đã ghi chú trong nguồn).
- `npm test`: **172/173 pass.** Một test lỗi: `src/golden/export.test.ts` "xuất hai lần ra cùng từng byte" hết thời gian chờ 5 s. Chạy riêng test này mất khoảng 3,3 s; khi chạy cả bộ thì vượt 5 s. Nguyên nhân là dữ liệu tăng từ 137 lên 204 công thức, không phải lỗi dữ liệu. Sửa ở phía Dev (tăng timeout hoặc tối ưu `buildGolden`), vì RESEARCH không được sửa `src/`.
- `npm run engine-report` (14 hồ sơ, bộ cũ): 14/14 hồ sơ 7/7; 98/98 ngày đạt; 0 vi phạm ràng buộc cứng; ma trận phủ không còn ô ⚠.

## Rủi ro cho Dev

1. **Engine TS chưa đọc `dish_role`.** Engine coi mọi món là `full_meal`, nên `main` và `soup` có thể bị chọn làm trọn suất trong bản tham chiếu. Kết quả báo cáo vẫn 98/98, nhưng cần Dev lọc `dish_role === "full_meal"` (hoặc tương đương) trước khi dùng số liệu. Kcal của `main` chỉ khoảng 145–400, không đủ làm trọn suất.
2. **Schema TS/C#** cần thêm `dish_role` và `pairs_with`. Zod hiện đang bỏ qua trường lạ, nên validate-data vẫn qua.
3. **Chỉ số ≥ 60% bữa trưa/tối là mâm** (AC T-066) đo được khi engine C# chạy, không đo được ở đây.
4. **`is_low_carb` của `main`:** 25/26 món có đạm ≥ 20 g được gắn `true`, vì không có dòng tinh bột. Cần PM xác nhận ngữ nghĩa này (xem cũng mục mở của v0.1).

## Lô bổ sung cho engine C# (theo docs/dev/engine-report-mam.txt)

Mục tiêu từ session chính: mỗi hồ sơ ≥ 40% bữa trưa/tối là mâm, toàn bộ ≥ 70%.

Thay đổi dữ liệu (247 công thức: 145 `full_meal`, 51 `main`, 20 `soup`, 24 `side_veg`, 7 `carb_base`):

- **`is_low_carb` cho canh và rau:** đặt `true` cho mọi `soup`/`side_veg` không có dòng tinh bột (29 món T-053 đã đổi). Engine C# dùng cờ này để lọc mâm "ít tinh bột", nên trước đây p05 không có canh/rau nào hợp lệ. Lưu ý: đây là nghĩa "không tinh bột", khác với quy tắc sinh tự động ở mục trên (đạm ≥ 20 g). PM cần xác nhận định nghĩa này.
- **`main` chay ít tinh bột, giàu đạm (+12):** đậu hũ, tempeh, đậu lăng, đậu xanh, nấm; có thêm lạc và vừng để đủ năng lượng. Đạm dùng dòng khoảng (`min_g`–`max_g` = 0,67–1,67 lần) để engine scale; dầu ăn và lạc/vừng cố định.
- **`main` mang đi (+10):** cá thu kho, thịt bò kho, gà xé, đùi gà rim, thịt heo kho trứng, cá basa kho, tôm rim, thịt heo kho hành, tempeh kho chay, đậu hũ xào sả ớt. Đều ăn nguội được.
- **`soup` chỉ lò vi sóng (+4):** bí xanh trứng, cải thảo đậu hũ, cà chua trứng, cải ngọt thịt băm.
- **`side_veg` chỉ lò vi sóng (+5):** su su, bắp cải, cải ngọt, đậu cô ve, bí xanh.
- **`side_veg` mang đi (+6)** và **`carb_base` mang đi (+2, không cần dụng cụ):** rau ăn nguội và cơm nguội.
- **`carb_base` lò vi sóng (+1):** cơm hâm.

### Kết quả engine C# (`dotnet run --project backend/MonNgon.Tools -- engine-report`)

| Hồ sơ | % bữa ghép mâm trước | sau |
|---|---|---|
| p05 thuần chay ít tinh bột | 0% | **100%** (7/7 ngày) |
| p09 chỉ lò vi sóng | 0% | **57%** |
| p11 hộ 2 lớn + 2 trẻ | 30–40% | **64%** |
| p13 nhiều món ghét | 7–43% | **86%** |
| p14 hộ 3 người, mang đi | 0–29% | **29%** (không đổi, xem dưới) |

- Toàn bộ: **83%** (trước 62%); 14/14 hồ sơ đạt 7/7; 98/98 ngày đạt.
- Chưa đạt mục tiêu 40% cho **p14**. Nguyên nhân nằm ở engine chứ không phải dữ liệu: `backend/MonNgon.Engine/Mam.cs` dòng 130 đặt `MealTypes` của mâm mang đi = `main.MealTypes − lunch`, nên mâm mang đi không bao giờ vào được bữa trưa. Dữ liệu không thể sửa được lỗi này. Cần Dev kiểm tra.

### Kiểm tra

- `npm run validate-data`: 0 lỗi (1 cảnh báo kcal của `rau_den`, đã ghi).
- `npm run export-golden` đã chạy: 49 tệp, `golden/` cập nhật.
- `npm test`: 173/173 pass.
- `dotnet test backend/MonNgon.sln`: 110 + 17 pass.
- `engine-report` (C#): 14/14 hồ sơ, 98/98 ngày, 0 vi phạm ràng buộc cứng.

## D-MAM-01 — món phụ giá rẻ cho ghép mâm (07/11/2026)

Yêu cầu (backlog T-053, PM D-MAM-01): trong số canh/rau, ≥ 8 món ≤ 8.000 ₫/khẩu phần chuẩn (giá `cho_khac`), ≥ 4 món chỉ cần nồi cơm điện hoặc lò vi sóng; p14 (3 người lớn, ngân sách 1,2 triệu, lunch mang đi) là hồ sơ cần cải thiện.

**Kết quả kiểm tra dữ liệu (trước khi thêm món):**
- Canh + rau: 53 món; **≤ 8.000 ₫: 36** (sau đổi quy cách gói ngày 07/11, trước đó 40). Chỉ dùng lò vi sóng/nồi cơm điện: **7** món. Yêu cầu đã đạt; không cần thêm canh/rau mới.
- Vấn đề thật của p14 là **mâm trưa mang đi**: canh không mang đi được (`lunch_style` = hot), nên mâm trưa mang đi chỉ gồm món chính mang đi + rau mang đi + cơm mang đi. Có 12 món chính mang đi (giá 10.000–63.000 ₫/khẩu phần), 6 rau mang đi, 2 cơm mang đi. Món chính mang đi đắt, nên ngân sách không đủ cho nhiều mâm.

**Đã thêm (5 món, đều dùng nguyên liệu có sẵn, chỉ cần bếp):**

| id | Vai trò | Giá ước tính (`cho_khac`) |
|---|---|---|
| `bi_xanh_luoc_an_nguoi` | rau mang đi | 2.416 ₫ |
| `bap_cai_luoc_an_nguoi` | rau mang đi | 4.516 ₫ |
| `cai_thao_luoc_an_nguoi` | rau mang đi | 3.316 ₫ |
| `rau_den_luoc_an_nguoi` | rau mang đi | 4.816 ₫ |
| `khoai_lang_luoc_mang_di` | cơm/tinh bột mang đi | 5.100 ₫ |

Tất cả `meal_types` ⊂ {lunch, dinner}, `lunch_style` = [packed], `is_low_carb` = true cho rau, false cho khoai.

**Kết quả engine-report C# (16/16 hồ sơ 7/7, 112/112 ngày):** % bữa ghép mâm trước → sau:
- p14 (lunch mang đi, ít dụng cụ): **21% → 29%**
- p02: 7% → 36%; p11: 7% → 21% (xem ghi chú bên dưới)
- p01: 100% → 93%; các hồ sơ khác không đổi.

Mục tiêu p14 ≥ 40% (T-077) và ngưỡng 20% (D-MAM-01) — p14 vượt 20% nhưng chưa đạt 40%. Nguyên nhân còn lại là món chính mang đi đắt; thêm rau/cơm rẻ không đủ. Đề xuất: thêm món chính mang đi rẻ (đậu hũ, trứng, cá rẻ) — cần PM duyệt vì không nằm trong yêu cầu canh/rau/cơm.

**Ghi chú về test C# (quan trọng):** sau khi thêm 5 món, 2 test macro (tổng macro bữa lệch 12,1 kcal so với tổng các món) bắt đầu lỗi:
- `DessertTests.Moi_bua_trua_toi_co_dung_mot_trang_mieng_tinh_vao_macro` (DessertTests.cs:77),
- `MamTests.Mam_co_dung_mot_mon_dam_chinh_va_dishes_cong_lai_bang_bua` (MamTests.cs:59),
- `V1Tests.Plans_auto_tra_dishes_...` (V1Tests.cs:235, dòng "kcal trace lệch macros bữa").

Khi bỏ riêng từng nhóm món mới (món rau hoặc món cơm) lỗi vẫn còn; khi dùng dữ liệu trước lượt này thì các test đó pass. Có nghĩa là lỗi nằm ở cách engine tổng hợp macro cho một số tổ hợp mâm (Dev, `Mam.cs` / bước tổng hợp bữa), không phải do một món cụ thể. Chưa tìm được nguyên nhân trong dữ liệu. Nếu Dev không sửa kịp, có thể giữ lại dữ liệu cũ bằng cách khôi phục `scratchpad/recipes_before_mam3.json`.

Các test "Hieu_nang_duoi_2_giay" lỗi trong lần chạy đầy đủ nhưng pass khi chạy riêng (lỗi thời gian do tải máy).

## D-MAM-01 — lần 2: món chính mang đi giá rẻ (07/11/2026)

PM duyệt (session chính): thêm 8–10 món chính mang đi giàu đạm, ≤ 15.000 ₫/khẩu phần (cho_khac), mục tiêu p14 ≥ 40% mâm.

**Đã thêm 8 món** (đều dùng nguyên liệu có sẵn, chỉ cần bếp, `lunch_style` = [packed]):

| id | Đạm (g/khẩu phần) | Giá (₫) |
|---|---|---|
| `main_dau_hu_sot_ca_chua_mang_di` (chay) | 27,2 | 11.146 |
| `main_dau_hu_kho_tieu_mang_di` (chay) | 27,1 | 7.800 |
| `main_trung_xi_dau_mang_di` | 20,0 | 13.610 |
| `main_thit_heo_xay_kho_mang_di` | 21,9 | 13.128 |
| `main_dau_lang_ham_mang_di` (chay) | 15,5 | 7.966 |
| `main_dau_xanh_man_mang_di` (chay) | 15,0 | 6.308 |
| `main_thit_heo_nac_kho_tieu_mang_di` | 17,2 | 14.060 |
| `main_trung_hap_thit_mang_di` | 23,5 | 13.480 |

**Đã thử rồi bỏ:**
- `main_dui_ga_hap_gung_mang_di` (đùi gà hấp gừng, 13,9 g đạm) và `main_ca_basa_hap_gung_mang_di` (cá basa hấp gừng, 12,6 g đạm): đạm thấp; khi có cả hai, hồ sơ p02 (1.350 kcal, 110 g đạm) hụt đạm 1 ngày.
- `main_dau_hu_hap_nam_mang_di` (đậu hũ hấp nấm, 28,9 g đạm, 10.180 ₫): thêm cùng `main_trung_hap_thit_mang_di` làm p02 hụt đạm; thêm riêng món nào cũng được. Chọn `main_trung_hap_thit_mang_di` vì khi thêm riêng nó không làm ước tính ngân sách (BudgetTests) giảm 1,2% như món đậu hũ hấp nấm.
- Chưa có cá rẻ dưới 15.000 ₫ đạm cao; ức gà 80 g ≈ 16.800 ₫ vượt ngưỡng; thịt gà xé không đạt ngưỡng ở khẩu phần 60 g (13,5 g đạm).

**Kết quả engine-report C# (16/16 hồ sơ 7/7, 112/112 ngày):** % bữa ghép mâm p14 **21% → 100%**; p02 7% → 100%; p11 7% → 21%; p01 100% → 93%; p09 43%.

**Test C#:** toàn bộ `dotnet test backend/MonNgon.sln` xanh: Api 39/39, Engine 171/171 (kể cả 3 test macro đã nêu ở trên, lần chạy này đều pass với dữ liệu này).

**Ghi chú:** health_tags của các món mới được tính lại bằng `scratchpad/health_calc.mjs` theo quy tắc trong `health-tags.md`.
