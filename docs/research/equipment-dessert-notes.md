# Ghi chú: đa dạng dụng cụ + tráng miệng (T-058)

Ngày: 06/11/2026 · Owner: RESEARCH · Chỉ sửa `data/` và `docs/research/`.

## 1. Đếm món theo dụng cụ (trước → sau)

Đếm theo dòng `equipment` của từng công thức (một món có thể nằm trong nhiều dụng cụ).

| Dụng cụ | Trước (247 công thức) | Sau (311 công thức) | Ghi chú |
|---|---|---|---|
| bep | 198 | 207 | +9 (5 súp/sốt xay có nấu; 3 chè và 1 táo hấp) |
| lo_vi_song | 38 | 38 | không thêm món mới (theo yêu cầu) |
| noi_ap_suat | 17 | 27 | +10 (món kho; xem mục 3) |
| lo_nuong | 7 | 13 | +6 |
| noi_com_dien | 3 | 43 | +40 (cơm trọn suất, cháo, nếp, và món hấp/kho gán thêm; xem mục 3) |
| noi_chien_khong_dau | 0 | 20 | +20 (10 trọn suất có cơm, 6 món chính, 3 rau, 1 khác) |
| may_xay | 0 | 9 | +9 (súp, sốt, sữa hạt, sinh tố) |
| Món không cần dụng cụ | 2 | 17 | 15 tráng miệng không cần dụng cụ |

Số món mới: 64 (43 món theo dụng cụ + 21 tráng miệng). Chi tiết: `data/recipes.json`.

## 2. Món mới theo dụng cụ

- **Nồi chiên không dầu (20):** ức gà, đùi gà, cá basa, cá rô phi, đậu hũ, chả heo, tôm, mực, thịt bò, khoai lang trứng (trọn suất có cơm); ức gà sả ớt, đậu hũ xì dầu, cá thu tiêu, thịt heo mật đường, tempeh, tôm tỏi (món chính); khoai tây, bí xanh, su su (rau). Dùng ít dầu (5–15 g).
- **Nồi cơm điện (6 + 40 gán thêm):** cơm gà, cơm đậu xanh, cháo gà, cháo cá rô phi (sáng), cơm trộn đậu hũ, cơm chưng trứng. Thêm: cơm thịt băm trứng, cơm đậu hũ sốt cà chua, cơm khoai lang đậu hũ.
- **Máy xay (8):** súp bí xanh, súp cà rốt, súp súp lơ (có nấu, cần `bep`); sốt cà chua, sốt đậu phộng; sữa đậu phộng; sinh tố đậu nành cà rốt; sinh tố sữa chua Hy Lạp.
- **Lò nướng (6):** đùi gà + cơm, cá basa + cơm, khoai lang trứng, thịt bò tiêu, đậu hũ sả ớt (chay), cà tím nướng.

## 3. Gán thêm dụng cụ cho món `bep` (chỉ khi đúng thực tế)

Quy tắc đã dùng (đặt trong `build_equip`):
- Món có tag `hap` và bước nấu có chữ "hấp", không chiên/xào/nướng/rim → thêm `noi_com_dien` (hấp trong nồi cơm điện). Gán cho 18 món.
- Món có tag `kho`, bước có "kho", thời gian nấu ≥ 20 phút → thêm `noi_ap_suat`. Gán cho 10 món.

Món vẫn giữ `bep` (vì có bước sơ chế trên bếp). Điều này làm nhiều món hơn khả dụng cho hồ sơ có nồi cơm điện. **Cần xác nhận với PM/Dev** nếu muốn quy tắc chặt hơn.

## 4. Hồ sơ test mới

| id | Dụng cụ | Ngân sách | Kết quả C# |
|---|---|---|---|
| `p15_chi_noi_chien_va_noi_com` | noi_chien_khong_dau + noi_com_dien | 1.200.000 ₫ | 7/7 ngày. Ngân sách tăng từ 800.000 ₫ vì với dụng cụ này món rẻ nhất vẫn ~870.000 ₫; cần xác nhận |
| `p16_chi_bep_va_noi_chien` | bep + noi_chien_khong_dau | 900.000 ₫ | 7/7 ngày |

## 5. Tráng miệng (T-058, D-DES-01)

21 món `dish_role: dessert`, `meal_types = [lunch, dinner]`:

