# Engine report (T-011) — chạy trên data/ thật, hồ sơ tạm

Sinh bởi `npm run engine-report` (seed 1, bắt đầu 2026-11-09). Hồ sơ tạm ở `src/report/profiles.ts`; sẽ chuyển sang `data/test-profiles.json` khi T-048 xong.

```

BÁO CÁO ENGINE (T-011)

[PARTIAL] spec-nam-giam-mo — Ví dụ spec: 2.200 kcal / 175 g, 3 bữa
   chỉ tiêu: 2090–2200 kcal, protein ≥ 175 g
   ngày đạt 4/7 (protein 4/7, kcal 5/7) · món khác nhau 9 (trưa/tối 6) · 224 ms · 12 vòng
   chi phí món ăn 946.000 ₫ / ngân sách 900.000 ₫ ✗ VƯỢT · trả tại quầy ~1.576.000 ₫
   · Bữa breakfast: chỉ 2/10 món scale khớp được mục tiêu bữa (~477 kcal, ≥ 40 g protein; dung sai protein 3 g, kcal 5%); gần nhất: pho_ga_sang.
   · Ngày không đạt theo loại: protein_low×3, kcal_high×2
   · Thiếu nặng nhất: 2026-11-09 kcal_high 14 kcal.
   · Vượt ngân sách 46.000 ₫. Nguyên liệu tốn nhất: uc_ga_khong_da 234.650 ₫ (~190.000 ₫/kg, giá cho_khac); dui_ga_khong_da 144.000 ₫ (~160.000 ₫/kg, giá cho_khac); com_trang 136.800 ₫ (~32.000 ₫/kg, giá cho_khac); thit_heo_nac_dui 112.500 ₫ (~150.000 ₫/kg, giá cho_khac); thit_bo_nac 70.400 ₫ (~440.000 ₫/kg, giá cho_khac)

[PARTIAL] spec-nam-5-bua — Ví dụ spec nhưng 5 bữa (có 2 bữa phụ)
   chỉ tiêu: 2090–2200 kcal, protein ≥ 175 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 6) · 182 ms · 12 vòng
   chi phí món ăn 969.000 ₫ / ngân sách 900.000 ₫ ✗ VƯỢT · trả tại quầy ~1.629.000 ₫
   · Bữa breakfast: chỉ 3/10 món scale khớp được mục tiêu bữa (~429 kcal, ≥ 36 g protein; dung sai protein 3 g, kcal 5%); gần nhất: pho_ga_sang.
   · Bữa snack_pm: chỉ 1/7 món scale khớp được mục tiêu bữa (~107 kcal, ≥ 9 g protein; dung sai protein 3 g, kcal 5%); gần nhất: khoai_tay_luoc_muoi.
   · Vượt ngân sách 69.000 ₫. Nguyên liệu tốn nhất: thit_heo_xay_nac 137.500 ₫ (~110.000 ₫/kg, giá cho_khac); sua_chua_khong_duong 123.200 ₫ (~140.000 ₫/kg, giá cho_khac); com_trang 108.640 ₫ (~32.000 ₫/kg, giá cho_khac); thit_heo_nac_dui 108.000 ₫ (~150.000 ₫/kg, giá cho_khac); uc_ga_khong_da 92.150 ₫ (~190.000 ₫/kg, giá cho_khac)

[ĐẠT ] nu-nho-can-giam-mo — Nữ nhỏ cân, chạm trần 35% (~1.050–1.350 kcal)
   chỉ tiêu: 1235–1300 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 6) · 8 ms · 1 vòng
   chi phí món ăn 539.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~1.156.000 ₫

[PARTIAL] nam-tang-co-5-bua — Tăng cơ, 5 bữa, kcal cao
   chỉ tiêu: 3040–3200 kcal, protein ≥ 145 g
   ngày đạt 0/7 (protein 6/7, kcal 0/7) · món khác nhau 13 (trưa/tối 6) · 192 ms · 12 vòng
   chi phí món ăn 617.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.114.000 ₫
   · Bữa breakfast: chỉ 0/10 món scale khớp được mục tiêu bữa (~624 kcal, ≥ 30 g protein; dung sai protein 3 g, kcal 5%); gần nhất: com_chien_trung_sang.
   · Bữa lunch: chỉ 0/40 món scale khớp được mục tiêu bữa (~1092 kcal, ≥ 52 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ca_thu_sot_ca_chua.
   · Bữa lunch: cần ~1092 kcal nhưng món nhiều calo nhất (dau_phu_chien_sot_lac) chỉ đạt 1026 kcal khi scale tối đa → biên max_g của protein/carb quá chặt hoặc thiếu món calo cao.
   · Bữa dinner: chỉ 0/40 món scale khớp được mục tiêu bữa (~1092 kcal, ≥ 52 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ca_thu_sot_ca_chua.
   · Bữa dinner: cần ~1092 kcal nhưng món nhiều calo nhất (dau_phu_chien_sot_lac) chỉ đạt 1026 kcal khi scale tối đa → biên max_g của protein/carb quá chặt hoặc thiếu món calo cao.
   · Bữa snack_pm: chỉ 2/7 món scale khớp được mục tiêu bữa (~156 kcal, ≥ 7 g protein; dung sai protein 3 g, kcal 5%); gần nhất: khoai_tay_luoc_muoi.
   · Ngày không đạt theo loại: kcal_low×7, protein_low×1
   · Thiếu nặng nhất: 2026-11-10 kcal_low 703 kcal.

[ĐẠT ] nu-giu-can — Giữ cân, vận động nhẹ
   chỉ tiêu: 1615–1700 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 6) · 7 ms · 1 vòng
   chi phí món ăn 580.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~1.212.000 ₫

[ĐẠT ] chay-co-trung-sua — Chay (không thịt/cá), giảm mỡ
   chỉ tiêu: 1568–1650 kcal, protein ≥ 135 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 6 (trưa/tối 3) · 5 ms · 1 vòng
   chi phí món ăn 450.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~900.000 ₫

[LỖI] thuan-chay — Thuần chay — khắt khe về protein
   chỉ tiêu: 2375–2500 kcal, protein ≥ 120 g
   lỗi: Không có công thức hợp lệ cho bữa "breakfast" sau khi lọc
   · Lọc cứng loại 56/64 món; nhiều nhất do: nguyên liệu nuoc_mam (36), nguyên liệu trung_ga (11), nguyên liệu uc_ga_khong_da (10), nguyên liệu thit_bo_nac (6)
   · KHÔNG CÓ MÓN cho bữa "breakfast" sau khi lọc → cần thêm công thức breakfast phù hợp nhóm ràng buộc này.

[PARTIAL] chay-co-ca — Chay có cá (pescatarian)
   chỉ tiêu: 1948–2050 kcal, protein ≥ 155 g
   ngày đạt 1/7 (protein 1/7, kcal 4/7) · món khác nhau 9 (trưa/tối 6) · 111 ms · 12 vòng
   chi phí món ăn 666.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~1.118.000 ₫
   · Lọc cứng loại 28/64 món; nhiều nhất do: nguyên liệu uc_ga_khong_da (10), nguyên liệu thit_bo_nac (6), nguyên liệu thit_heo_xay_nac (5), nguyên liệu thit_heo_nac_dui (3)
   · Bữa breakfast: chỉ 0/6 món scale khớp được mục tiêu bữa (~444 kcal, ≥ 35 g protein; dung sai protein 3 g, kcal 5%); gần nhất: sua_chua_hat_sang.
   · Ngày không đạt theo loại: protein_low×6, kcal_high×3
   · Thiếu nặng nhất: 2026-11-13 kcal_high 43 kcal.

[PARTIAL] khat-khe-di-ung — Không lợn, không gluten, không lạc, không hải sản có vỏ, không trứng
   chỉ tiêu: 1995–2100 kcal, protein ≥ 165 g
   ngày đạt 4/7 (protein 4/7, kcal 4/7) · món khác nhau 6 (trưa/tối 4) · 108 ms · 12 vòng
   chi phí món ăn 662.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~1.102.000 ₫
   · Lọc cứng loại 37/64 món; nhiều nhất do: nguyên liệu trung_ga (11), nguyên liệu xi_dau (9), nguyên liệu lac (6), nguyên liệu thit_heo_xay_nac (5)
   · Bữa breakfast: chỉ còn 3 món hợp lệ (nên ≥ 6 để có đa dạng).
   · Bữa breakfast: chỉ 1/3 món scale khớp được mục tiêu bữa (~455 kcal, ≥ 37 g protein; dung sai protein 3 g, kcal 5%); gần nhất: pho_ga_sang.
   · Ngày không đạt theo loại: protein_low×3, kcal_low×3
   · Thiếu nặng nhất: 2026-11-14 kcal_low 378 kcal.

[PARTIAL] it-tinh-bot — Ít tinh bột (low-carb trưa/tối)
   chỉ tiêu: 2090–2200 kcal, protein ≥ 170 g
   ngày đạt 0/7 (protein 1/7, kcal 0/7) · món khác nhau 9 (trưa/tối 6) · 85 ms · 12 vòng
   chi phí món ăn 885.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~1.632.000 ₫
   · Bữa breakfast: chỉ 3/10 món scale khớp được mục tiêu bữa (~477 kcal, ≥ 39 g protein; dung sai protein 3 g, kcal 5%); gần nhất: pho_ga_sang.
   · Bữa lunch: chỉ 0/39 món scale khớp được mục tiêu bữa (~834 kcal, ≥ 67 g protein; dung sai protein 3 g, kcal 5%); gần nhất: dau_phu_sot_ca_chua.
   · Bữa lunch: cần ≥ 67 g protein trong ~834 kcal (32% calo từ protein), món mạnh nhất (dau_phu_sot_ca_chua) chỉ đạt 65 g khi scale tối đa → THIẾU MÓN GIÀU ĐẠM cho bữa này.
   · Bữa lunch: cần ~834 kcal nhưng món nhiều calo nhất (dau_phu_chien_sot_lac) chỉ đạt 636 kcal khi scale tối đa → biên max_g của protein/carb quá chặt hoặc thiếu món calo cao.
   · Bữa dinner: chỉ 0/39 món scale khớp được mục tiêu bữa (~834 kcal, ≥ 67 g protein; dung sai protein 3 g, kcal 5%); gần nhất: dau_phu_sot_ca_chua.
   · Bữa dinner: cần ≥ 67 g protein trong ~834 kcal (32% calo từ protein), món mạnh nhất (dau_phu_sot_ca_chua) chỉ đạt 65 g khi scale tối đa → THIẾU MÓN GIÀU ĐẠM cho bữa này.
   · Bữa dinner: cần ~834 kcal nhưng món nhiều calo nhất (dau_phu_chien_sot_lac) chỉ đạt 636 kcal khi scale tối đa → biên max_g của protein/carb quá chặt hoặc thiếu món calo cao.
   · Ngày không đạt theo loại: protein_low×6, kcal_low×7
   · Thiếu nặng nhất: 2026-11-10 kcal_low 686 kcal.

[PARTIAL] gia-dinh-2-lon-1-be — Hộ 2 người lớn + 1 trẻ em
   chỉ tiêu: 2090–2200 kcal, protein ≥ 170 g
   ngày đạt 4/7 (protein 4/7, kcal 7/7) · món khác nhau 9 (trưa/tối 6) · 137 ms · 12 vòng
   chi phí món ăn 1.838.000 ₫ / ngân sách 1.800.000 ₫ ✗ VƯỢT · trả tại quầy ~2.289.000 ₫
   · Bữa breakfast: chỉ 3/10 món scale khớp được mục tiêu bữa (~477 kcal, ≥ 39 g protein; dung sai protein 3 g, kcal 5%); gần nhất: pho_ga_sang.
   · Ngày không đạt theo loại: protein_low×3
   · Thiếu nặng nhất: 2026-11-09 protein_low 3 g.
   · Vượt ngân sách 38.000 ₫. Nguyên liệu tốn nhất: uc_ga_khong_da 378.290 ₫ (~190.000 ₫/kg, giá cho_khac); dui_ga_khong_da 282.240 ₫ (~160.000 ₫/kg, giá cho_khac); com_trang 257.760 ₫ (~32.000 ₫/kg, giá cho_khac); thit_heo_nac_dui 220.500 ₫ (~150.000 ₫/kg, giá cho_khac); dau_phu 157.200 ₫ (~40.000 ₫/kg, giá cho_khac)

[PARTIAL] chi-trua-toi-sang-tu-lo — Sáng tự lo, chỉ lên trưa + tối
   chỉ tiêu: 2328–2450 kcal, protein ≥ 120 g
   ngày đạt 1/7 (protein 7/7, kcal 1/7) · món khác nhau 6 (trưa/tối 6) · 114 ms · 12 vòng
   chi phí món ăn 548.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~1.017.000 ₫
   · Bữa lunch: chỉ 2/40 món scale khớp được mục tiêu bữa (~922 kcal, ≥ 48 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ca_thu_sot_ca_chua.
   · Bữa dinner: chỉ 2/40 món scale khớp được mục tiêu bữa (~922 kcal, ≥ 48 g protein; dung sai protein 3 g, kcal 5%); gần nhất: ca_thu_sot_ca_chua.
   · Ngày không đạt theo loại: kcal_low×6
   · Thiếu nặng nhất: 2026-11-10 kcal_low 204 kcal.

[PARTIAL] ngan-sach-thap — Ngân sách 350.000 ₫/tuần
   chỉ tiêu: 1568–1650 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 6 (trưa/tối 4) · 89 ms · 12 vòng
   chi phí món ăn 372.000 ₫ / ngân sách 350.000 ₫ ✗ VƯỢT · trả tại quầy ~769.000 ₫
   · Bữa breakfast: chỉ 3/10 món scale khớp được mục tiêu bữa (~358 kcal, ≥ 22 g protein; dung sai protein 3 g, kcal 5%); gần nhất: bun_bo_sang.
   · Vượt ngân sách 22.000 ₫. Nguyên liệu tốn nhất: com_trang 97.280 ₫ (~32.000 ₫/kg, giá cho_khac); dau_phu 86.800 ₫ (~40.000 ₫/kg, giá cho_khac); trung_ga 56.000 ₫ (~80.000 ₫/kg, giá cho_khac); khoai_lang 31.950 ₫ (~30.000 ₫/kg, giá cho_khac); thit_heo_xay_nac 31.900 ₫ (~110.000 ₫/kg, giá cho_khac)

[PARTIAL] chi-co-bep — Chỉ có bếp
   chỉ tiêu: 1900–2000 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 6) · 122 ms · 12 vòng
   chi phí món ăn 858.000 ₫ / ngân sách 800.000 ₫ ✗ VƯỢT · trả tại quầy ~1.494.000 ₫
   · Lọc cứng loại 8/64 món; nhiều nhất do: equipment (8)
   · Bữa breakfast: chỉ 3/10 món scale khớp được mục tiêu bữa (~433 kcal, ≥ 36 g protein; dung sai protein 3 g, kcal 5%); gần nhất: bun_bo_sang.
   · Vượt ngân sách 58.000 ₫. Nguyên liệu tốn nhất: uc_ga_khong_da 218.500 ₫ (~190.000 ₫/kg, giá cho_khac); thit_heo_xay_nac 138.050 ₫ (~110.000 ₫/kg, giá cho_khac); thit_heo_nac_than 120.000 ₫ (~160.000 ₫/kg, giá cho_khac); com_trang 117.440 ₫ (~32.000 ₫/kg, giá cho_khac); thit_bo_nac 59.400 ₫ (~440.000 ₫/kg, giá cho_khac)

[LỖI] cuc-ky-khat-khe — Thuần chay + không đậu nành + ít tinh bột
   chỉ tiêu: 1900–2000 kcal, protein ≥ 155 g
   lỗi: Không có công thức hợp lệ cho bữa "breakfast" sau khi lọc
   · Lọc cứng loại 59/64 món; nhiều nhất do: nguyên liệu nuoc_mam (36), nguyên liệu trung_ga (11), nguyên liệu uc_ga_khong_da (10), nguyên liệu xi_dau (9)
   · KHÔNG CÓ MÓN cho bữa "breakfast" sau khi lọc → cần thêm công thức breakfast phù hợp nhóm ràng buộc này.

TỔNG HỢP
  Hồ sơ đạt 7/7: 3/15 · partial 10 · lỗi 2
  Hồ sơ kỳ vọng đạt: 3/13 (23%)
  Ngày đạt: 56/91 (62%) · sàn protein 76% · dải calo 69%
  Vi phạm ràng buộc cứng: 0 · thời gian TB 92 ms, tối đa 224 ms

MA TRẬN PHỦ MÓN (số công thức dùng được / bữa; ⚠ = dưới 6)
  nhóm ràng buộc             breakfast     lunch    dinner  snack_am  snack_pm
  không ràng buộc                  10        40        40        14         7 
  chay                              3⚠        3⚠        3⚠       12         5⚠
  thuần chay                        0⚠        2⚠        2⚠        6         3⚠
  chay có cá                        6        17        17        13         6 
  không lợn                         9        31        31        14         7 
  không thịt đỏ                     9        35        35        14         7 
  không trứng                       5⚠       36        36        12         5⚠
  không sữa                         9        40        40        10         7 
  không gluten                      9        33        33        13         6 
  không đậu nành                    9        29        29        12         5⚠
  không cá                          5⚠        8         8        12         5⚠
  không hải sản có vỏ              10        36        36        14         7 
  không lạc                         9        37        37        12         6 
  ít tinh bột (trưa/tối)           10        39        39        14         7 
  chỉ có bếp                       10        33        33        13         7 

MẬT ĐỘ PROTEIN MÓN TRƯA/TỐI Ở KHẨU PHẦN CHUẨN (% calo từ protein)
  40 món; trung vị 33%, thấp nhất 20% (trung_nhoi_thit_tom), cao nhất 77% (ga_hap_gung_hanh)
  ≥ 25% calo từ protein: 38/40 · ≥ 30%: 27/40 · ≥ 35%: 13/40
  kcal khẩu phần chuẩn: min 179, trung vị 456, max 637

ĐỘ PHỦ GIÁ (số nguyên liệu có giá riêng của cửa hàng / 40)
  bach_hoa_xanh    3/40  (phần thiếu dùng giá cho_khac)
  winmart          0/40  (phần thiếu dùng giá cho_khac)
  coopmart         0/40  (phần thiếu dùng giá cho_khac)
  cho_khac         40/40
  Nguyên liệu không dùng trong công thức nào: thit_heo_ba_chi, ca_tim
```
