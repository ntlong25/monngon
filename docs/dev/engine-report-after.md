# Engine report sau cải tiến (T-011, test-profiles.json)

Sinh bởi `npm run engine-report` (seed 1). So sánh: `npm run engine-report -- --legacy` (engine cũ, cùng dữ liệu).

```

BÁO CÁO ENGINE (T-011)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1400 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 49 ms · 1 vòng
   chi phí món ăn 575.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~1.161.000 ₫

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1350 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 6) · 36 ms · 1 vòng
   chi phí món ăn 490.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.202.000 ₫

[PARTIAL] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Kỳ vọng chưa đạt: 180 g đạm/ngày cần nhiều món đạm lớn; thiếu món đạm nặng trong kho hiện tại.
   chỉ tiêu: 2660–2800 kcal, protein ≥ 180 g
   ngày đạt 6/7 (protein 6/7, kcal 7/7) · món khác nhau 15 (trưa/tối 6) · 262 ms · 12 vòng
   chi phí món ăn 895.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.592.000 ₫
   · Lọc cứng loại 12/105 món; nhiều nhất do: equipment (12)
   · Bữa snack_am: chỉ 2/14 món scale khớp được mục tiêu bữa (~137 kcal, ≥ 9 g protein; dung sai protein 3 g, kcal 5%); gần nhất: khoai_tay_luoc_muoi.
   · Bữa snack_pm: chỉ 0/7 món scale khớp được mục tiêu bữa (~137 kcal, ≥ 9 g protein; dung sai protein 3 g, kcal 5%); gần nhất: khoai_tay_luoc_muoi.
   · Ngày không đạt theo loại: protein_low×1
   · Thiếu nặng nhất: 2026-11-10 protein_low 3 g.

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2400 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 10 ms · 1 vòng
   chi phí món ăn 532.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~1.157.000 ₫

[PARTIAL] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Kỳ vọng chưa đạt: ít món thuần chay lunch/dinner trong kho (chỉ có đậu phụ và lạc); cần thêm món chay.
   chỉ tiêu: 1663–1750 kcal, protein ≥ 100 g
   ngày đạt 3/7 (protein 7/7, kcal 3/7) · món khác nhau 6 (trưa/tối 6) · 43 ms · 12 vòng
   chi phí món ăn 391.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~656.000 ₫
   · Lọc cứng loại 86/105 món; nhiều nhất do: nguyên liệu nuoc_mam (52), nguyên liệu trung_ga (19), nguyên liệu uc_ga_khong_da (17), equipment (16)
   · Bữa lunch: chỉ 2/8 món scale khớp được mục tiêu bữa (~659 kcal, ≥ 40 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ld_chay_gao_lut_dau_lang_su_su.
   · Bữa dinner: chỉ 2/8 món scale khớp được mục tiêu bữa (~659 kcal, ≥ 40 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ld_chay_gao_lut_dau_lang_su_su.
   · Ngày không đạt theo loại: kcal_low×4
   · Thiếu nặng nhất: 2026-11-15 kcal_low 29 kcal.

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1850 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 5) · 8 ms · 1 vòng
   chi phí món ăn 382.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~880.000 ₫

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2000 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 10 ms · 1 vòng
   chi phí món ăn 641.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.208.000 ₫

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1700 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 12 ms · 1 vòng
   chi phí món ăn 455.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.024.000 ₫

[LỖI] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Kỳ vọng chưa đạt: mọi công thức trong kho cần bep hoặc lo_nuong/noi_ap_suat; cần thêm món lò vi sóng.
   chỉ tiêu: 1330–1400 kcal, protein ≥ 120 g
   lỗi: Không có công thức hợp lệ cho bữa "breakfast" sau khi lọc
   · Lọc cứng loại 105/105 món; nhiều nhất do: equipment (105)
   · KHÔNG CÓ MÓN cho bữa "breakfast" sau khi lọc → cần thêm công thức breakfast phù hợp nhóm ràng buộc này.

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Kỳ vọng chưa đạt: 7 ngày đạm với ngân sách sát sàn có thể vượt; kiểm tra thông báo partial và chi phí.
   chỉ tiêu: 2328–2450 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 11 ms · 1 vòng
   chi phí món ăn 514.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.037.000 ₫

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2400 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 13 ms · 1 vòng
   chi phí món ăn 1.491.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.991.000 ₫

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2100 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 6) · 7 ms · 1 vòng
   chi phí món ăn 487.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~980.000 ₫

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1700 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 9 ms · 1 vòng
   chi phí món ăn 512.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~1.124.000 ₫

[PARTIAL] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1600 kcal, protein ≥ 110 g
   ngày đạt 5/7 (protein 5/7, kcal 5/7) · món khác nhau 9 (trưa/tối 4) · 221 ms · 12 vòng
   chi phí món ăn 1.182.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.511.000 ₫
   · Lọc cứng loại 16/105 món; nhiều nhất do: equipment (16)
   · Bữa lunch: chỉ 3/8 món scale khớp được mục tiêu bữa (~575 kcal, ≥ 41 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ga_sot_ca_chua.
   · Bữa snack_pm: chỉ 1/7 món scale khớp được mục tiêu bữa (~82 kcal, ≥ 6 g protein; dung sai protein 3 g, kcal 5%); gần nhất: khoai_tay_luoc_muoi.
   · Ngày không đạt theo loại: protein_low×2, kcal_high×2
   · Thiếu nặng nhất: 2026-11-09 protein_low 2 g.

TỔNG HỢP
  Hồ sơ đạt 7/7: 10/14 · partial 3 · lỗi 1
  Hồ sơ kỳ vọng đạt: 9/10 (90%)
  Ngày đạt: 84/91 (92%) · sàn protein 97% · dải calo 93%
  Vi phạm ràng buộc cứng: 0 · thời gian TB 49 ms, tối đa 262 ms

MA TRẬN PHỦ MÓN (số công thức dùng được / bữa; ⚠ = dưới 6)
  nhóm ràng buộc             breakfast     lunch    dinner  snack_am  snack_pm
  không ràng buộc                  28        49        49        13         7 
  chay                             10        10        10        11         5⚠
  thuần chay                        6         8         8         5⚠        3⚠
  chay có cá                       18        25        25        12         6 
  không lợn                        26        39        39        13         7 
  không thịt đỏ                    26        43        43        13         7 
  không trứng                      19        44        44        11         5⚠
  không sữa                        26        49        49         9         7 
  không gluten                     22        34        34        12         6 
  không đậu nành                   20        30        30        11         5⚠
  không cá                         15        17        17        11         5⚠
  không hải sản có vỏ              28        43        43        13         7 
  không lạc                        26        46        46        11         6 
  ít tinh bột (trưa/tối)           28        48        48        13         7 
  chỉ có bếp                       28        48        48        13         7 

MẬT ĐỘ PROTEIN MÓN TRƯA/TỐI Ở KHẨU PHẦN CHUẨN (% calo từ protein)
  62 món; trung vị 32%, thấp nhất 7% (ld_hk_ba_chi_kho_khoai_lang), cao nhất 77% (ga_hap_gung_hanh)
  ≥ 25% calo từ protein: 50/62 · ≥ 30%: 35/62 · ≥ 35%: 17/62
  kcal khẩu phần chuẩn: min 179, trung vị 513, max 891

ĐỘ PHỦ GIÁ (số nguyên liệu có giá riêng của cửa hàng / 46)
  bach_hoa_xanh    3/46  (phần thiếu dùng giá cho_khac)
  winmart          0/46  (phần thiếu dùng giá cho_khac)
  coopmart         0/46  (phần thiếu dùng giá cho_khac)
  cho_khac         46/46
  Nguyên liệu không dùng trong công thức nào: ca_tim
```