| Nhóm | Số | Món |
|---|---|---|
| Trái cây | 9 | chuối, cam, ổi, dưa hấu, đu đủ, táo, xoài, dứa, bưởi |
| Sữa | 5 | sữa tươi không đường, sữa chua Hy Lạp không đường, sữa chua trái cây ít béo, sữa chua Hy Lạp với chuối, sữa chua Hy Lạp với đậu phộng |
| Chay / không sữa | 3 | sữa đậu nành không đường, sinh tố chuối sữa đậu nành, táo hấp đường phèn |
| Chè ít đường | 3 | đậu xanh, đậu đỏ, khoai lang |
| Khác | 1 | sữa chua nếp |

Quy ước: `portable` = true cho trái cây nguyên quả, sữa hộp/hũ; `low_carb_ok` = true khi ≤ 10 g carb/khẩu phần (sữa tươi, sữa chua Hy Lạp, sữa đậu nành); `is_low_carb` đặt bằng `low_carb_ok` để khớp quy ước của engine. `lunch_style` = [hot, packed] khi portable, ngược lại [hot].

Nguyên liệu mới (13) tra FDC SR Legacy trên web: chuối, cam, ổi, dưa hấu, đu đủ, táo, xoài, dứa, bưởi, sữa tươi, sữa chua trái cây, đậu đỏ, gạo nếp. Ghi chú đầy đủ trong `source.note`.

**Proxy và hạn chế:**
- Cam: Florida (không phải cam sành). Táo: golden delicious có vỏ (không phải Fuji). Bưởi: grapefruit trắng California (không phải bưởi VN; xơ không có trong bản ghi nên để 0).
- Sữa chua trái cây: ngọt bằng chất tạo ngọt ít calo, không phải đường mía. Gạo nếp: nếp trắng, không có nếp cẩm trong SR.
- Giá là ước tính `cho_khac` (chưa có giá siêu thị đã xác minh cho trái cây và sữa mới). Chưa đạt "≥ 1 siêu thị" trong AC T-058.
- Dessert không có cờ `dessert_missing` vì mọi bữa đều có ứng viên.

## 6. Thay đổi đặt tên

Ba món tráng miệng trùng ID với fixture trong `backend/MonNgon.Engine.Tests/DessertTests.cs` (`dessert_chuoi`, `dessert_oi`, `dessert_sua_dau_nanh`). Đã đổi thành `dessert_chuoi_qua`, `dessert_oi_qua`, `dessert_sua_dau_nanh_khong_duong` để tránh xung đột khi nạp dữ liệu.

## 7. Kiểm tra

- `npm run validate-data`: 0 lỗi, 1 cảnh báo (kcal `rau_den`, đã ghi).
- `npm run export-golden`: 55 tệp, đã chạy lại sau mọi thay đổi dữ liệu.
- `npm test`: 173/173.
- `dotnet test backend/MonNgon.sln`: Api 25/25 pass; Engine 135/141, 6 lỗi (xem dưới).
- Engine C# report: **15/16** hồ sơ đạt 7/7 (112 ngày, 111 đạt). 100% bữa trưa/tối có tráng miệng.

### Hồ sơ còn lại

- **p02** (1.350 kcal, 110 g protein): 6/7 ngày. Trước khi thêm tráng miệng hồ sơ này đạt 7/7. Tráng miệng trừ kcal trước khi chọn món chính, và với mục tiêu thấp, mâm mất đạm. Cần Dev xem điểm chọn tráng miệng (ưu tiên đạm khi thiếu đạm) hoặc PM quyết định kỳ vọng.

### 6 lỗi `dotnet test` (Engine.Tests)

Không do dữ liệu sai; có ba nhóm:
1. **Test giả định data không có tráng miệng** (`Khong_co_mon_trang_mieng_trong_du_lieu...`, `Kieng_va_ghet...`): `Dataset Base` đọc `data/` nên đã có tráng miệng thật. Cần sửa test.
2. **Test chỉ mong ID fixture** (`Chay_thuan_khong_co_sua_bo`): chọn tráng miệng thật thay vì `dessert_sua_dau_nanh`. Cần sửa test.
3. **Lỗi engine đã biết**: `Trua_mang_di_van_co_mam...` (p14 dưới 40%, do `Mam.cs` dòng 130 — đã báo) và `Auto_toan_bo_ho_so...` (p02 như trên).

Các lỗi này cần Dev xử lý; không sửa được bằng dữ liệu.
