# Ghi chú bộ công thức (T-043)

Ngày: 06/11/2026 · File dữ liệu: `data/recipes.json` (64 công thức) · Nguyên liệu: `data/ingredients.json` (40 mục lô 40, USDA FDC).

## Thống kê

| Nhóm | Yêu cầu T-043 | Có |
|---|---|---|
| Bữa trưa/tối (công thức có `lunch` hoặc `dinner`) | ≥ 34 | 40 |
| Bữa sáng | ≥ 10 | 10 |
| Bữa phụ | ≥ 14 (7 ngọt, 7 mặn) | 14 (7 ngọt, 7 mặn) |
| Món giàu đạm (tag `giau_dam`, trưa/tối) | ≥ 10 | 38 |
| Món chay/đậu phụ (tag `chay`) | ≥ 8 | 9 |
| `is_low_carb: true` | ≥ 8 | 39 (trưa/tối có đạm ≥ 20 g) |
| Món mang đi được (`packed`) | ≥ 10 | 6 — **chưa đạt**, cần bổ sung |
| Đạm ≥ 20 g khi khẩu phần chuẩn | mọi món chính | đạt (trưa/tối và sáng có đạm) |

Quy tắc `is_low_carb` được sinh tự động: công thức trưa/tối có đạm ≥ 20 g ở khẩu phần chuẩn được gắn `true` (engine đặt carb = 0 vẫn đủ đạm). Cần PM xác nhận cách hiểu này.

## Hạn chế của lô này (cần biết trước khi test engine)

- **Kho nguyên liệu còn 40 mục**, nên công thức chỉ dùng các id đó. Không có gia vị phụ (sả, ớt, mắm tôm, nấm, rau thơm), không có trái cây, không có bánh mì/yến mạch. Các món như canh chua, bún riêu, bánh mì trứng, sữa chua trái cây chưa làm được.
- Số món `packed` chỉ 6 (ví dụ gỏi gà bắp cải, bún trộn gà xé, mực hấp gừng, thịt heo luộc chấm), chưa đủ 10.
- Gram trong `household_units` chỉ có vài mục (trứng, thìa, tép) và là ước tính chưa đối chiếu.
- Hai nguyên liệu **proxy**, cần xác nhận trước khi công bố: `ca_thu` (cá thu Đại Tây Dương), `nuoc_mam` (sauce fish ready-to-serve), `cai_ngot` (pak-choi), `bi_xanh` (zucchini). `ca_basa` dùng catfish.
- `com_trang` là cơm chín; giá tương ứng quy đổi từ gạo tẻ (xem `docs/research/prices-method.md`).

## Kiểm tra macro (tính tay đối chiếu với T-005)

Công thức: macro = Σ (gram × giá trị /100 g). Khẩu phần chuẩn `grams` trong JSON. Kết quả tính bằng script đọc đúng `data/ingredients.json`; đối chiếu tay món đầu tiên:

- Ức gà xào súp lơ: ức gà 150 g × 22,5 g/100 g = 33,75 g; cơm 150 g × 2,69 = 4,04 g; súp lơ xanh 150 g × 2,82 = 4,23 g; tỏi 5 g × 6,36 = 0,32 g; nước mắm 5 g × 5,06 = 0,25 g. Tổng ≈ 42,6 g, khớp với script.

| Công thức (id) | kcal | Protein g | Carb g | Fat g | Fiber g |
|---|---|---|---|---|---|
| `ga_xao_sup_lo_xanh_toi` | 504 | 42,6 | 54,1 | 13,9 | 4,6 |
| `dui_ga_kho_gung` | 456 | 39,7 | 52,8 | 8,2 | 1,5 |
| `goi_ga_bap_cai` | 265 | 32,6 | 20,2 | 7,5 | 5,5 |
| `thit_heo_kho_trung` | 504 | 41,9 | 50,5 | 13,3 | 1,2 |
| `bo_xao_sup_lo_xanh` | 545 | 44,8 | 57,4 | 15,9 | 4,7 |
| `ca_basa_kho_to` | 405 | 27,6 | 49,7 | 9,4 | 1,1 |
| `tom_rim` | 398 | 34,9 | 49,9 | 6,2 | 1,0 |
| `dau_phu_sot_ca_chua` | 620 | 46,0 | 52,8 | 27,8 | 6,7 |
| `muc_xao_hanh_tay` | 401 | 28,4 | 52,2 | 7,6 | 1,5 |
| `chao_ga` (sáng, khẩu phần 40 g cơm) | 167 | 23,9 | 13,2 | 2,1 | 0,6 |

Lưu ý: kcal của công thức là tổng kcal từ bảng FDC (không cộng lại theo Atwater), nên lệch nhỏ so với 4/4/9 khi có chất xơ.

## Việc còn lại

1. Bổ sung ≥ 7 món `packed` (cơm nguội, bún/gỏi, trứng cuộn...).
2. Đổi 4 proxy sang nguyên liệu thật khi có dữ liệu Việt (sau khi có khóa FDC thật hoặc bảng VN 2007).
3. Thêm công thức khi kho nguyên liệu mở rộng (RESEARCH, lô 2).
