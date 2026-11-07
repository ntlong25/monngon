# L-05 — Món chứa lạc có bị phạt bất thường không? (T-093 mục 6, D-QA-06)

**Kết luận: không. Không có điều khoản nào riêng cho lạc trong bộ lọc hay chấm điểm; lạc ít xuất hiện vì giá, không phải vì bị phạt.**

## Kiểm tra
- `Filter`: "Không hạt cây" (`no_tree_nut`) chỉ cấm tag `tree_nut`; lạc có tag `peanut` nên **không** bị loại. Unit test: `FilterTests.Khong_hat_cay_giu_mon_chua_lac_trong_tap_hop_le` (kèm `No_seed_khong_cam_lac_hay_hat_cay`). "Không lạc" (`no_peanut`) cấm tag `peanut`; hồ sơ p08 trong engine-report không có món chứa lạc.
- `Score.Total` gồm: khẩu vị (likes/less), xu hướng sức khỏe, chi phí so với tham chiếu, lặp trong tuần, trùng ngày, đơn điệu đạm chính. Không có thành phần nào xét dị ứng/lạc.
- Dữ liệu: 18/324 công thức có `lac` (12 món trưa/tối, 2 sáng, 4 phụ).
- Đo thực (dữ liệu 07/11/2026, auto, không loại trừ gì): 14 hồ sơ × 30 seed, 441/12.180 bữa (3,6%) có lạc. Theo hồ sơ rất lệch: p07 (không lợn, không sữa) 90/840 bữa (10,7%); p01 và p04 0/840.
- Giá một suất (Bách hóa Xanh) của món có lạc đa số cao hơn trung vị: trưa/tối 9/12 món xếp sau hạng 120/255 (`pk_bun_tron_uc_ga_nguoi` hạng 215, `main_tempeh_sot_lac_chay` hạng 202); sáng 2 món hạng 24 và 36/37; phụ chiều 2/4 món hạng 30/32. Thành phần chi phí của điểm đẩy chúng ra khỏi nhóm đầu, còn p07 bị loại bớt món rẻ (lợn, sữa) nên lạc lọt vào.

→ Nên TC-1-22 kiểm ở cấp bộ lọc (đã đổi theo D-QA-06), không đòi lạc xuất hiện trong tuần. Không cần sửa engine. Nếu muốn lạc xuất hiện đều hơn thì chỉnh trọng số chi phí hoặc giá/khẩu phần lạc (việc của Research/PM, không khẩn).
