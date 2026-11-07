# Engine report — lượng cơm theo thói quen (T-094, cập nhật T-096)

Sinh bằng `dotnet backend/MonNgon.Tools/bin/<cfg>/net10.0/MonNgon.Tools.dll engine-report --data data --profiles data/test-profiles.json --rice <mức> [--seed n] [--rice-keep-first false]` (auto). T-096 thêm hai dòng mỗi hồ sơ: `khẩu vị thích: x% bữa mâm khớp · n loại tráng miệng/tuần`. `--rice-keep-first false` tắt xếp hạng từ điển "giữ được cơm" (chỉ để so sánh trước/sau).

## Tóm tắt 4 mức (16 hồ sơ, seed 1)

```
[it]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 100%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 89 ms, tối đa 301 ms

[vua]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 136 ms, tối đa 491 ms

[nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 79%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 21% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 806 ms, tối đa 2921 ms

[rat_nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 75%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1122 ms, tối đa 3663 ms

```

## Seed 2 và 3 (tóm tắt)

```
[vua · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 97%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 140 ms, tối đa 520 ms

[nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 81%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 22% · hồ sơ >20% bữa có ghi chú: p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p13_nhieu_mon_ghet, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 834 ms, tối đa 3064 ms

[rat_nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 72%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1119 ms, tối đa 3292 ms

[vua · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 126 ms, tối đa 501 ms

[nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 81%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 20% · hồ sơ >20% bữa có ghi chú: p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p13_nhieu_mon_ghet, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 844 ms, tối đa 3231 ms

[rat_nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1070 ms, tối đa 3310 ms

```

## p01 mức vừa: trước/sau xếp hạng "giữ được cơm" (T-096 AC1, AC4)

Trước = `--rice-keep-first false` (điểm mềm khẩu vị/xu hướng thắng lượng cơm; vẫn có luật mâm một canh và ngưỡng bữa phụ). Số T-095 gốc theo PM: 92% bữa mâm giảm cơm, trung vị 88 g.

| Seed | Chế độ | % bữa mâm giảm cơm | Cơm trung vị | % mâm khớp khẩu vị thích | Loại tráng miệng/tuần |
|---|---|---|---|---|---|
| 1 | trước | 64% | 113 g | 93% | 6 |
| 1 | sau | 0% | 150 g | 85% | 3 |
| 2 | trước | 67% | 125 g | 92% | 5 |
| 2 | sau | 0% | 150 g | 92% | 3 |
| 3 | trước | 67% | 125 g | 92% | 4 |
| 3 | sau | 0% | 150 g | 85% | 3 |

