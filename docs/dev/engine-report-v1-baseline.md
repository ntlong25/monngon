# Engine report — baseline v1 (dải calo ±5%) · T-051

Ngày: 2026-11-06 · dữ liệu `data/` hiện tại (137 công thức) · `data/test-profiles.json` (p01–p14) · seed 1 · bắt đầu 2026-11-09.
Tạo lại: `npm run engine-report`. Bản C# (T-064) phải trùng các số liệu dưới đây.

## Thay đổi
- `calorieBand` mặc định `bandBelowPct = 0.05`, `bandAbovePct = 0.05` (trước: 0). Ví dụ spec 2.200 kcal → [2.090; 2.310]; 1.800 → [1.710; 1.890]; tự nhập 1.350 → [1.283; 1.418] (`Math.round`, 1417,5 → 1418).
- Đã rà `validate.ts`, `scale.ts`, `planWeek.ts`, report: chỉ dùng `kcal_min`/`kcal_max` từ `Targets`, không nơi nào giả định trần = mục tiêu (planWeek lấy tâm dải làm điểm nhắm). Protein vẫn là sàn.
- Test: cập nhật `targets.test.ts` (dải mặc định, 2.200 → 2.090–2.310, tùy chọn về −5%/0%); `npm test` 173 xanh.

## So sánh trên cùng dữ liệu (137 món)
| | −5% / 0% (cũ) | ±5% (baseline v1) |
|---|---|---|
| Hồ sơ đạt 7/7 | 14/14 | **14/14** |
| Hồ sơ kỳ vọng đạt | 14/14 | 14/14 |
| Ngày đạt | 98/98 | **98/98** |
| Vi phạm ràng buộc cứng | 0 | **0** |
| Thời gian TB / tối đa | 28 / 71 ms | 26 / 64 ms |

Ghi chú: ở lượt báo cáo trước (108 món) là 12/14 với dải cũ; p09, p14 nay đạt nhờ Research bổ sung món (lô 3).

## Báo cáo đầy đủ (đầu ra `npm run engine-report`)
```

> mon-ngon@0.0.1 engine-report
> node src/report/engine-report-cli.ts

BÁO CÁO ENGINE (T-011)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 64 ms · 1 vòng
   chi phí món ăn 600.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~1.161.000 ₫

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 6) · 56 ms · 1 vòng
   chi phí món ăn 495.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.168.000 ₫

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 6) · 48 ms · 1 vòng
   chi phí món ăn 882.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.417.000 ₫

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 19 ms · 1 vòng
   chi phí món ăn 547.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~1.157.000 ₫

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 6 (trưa/tối 6) · 5 ms · 1 vòng
   chi phí món ăn 395.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~681.000 ₫

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 5) · 7 ms · 1 vòng
   chi phí món ăn 388.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~902.000 ₫

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 5) · 12 ms · 1 vòng
   chi phí món ăn 574.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.117.000 ₫

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 17 ms · 1 vòng
   chi phí món ăn 447.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.026.000 ₫

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 4) · 42 ms · 5 vòng
   chi phí món ăn 563.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.189.000 ₫

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 12 ms · 1 vòng
   chi phí món ăn 540.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.175.000 ₫

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 5) · 39 ms · 2 vòng
   chi phí món ăn 1.338.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.766.000 ₫

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 8 (trưa/tối 5) · 9 ms · 1 vòng
   chi phí món ăn 444.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.004.000 ₫

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 9 ms · 1 vòng
   chi phí món ăn 529.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~1.154.000 ₫

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 5) · 19 ms · 1 vòng
   chi phí món ăn 1.194.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.680.000 ₫

TỔNG HỢP
  Hồ sơ đạt 7/7: 14/14 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 98/98 (100%) · sàn protein 100% · dải calo 100%
  Vi phạm ràng buộc cứng: 0 · thời gian TB 26 ms, tối đa 64 ms

```
