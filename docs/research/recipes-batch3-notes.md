# Ghi chú lô 3 công thức (lò vi sóng và món mang đi, 06/11/2026)

Tổng công thức: **137** (trước: 108). Nguyên liệu: không đổi (46).

## Số món thêm theo nhóm

| Nhóm | Yêu cầu (Dev) | Đã thêm | Ghi chú |
|---|---|---|---|
| Lò vi sóng — sáng | ≥ 6 | 6 (`mw_sang_*`) | Chỉ `equipment = [lo_vi_song]`. |
| Lò vi sóng — trưa/tối | ≥ 6 | 7 (`mw_ld_*`) | Dùng cho cả trưa và tối. |
| Lò vi sóng — bữa phụ | ≥ 6 | 7 (`mw_sn_*`) | 4 mặn, 2 ngọt, 1 có cả hai. Tổng bữa phụ chỉ lò vi sóng: 7. |
| Mang đi / ăn nguội, đạm cao | ≥ 6 | 8 (`pk_*`) | `lunch_style = [packed]`. Tổng món mang đi: 18. |

Tổng món chỉ cần lò vi sóng: 20 (sáng 6, trưa 7, tối 7, phụ sáng 7, phụ chiều 7 — các món dùng chung cho trưa và tối được tính cả hai bữa).

## Cách làm món lò vi sóng

- Cơm, khoai và nguyên liệu đã chín được hâm hoặc hấp trong lò vi sóng; không yêu cầu bếp.
- Thời gian ghi trong bước là ước lượng cho lò 700 W; cần thử lại khi có máy thật.
- Chỉ dùng nguyên liệu có sẵn trong kho (`data/ingredients.json`), không thêm nguyên liệu mới.

## Kết quả engine report (cùng bộ 14 hồ sơ `data/test-profiles.json`)

| Chỉ số | Trước (108 công thức) | Sau (137 công thức) |
|---|---|---|
| Hồ sơ đạt 7/7 | 12/14 (p09, p14 partial) | **14/14** |
| Hồ sơ kỳ vọng đạt | 9/10 | **14/14** |
| Ngày đạt | 90/98 (92%) | **98/98 (100%)** |
| Lỗi | 0 | 0 |

## Thay đổi trong `data/test-profiles.json`

Bốn hồ sơ đã được đổi `expect_all_days_pass` từ `false` sang `true`, kèm ghi chú lý do: p03, p05, p09, p10. Lý do: các kỳ vọng ban đầu là phỏng đoán khi chưa có số liệu; sau lô 2–3, cả bốn hồ sơ đều đạt 7/7. Đây là cập nhật theo kết quả đo, không phải đổi tiêu chí kiểm; nếu đội muốn giữ kỳ vọng gốc để theo dõi hồi quy thì cần khôi phục.

## Việc còn lại

- Thuần chay: kiểm lại p05 sau khi có thêm món; số món thuần chay trưa/tối đã đủ (≥ 6 mỗi bữa).
- Giá theo cửa hàng: vẫn dùng `cho_khac` (theo ghi chú hiện tại).
- Ảnh món, nội dung UI: không thuộc lô này.