## Chi tiết từng hồ sơ — mức vừa (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 491 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 617.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~966.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (13 bữa) · gạo sống cần mua 575 g/tuần
   khẩu vị thích: 85% bữa mâm khớp · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 86%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 29%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 11) · 484 ms · 1 vòng · % bữa ghép mâm 79% · % có tráng miệng 100%
   chi phí món ăn 589.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~939.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (11 bữa) · gạo sống cần mua 582 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 93%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 41 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 767.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.060.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 910 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 42 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 551.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~810.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 866 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 20 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 497.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~786.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 225 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 256 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 49%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 35 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 571.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~861.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 568 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 50%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 35 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 467.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~684.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 613 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 5) · 300 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 600.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~820.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 797 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 37 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 564.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~779.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 674 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 122 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.490.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.482.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.540 g/tuần
   khẩu vị thích: 93% bữa mâm khớp · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 37 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 514.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~827.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 582 g/tuần
   khẩu vị thích: không chọn · 9 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 43%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 23 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 571.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~898.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 188 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 410 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 90 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.189.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.243.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.064 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 7) · 375 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 1.178.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.175.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (13 bữa) · gạo sống cần mua 2.533 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): noi_com_dien 81% · noi_chien_khong_dau 62%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 38 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 729.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~918.000 ₫
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.895 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 29%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 88% · noi_com_dien 28% · lo_vi_song 6% · noi_chien_khong_dau 6%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 136 ms, tối đa 491 ms
```

## Chi tiết từng hồ sơ — mức nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 2517 ms · 3 vòng · % bữa ghép mâm 50% · % có tráng miệng 100%
   chi phí món ăn 643.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~921.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 175 g · 86% bữa mâm có ghi chú giảm cơm (7 bữa) · gạo sống cần mua 678 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 6 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 71%, đủ dụng cụ → 50%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 29%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 4) · 2921 ms · 3 vòng · % bữa ghép mâm 29% · % có tráng miệng 100%
   chi phí món ăn 599.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~758.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 150 g · 100% bữa mâm có ghi chú giảm cơm (4 bữa) · gạo sống cần mua 488 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 43%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 46 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 615.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~944.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.640 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · lo_nuong 11%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 40 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 539.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~773.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 378 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.079 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 32%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 9) · 370 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 597.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~915.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 455 g · 14% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 337 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 49%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 221 ms · 1 vòng · % bữa ghép mâm 57% · % có tráng miệng 100%
   chi phí món ăn 699.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~915.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (8 bữa) · gạo sống cần mua 933 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 71%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 25%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 7) · 145 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 689.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~847.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 939 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 2136 ms · 3 vòng · % bữa ghép mâm 86% · % có tráng miệng 100%
   chi phí món ăn 599.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~807.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 175 g · 100% bữa mâm có ghi chú giảm cơm (12 bữa) · gạo sống cần mua 825 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 43%)
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 44 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 599.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~870.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 455 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 649 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 43%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 60 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.492.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.505.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.948 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 4 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 12) · 340 ms · 1 vòng · % bữa ghép mâm 79% · % có tráng miệng 100%
   chi phí món ăn 653.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~927.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (11 bữa) · gạo sống cần mua 1.274 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 29%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 5) · 921 ms · 2 vòng · % bữa ghép mâm 86% · % có tráng miệng 100%
   chi phí món ăn 648.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~984.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 455 g · trung vị 455 g · 0% bữa mâm có ghi chú giảm cơm (12 bữa) · gạo sống cần mua 124 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 46%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 2711 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
   chi phí món ăn 1.137.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.212.000 ₫
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 43%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 8 (trưa/tối 6) · 188 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.198.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.343.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.137 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 90% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 230 ms · 1 vòng · % bữa ghép mâm 79% · % có tráng miệng 100%
   chi phí món ăn 839.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~953.000 ₫
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (11 bữa) · gạo sống cần mua 2.489 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 93%)
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 5%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 79%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 88% · noi_com_dien 26% · lo_vi_song 6% · noi_chien_khong_dau 4% · lo_nuong 1%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 21% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 806 ms, tối đa 2921 ms
```

## Chi tiết từng hồ sơ — mức rat_nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 2767 ms · 4 vòng · % bữa ghép mâm 29% · % có tráng miệng 100%
   chi phí món ăn 550.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~870.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (4 bữa) · gạo sống cần mua 429 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 6 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 50%, đủ dụng cụ → 7%)
   dụng cụ (% bữa): bep 79% · noi_com_dien 50%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 6) · 1926 ms · 3 vòng · % bữa ghép mâm 29% · % có tráng miệng 100%
   chi phí món ăn 596.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~824.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (4 bữa) · gạo sống cần mua 548 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 57%, đủ dụng cụ → 43%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 119 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 941.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.241.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.324 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 48 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 526.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~733.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.160 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 43%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 9 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 1172 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 596.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~818.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 250 g · trung vị 468 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 294 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 49%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 1689 ms · 3 vòng · % bữa ghép mâm 50% · % có tráng miệng 100%
   chi phí món ăn 672.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~943.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 345 g · 100% bữa mâm có ghi chú giảm cơm (7 bữa) · gạo sống cần mua 595 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 71%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 1051 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 623.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~881.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 275 g · trung vị 325 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.253 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 1926 ms · 3 vòng · % bữa ghép mâm 57% · % có tráng miệng 100%
   chi phí món ăn 591.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~849.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (8 bữa) · gạo sống cần mua 682 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 64%, đủ dụng cụ → 7%)
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 55 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 576.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~788.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.620 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 43%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 156 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.465.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.532.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 4.423 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 732 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 615.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~869.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 300 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 846 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 52%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 887 ms · 3 vòng · % bữa ghép mâm 50% · % có tráng miệng 100%
   chi phí món ăn 525.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~864.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 275 g · trung vị 350 g · 100% bữa mâm có ghi chú giảm cơm (7 bữa) · gạo sống cần mua 574 g/tuần
   khẩu vị thích: không chọn · 9 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 82% · noi_com_dien 50%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 3663 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
   chi phí món ăn 1.137.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.212.000 ₫
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 0%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 9) · 142 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.196.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.181.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.833 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 71% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 8) · 1612 ms · 3 vòng · % bữa ghép mâm 86% · % có tráng miệng 100%
   chi phí món ăn 885.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~966.000 ₫
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 325 g · 100% bữa mâm có ghi chú giảm cơm (12 bữa) · gạo sống cần mua 2.604 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 29%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 75%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 85% · noi_com_dien 29% · lo_vi_song 6% · noi_chien_khong_dau 6%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1122 ms, tối đa 3663 ms
```
