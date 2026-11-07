# Ghi chú lô 2 công thức (theo yêu cầu engine report, 06/11/2026)

Tổng công thức: **108** (trước: 64). Nguyên liệu: **46** (thêm 6: đậu lăng khô, đậu xanh khô, sữa đậu nành, gạo lứt nấu chín, tempeh, nước mắm chay).

## Số món thêm theo nhóm

| Nhóm (yêu cầu) | Yêu cầu | Đã thêm / đạt |
|---|---|---|
| 1. Bữa sáng giàu đạm (≥35 g protein ở khẩu phần scale tối đa, ~450 kcal) | ≥ 8 | 10 món (`sang_uc_ga_*`, `sang_ca_basa_chao`, `sang_bun_bo_xao`, `sang_pho_ga_dac_biet`...). Tổng 21/29 bữa sáng đạt điều kiện. |
| 2. Thuần chay: ≥6 món mỗi bữa, có biến thể chay cho nước mắm | ≥ 6 sáng, ≥ 6 trưa, ≥ 6 tối | Sáng 7 (tổng món thuần chay sáng: 7), trưa/tối 12 (dùng chung). Thêm `nuoc_mam_chay` (proxy xì dầu, gắn gluten bảo thủ). |
| 3. Trưa/tối giàu đạm ít tinh bột (≥67 g protein, ~830 kcal không cơm) | ≥ 8 | 12 món `ld_lc_*` (9 mặn, 3 chay). Chỉnh tăng dầu/ba chỉ ở 5 món để đạt ≥830 kcal ở khẩu phần scale tối đa. |
| 4. Trưa/tối calo cao (≥1.100 kcal khi scale) | ≥ 6 | 6 món `ld_hk_*` (cơm, khoai tây, khoai lang với hệ số scale ×3). Ước tính: 10 món trưa/tối đạt ≥ 1.100 kcal ở khẩu phần tối đa. |
| 5. Chay có cá, không trứng, không gluten (sáng) | thêm món sáng | 2 món mới (`sang_ca_thu_com_gung`, `sang_ca_ro_phi_hap_com`). Tổng 9 món sáng chay có cá, không trứng, không gluten. |

## Kết quả engine report (cùng bộ 14 hồ sơ `data/test-profiles.json`)

| Chỉ số | Trước (64 công thức) | Sau (108 công thức) |
|---|---|---|
| Hồ sơ đạt 7/7 | 10/14 | 11/14 |
| Hồ sơ kỳ vọng đạt | 8/10 (80%) | 9/10 (90%) |
| Ngày đạt | 81/91 (89%) | 88/91 (97%) |
| Món trưa/tối có mật độ protein ≥ 25% calo (khẩu phần chuẩn) | 38/40 | 51/65 |
| Lỗi (bữa không có món) | 1 hồ sơ (chỉ lò vi sóng) | 1 hồ sơ (chỉ lò vi sóng, vẫn lỗi) |

Báo cáo Dev trước đó (3/15 đạt 7/7) dùng bộ hồ sơ cũ (15 hồ sơ). Không so sánh trực tiếp được với bộ 14 hồ sơ hiện tại.

## Hồ sơ còn chưa đạt

- `p03_nam_tang_co_2800` (partial, 6/7 ngày): thiếu món đạm lớn, cần 180 g protein/ngày.
- `p05_thuan_chay_it_tinh_bot` (partial): kcal chưa đủ trong bữa thuần chay ít tinh bột, cần thêm món chay calo cao không cơm.
- `p09_chi_co_lo_vi_song` (lỗi): không có công thức nào dùng được chỉ với lò vi sóng.
- `p14_ho_3_nguoi_lon_2` (partial): thiếu món `packed` cho bữa trưa ở mức protein.

## Giới hạn cần nói rõ

- `nuoc_mam_chay` là proxy số liệu xì dầu; giá trị dinh dưỡng và nguồn gluten cần kiểm nhãn sản phẩm thực.
- `tempeh` ít phổ biến ở VN, cần xác nhận nguồn mua.
- Giá của 6 nguyên liệu mới là ước tính (`cho_khac`).
- Số liệu FDC là tra cứu thủ công trên web, chưa qua API.
