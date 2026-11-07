# Engine report — bản cuối (2026-11-06)

Dữ liệu: `data/` (108 công thức) · hồ sơ: `data/test-profiles.json` (p01–p14) · seed 1 · bắt đầu 2026-11-09.
Tạo lại: `npm run engine-report` (xuất thô: `engine-report-final-raw.txt`). `npm test`: 166 test xanh.

## Kết quả
- **12/14 hồ sơ đạt 7/7 ngày**, 2 partial, **0 lỗi (không còn ném lỗi)**; hồ sơ kỳ vọng đạt: 9/10 (90%).
- 90/98 ngày đạt; **vi phạm ràng buộc cứng: 0** (kiêng kỵ, dụng cụ, ngân sách tuần); thời gian TB 31 ms, tối đa ~230 ms.

| Hồ sơ | Kết quả | Nguyên nhân (nếu chưa đạt) |
|---|---|---|
| p01–p04, p06–p08, p10–p13 | ĐẠT 7/7 | — |
| p03 nam tăng cơ 2800 | ĐẠT 7/7 | trước đây thiếu; nay đạt nhờ món phụ + polishDay |
| p05 thuần chay + ít tinh bột | ĐẠT 7/7 | trước đây lệch 26 kcal (engine) → polishDay sửa; dữ liệu vẫn mỏng (chỉ 6 món khác nhau) |
| p09 chỉ có lò vi sóng | PARTIAL 0/7 | **Thiếu món (dữ liệu)**: 108/108 công thức cần bếp/lò nướng/nồi áp suất. Engine trả tuần đủ 7 ngày, mọi bữa `unfilled`, thiếu = toàn bộ chỉ tiêu (1330 kcal, 120 g protein/ngày) |
| p14 hộ 3 người, ít dụng cụ | PARTIAL 6/7 | **Chủ yếu thiếu món**: còn 16 món sau lọc dụng cụ; bữa trưa mang đi chỉ 3/8 món scale khớp, snack_pm 1/7. Ngày lỗi: 2026-11-15 protein thiếu 4 g |

## Phân loại p03/p05/p09/p14
- **Do engine (đã sửa):** lệch sát ngưỡng ở p03, p05 (kcal_low 26), p14 (kcal_high 8) → thêm `polishDay` (tinh chỉnh ±5 g từng dòng protein/carb/món phụ, ưu tiên giảm vi phạm); p09 từng ném `NoRecipesError` → nay trả `partial`.
- **Do thiếu món (Research):** p09, p14 và phần mỏng của p05.

## Thay đổi engine lượt này
1. Bỏ `NoRecipesError`: bữa không còn ứng viên → `PlanMeal.status = 'unfilled'` (macro 0), `WeekPlan.unfilled_slots` liệt kê; chỉ tiêu được dồn sang các bữa còn lại; tuần có bữa `unfilled` luôn là `partial`. Validator vẫn báo ngày thiếu và lượng thiếu (F-ENG-05). Vegan + ít tinh bột + đạm cao không ném lỗi.
2. `polishDay` sau `refineDay` + `addExtras` mỗi vòng.
3. Báo cáo chẩn đoán dùng `unfilled_slots`; thêm test (unfilled, không còn món nào → 7 ngày thiếu, vegan+low-carb+high-protein không ném lỗi, bù chéo bữa).

## Món Research cần bổ sung (theo ma trận phủ, ⚠ = dưới 6)
1. **Lò vi sóng**: món chỉ cần vi sóng/không cần dụng cụ, đủ cho sáng, trưa, tối, snack_pm (hiện 0) — ≥ 6 món mỗi bữa.
2. **Bữa trưa mang đi (`packed`)**: thêm ≥ 6 món đạm cao, ăn nguội được (p14 chỉ còn 3).
3. **Thuần chay**: trưa/tối hiện 11 (52 món chết vì `nuoc_mam`) → thêm món chay không nước mắm, đạm cao (đậu hũ, tempeh, đậu); snack_pm 3, snack_am 5 → ≥ 6; sáng 6.
4. **Chay (lacto)**: snack_pm 5.
5. **snack_pm mặn** ≥ 6 (nay 7 không ràng buộc; 5 với không trứng/đậu nành/cá/chay) và snack có đạm ≥ 6–10 g.
6. **Món mật độ đạm cao** (≥ 35% kcal từ protein chỉ 14/65 món trưa/tối) và món trung/cao calo (≥ 700 kcal) cho hồ sơ tăng cơ.
7. **Giá theo cửa hàng**: bach_hoa_xanh 3/46, winmart/coopmart 0/46 — mọi thứ đang dùng giá `cho_khac`. `ca_tim` không công thức nào dùng.
