# Đợt mở băng dữ liệu D1 (07/11/2026)

Owner: RESEARCH · Căn cứ: D-QA-07 (PM), T-042c (gạo sống, D-SHP-02), T-054b (rau muống, nhieu_xo ≥ 4 g D-HLT-02, đếm món có lạc D-QA-06).
Phạm vi: `data/` và `docs/research/`. Không sửa mã, không sửa `content/i18n` ngoài một khóa mới.

## 1. Thay đổi

### Nguyên liệu (`data/ingredients.json`): 66 → 69
| id | Nội dung | Nguồn (USDA SR Legacy) |
|---|---|---|
| `gao_te` | Gạo tẻ (sống), aisle `gao_do_kho`, `default_pantry: true`, `shelf_life_days: 180` | FDC 168877, đã đọc trực tiếp trang food-details 07/11/2026: 365 kcal, đạm 7,13, béo 0,66, carb 80, xơ 1,3 |
| `gao_lut` | Gạo lứt (sống), `default_pantry: false` | FDC 169703, đã đọc trực tiếp: 367 kcal, đạm 7,54, béo 3,2, carb 76,2, xơ 3,6 |
| `rau_muong` | Rau muống (PROXY: rau bina), `aliases` gồm "rau muống", "rau muong" | FDC 168462 (Spinach, raw), đã đọc trực tiếp: 23 kcal, đạm 2,86, béo 0,39, carb 3,63, xơ 2,2 |

Rau muống không có trong SR Legacy; dùng rau bina làm proxy (ghi rõ trong `source.note`).

### Hợp đồng `purchase_as` (`data/ingredients.json`)
- `com_trang` → `{ingredient_id: "gao_te", factor: 0.36}`
- `gao_lut_nau_chin` → `{ingredient_id: "gao_lut", factor: 0.34}`

Hệ số đặt theo kcal (xem mục 3), không theo 0,4 / 0,40–0,45 trong D-SHP-02. Lý do ở mục 3.

### Giá (`data/prices.json`): 70 → 73 dòng (cùng quy ước "ước tính", ngày 07/11/2026)
- `gao_te` cho_khac: bao 1 kg, 22.000 ₫
- `gao_lut` cho_khac: bao 1 kg, 30.000 ₫
- `rau_muong` cho_khac: 500 g, 15.000 ₫

### Món mới (`data/recipes.json`): 324 → 327 (cả ba đều nhắm rau muống)
| id | Vai trò | Ghi chú |
|---|---|---|
| `rau_muong_luoc_cham_toi` | side_veg | luộc, chấm tỏi muối; trưa và tối; hot và packed |
| `rau_muong_xao_toi` | side_veg | xào tỏi; trưa và tối; hot |
| `canh_rau_muong_tom` | soup | canh rau muống nấu tôm; trưa và tối; hot |

### Ngưỡng `nhieu_xo` (D-HLT-02): xơ ≥ 4 g/khẩu phần
Đã áp dụng và ghi lại `health_tags` cho toàn bộ công thức (`scratchpad/health_calc.mjs`, ngưỡng 4 g). Số món mang thẻ, sau D1 (bao gồm 3 món mới): nhieu_xo 101, it_duong 52, tot_cho_tim 76, it_beo 152. Ngưỡng 4 g và thẻ `it_duong`/`tot_cho_tim`/`it_beo` không đổi định nghĩa.

### Nội dung (`content/i18n/vi.json`): 1 khóa mới
- `shop.pantry_if_buy` = "Nếu phải mua: +{amount} ₫" → tên ARB `shopPantryIfBuy` (đã kiểm: không trùng khóa khác).

## 2. Đếm món có lạc (D-QA-06)
- Công thức chứa lạc (`lac`): **18** (full_meal 6, main, side_veg, dessert…). Trong 30 seed với hồ sơ mặc định, **không tuần nào** có món lạc được chọn, kể cả khi không loại trừ. Chưa phải lỗi theo D-QA-06; Dev kiểm điểm món lạc có bị phạt bất thường không.

## 3. Hệ số gạo: lệch so với D-SHP-02
- D-SHP-02 nêu 1 g cơm chín cần 0,4 g gạo sống (gạo 345 kcal → 138 so với cơm 130).
- Với giá trị USDA đã đọc (gạo tẻ sống 365 kcal): 365 × 0,4 = 146 kcal, lệch 12% so với cơm 130 kcal. AC T-042c yêu cầu ±10%, nên 0,4 không đạt.
- Hệ số đạt AC: 0,36 (365 × 0,36 = 131, lệch 1%). Gạo lứt: 367 × 0,34 = 125 so với gạo lứt nấu chín 123 (lệch 1,5%).
- Hệ số 0,36 tương ứng 1 g gạo tẻ → 2,8 g cơm chín, không phải 2,5. **Cần PM xác nhận** nếu muốn giữ 0,4 và đổi giá trị gạo sống khác.

## 4. Chưa đạt trong đợt này
- **Bao 2 kg và 5 kg:** schema giá hiện có một dòng cho mỗi cặp (nguyên liệu, cửa hàng) (`IngredientId@StoreId` phải duy nhất). Chưa biểu diễn được nhiều quy cách; cần Dev/PM quyết định khóa giá theo quy cách.
- **≥ 1 siêu thị có giá gạo:** chưa xác minh. Thử trang Bách hóa Xanh (`/gao`) không tải được danh sách. Giá gạo hiện là ước tính `cho_khac`.
- **Dòng "cơm nấu chín" (`com_trang` 1 kg, 12.000 ₫ cho_khac):** chưa bỏ. T-042c yêu cầu bỏ hoặc đánh dấu lỗi thời khi Dev xong T-078 phần `purchase_as` (chưa có trong code C#/TS: không tìm thấy trường này).
- **Rau muống là PROXY:** rau bina, không phải rau muống. Cần nguồn đúng khi có.

## 5. Kiểm tra (trên dữ liệu sau D1)
- `npm run validate-data`: 0 lỗi, 1 cảnh báo (kcal `rau_den`, đã biết). C# `validate-data`: 0 lỗi, cùng cảnh báo.
- `npm run export-golden`: 55 tệp.
- `npm test`: 173/173.
- `python backend/check-tests.py`: Engine.Tests 178/178, Api.Tests 44/44; "OK: đủ số test, tất cả đạt".
- `engine-report` (C#): 16/16 hồ sơ đạt 7/7, 112/112 ngày, sàn protein 100%, dải calo 100%. Tỉ lệ mâm: 100% ở cả 16 hồ sơ (trước D1: p09 43%, p11 21%, p15 21%, p14 100%); thay đổi do giá gạo và rau muống mới, cần Dev xem cho đúng ý đồ.

## 6. Hash dữ liệu đóng băng (sau D1)
- `data_version_sha256` (golden/manifest.json): `48a76585a8e7851654d73fd4fb0c3db1c23da419da47ce31846366d80fd2e83e`
- `ingredients.json` `975e18760c9b026f8eb089d58a790ab3ae0e6841aa217f932d0a07a74fe0390d`
- `prices.json` `e6f0e35d1da2117252cef899892e60cede14cff925dcd3b30f0b19ccc3081855`
- `recipes.json` `afc6c779a0c7a0f89d7432aa45ee66c91fb9b363961f1c8cd495fa09fc586513`
- `stores.json` `a39128e75ead2b044c4b577a5ee1b29e1fa144ed8283ccd9e7719bd8c3eca065`
- `test-profiles.json` `db24401bbcc7eabfda18b2fd0b2e39690a825bbfe0230ea377e5ecc5cbcaeb76`
