# Engine report — lượng cơm theo thói quen (T-094, T-096, cập nhật T-098)

Sinh bằng `dotnet backend/MonNgon.Tools/bin/<cfg>/net10.0/MonNgon.Tools.dll engine-report --data data --profiles data/test-profiles.json --rice <mức> [--seed n] [--levels] [--relaxed]` (auto). T-098 thêm: `bữa trưa/tối có cơm x/y (mâm a · trọn suất b) · phương án xếp hạng n`, `cơm khả thi ước lượng`, và (cờ `--levels`) `gạo sống cần mua it → vừa → nhiều → rất nhiều`, (cờ `--relaxed`) `món trưa/tối khác nhau khi nới ngân sách 20% → N`.

## Ma trận 16 hồ sơ × 4 mức (seed 1)

Mỗi ô: trạng thái · bữa trưa/tối có cơm / tổng · `f` = số bữa trọn suất có cơm trong đó · `a` = phương án xếp hạng đã dùng (1–7; 0 = một lượt, mức ít/vừa) · gạo sống cần mua (g/tuần) · thời gian lập tuần · `d` = số món trưa/tối khác nhau.

```
profile       |                 it                 |                vua                 |               nhieu                |             rat_nhieu             
p01           | ĐẠT  14/14 f0 a0 raw  290    307ms d12 | ĐẠT  14/14 f1 a0 raw  575    615ms d 9 | ĐẠT  14/14 f8 a4 raw  925   8849ms d 8 | ĐẠT  13/14 f12 a4 raw  990  17896ms d 6
p02           | ĐẠT  14/14 f0 a0 raw  359     66ms d11 | ĐẠT  12/14 f1 a0 raw  582    563ms d11 | ĐẠT  12/14 f11 a3 raw  654   9448ms d 8 | ĐẠT  4/14 f0 a7 raw  548  18959ms d 6
p03           | ĐẠT  14/14 f0 a0 raw  505     35ms d10 | ĐẠT  14/14 f0 a0 raw  910     51ms d10 | ĐẠT  14/14 f0 a1 raw 1583    184ms d11 | ĐẠT  14/14 f0 a1 raw 2306    361ms d11
p04           | ĐẠT  14/14 f0 a0 raw  464     58ms d 8 | ĐẠT  14/14 f0 a0 raw  866     70ms d11 | ĐẠT  14/14 f0 a1 raw 1622    201ms d 8 | ĐẠT  14/14 f0 a1 raw 2365    290ms d 9
p05           | ĐẠT  0/14 f0 a0 raw    0      8ms d11 | ĐẠT  0/14 f0 a0 raw    0     11ms d11 | ĐẠT  0/14 f0 a0 raw    0     10ms d11 | ĐẠT  0/14 f0 a0 raw    0      9ms d11
p06           | ĐẠT  14/14 f0 a0 raw  252     14ms d11 | ĐẠT  14/14 f0 a0 raw  256     19ms d11 | ĐẠT  14/14 f0 a1 raw  640    369ms d 9 | ĐẠT  14/14 f0 a1 raw  701   3020ms d10
p07           | ĐẠT  14/14 f0 a0 raw  374     37ms d11 | ĐẠT  14/14 f0 a0 raw  568     54ms d11 | ĐẠT  14/14 f1 a1 raw 1508    355ms d 8 | ĐẠT  14/14 f1 a8 raw 1508   3833ms d 8
p08           | ĐẠT  14/14 f0 a0 raw  268     38ms d 8 | ĐẠT  14/14 f0 a0 raw  613     48ms d10 | ĐẠT  14/14 f0 a1 raw 1559    171ms d10 | ĐẠT  14/14 f14 a2 raw 1598   4300ms d 7
p09           | ĐẠT  14/14 f0 a0 raw  522     76ms d 3 | ĐẠT  14/14 f0 a0 raw  797    338ms d 5 | ĐẠT  13/14 f1 a7 raw  825   4252ms d 7 | ĐẠT  8/14 f0 a7 raw  682  10969ms d 8
p10           | ĐẠT  14/14 f0 a0 raw  457     33ms d10 | ĐẠT  14/14 f0 a0 raw  674     38ms d11 | ĐẠT  14/14 f0 a1 raw 1629    204ms d 8 | ĐẠT  14/14 f0 a1 raw 1593    339ms d11
p11           | ĐẠT  14/14 f0 a0 raw 3082    224ms d 7 | ĐẠT  14/14 f0 a0 raw 3540    149ms d 9 | ĐẠT  14/14 f0 a1 raw 3800    353ms d 6 | ĐẠT  14/14 f0 a1 raw 4570    640ms d10
p12           | ĐẠT  14/14 f0 a0 raw  263     38ms d11 | ĐẠT  14/14 f0 a0 raw  582     63ms d11 | ĐẠT  14/14 f0 a1 raw 1494   1213ms d 9 | ĐẠT  14/14 f0 a1 raw 1473   2517ms d10
p13           | ĐẠT  14/14 f0 a0 raw  307     24ms d11 | ĐẠT  14/14 f0 a0 raw  410     33ms d 8 | ĐẠT  14/14 f0 a1 raw  817    397ms d 8 | ĐẠT  14/14 f0 a8 raw  817   1939ms d 8
p14           | ĐẠT  14/14 f0 a0 raw 2672     58ms d11 | ĐẠT  14/14 f0 a0 raw 3064    161ms d11 | ĐẠT  14/14 f0 a8 raw 3064   6985ms d11 | ĐẠT  0/14 f0 a7 raw    0  15285ms d 7
p15           | ĐẠT  14/14 f1 a0 raw 2595    247ms d 9 | ĐẠT  14/14 f1 a0 raw 2533    327ms d 7 | ĐẠT  14/14 f0 a4 raw 3137    640ms d 6 | ĐẠT  14/14 f0 a1 raw 3575    890ms d 9
p16           | ĐẠT  14/14 f0 a0 raw 1516     25ms d10 | ĐẠT  14/14 f0 a0 raw 1895     46ms d11 | ĐẠT  14/14 f0 a1 raw 2398    152ms d10 | ĐẠT  14/14 f0 a8 raw 2398   4654ms d10
non-monotonic raw rice: [('p02', [359, 582, 654, 548]), ('p09', [522, 797, 825, 682]), ('p10', [457, 674, 1629, 1593]), ('p12', [263, 582, 1494, 1473]), ('p14', [2672, 3064, 3064, 0]), ('p15', [2595, 2533, 3137, 3575])]
```

## Tóm tắt 4 mức (16 hồ sơ, seed 1)

```
[it]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 100%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 80 ms, tối đa 307 ms

[vua]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 1% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 162 ms, tối đa 615 ms

[nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 89%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 2111 ms, tối đa 9448 ms

[rat_nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 5369 ms, tối đa 18959 ms

```

## Seed 2 và 3 (tóm tắt)

```
[vua · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 97%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 1% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 161 ms, tối đa 677 ms

[nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 86%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 2163 ms, tối đa 9078 ms

[rat_nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 5426 ms, tối đa 18761 ms

[vua · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 1% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 128 ms, tối đa 531 ms

[nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 83%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 28% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 2218 ms, tối đa 9435 ms

[rat_nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 5545 ms, tối đa 18915 ms

```

## Gạo sống 4 mức và số món trưa/tối khi nới ngân sách 20% (seed 1, `--rice vua --levels --relaxed`)

```
p01_nu_giam_mo_vua
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 626 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 575 → 925 → 990
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p02_nu_nho_can_giam_mo_1350
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 11) · 560 ms · 1 vòng · % bữa ghép mâm 79% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 582 → 654 → 548  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 12

p03_nam_tang_co_2800
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 50 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 505 → 910 → 1.583 → 2.306
   món trưa/tối khác nhau khi nới ngân sách 20% → 10

p04_nam_giu_can
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 84 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 464 → 866 → 1.622 → 2.365
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p05_thuan_chay_it_tinh_bot
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 5 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p06_chay_lacto_nu
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 21 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 252 → 256 → 640 → 701
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p07_khong_lon_khong_sua
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 47 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 374 → 568 → 1.508 → 1.508
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p08_di_ung_lac_hat_cay
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 67 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 268 → 613 → 1.559 → 1.598
   món trưa/tối khác nhau khi nới ngân sách 20% → 10

p09_chi_co_lo_vi_song
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 5) · 363 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 522 → 797 → 825 → 682  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 6

p10_ngan_sach_toi_thieu
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 42 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 457 → 674 → 1.629 → 1.593  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p11_ho_2_nguoi_lon_2_tre
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 159 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 3.082 → 3.540 → 3.800 → 4.570
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p12_bua_sang_tu_lo
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 60 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 263 → 582 → 1.494 → 1.473  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p13_nhieu_mon_ghet
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 34 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 307 → 410 → 817 → 817
   món trưa/tối khác nhau khi nới ngân sách 20% → 8

p14_ho_3_nguoi_lon
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 184 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.672 → 3.064 → 3.064 → 2.678  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p15_chi_noi_chien_va_noi_com
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 7) · 354 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.595 → 2.533 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 6

p16_chi_bep_va_noi_chien
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 35 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 1.516 → 1.895 → 2.398 → 2.398
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

```

## Chi tiết từng hồ sơ — mức vua (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 615 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 617.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~966.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 13 · trọn suất 1) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 13/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 575 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.060 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 110 g · trung vị 150 g · 7% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 575 g/tuần
   khẩu vị thích: 85% bữa mâm khớp · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 86%)
   dụng cụ (% bữa): bep 100% · noi_com_dien 29%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 11) · 563 ms · 1 vòng · % bữa ghép mâm 79% · % có tráng miệng 100%
   chi phí món ăn 589.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~939.000 ₫
   bữa trưa/tối có cơm: 12/14 (mâm 11 · trọn suất 1) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 125 g (~0.5 chén) / mức chọn 150 g → CẢNH BÁO onboarding (lý do budget) · bữa trưa/tối đủ cơm 11/14 · bữa có cơm 12/14 · ngân sách 600.000 ₫, cần ≥ không phương án nào đủ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 582 → 654 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 1.750 → 1.825 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 12
   cơm (vua, mức 150 g): thực tế min 100 g · trung vị 150 g · 8% bữa mâm có ghi chú giảm cơm (12 bữa) · gạo sống cần mua 582 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 93%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 51 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 767.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.060.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 505 → 910 → 1.583 → 2.306
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 910 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 70 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 551.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~810.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 464 → 866 → 1.622 → 2.365
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 866 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 11 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   bữa trưa/tối có cơm: 0/14 (mâm 0 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 19 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 497.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~786.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 252 → 256 → 640 → 701
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.370
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 225 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 256 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 49%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 54 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 571.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~861.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 374 → 568 → 1.508 → 1.508
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 568 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 50%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 48 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 467.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~684.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 268 → 613 → 1.559 → 1.598
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.425
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 613 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 5) · 338 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 600.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~820.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 522 → 797 → 825 → 682  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.355 → 1.800  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 797 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 38 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 564.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~779.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 457 → 674 → 1.629 → 1.593  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 674 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 149 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.490.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.482.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 3.082 → 3.540 → 3.800 → 4.570
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.130 → 2.175 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.540 g/tuần
   khẩu vị thích: 93% bữa mâm khớp · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 63 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 514.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~827.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 263 → 582 → 1.494 → 1.473  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.175
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 582 g/tuần
   khẩu vị thích: không chọn · 9 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 43%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 33 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 571.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~898.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 307 → 410 → 817 → 817
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 188 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 410 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 36%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 161 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.189.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.243.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.672 → 3.064 → 3.064 → 2.678  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 0  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.064 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 7) · 327 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 1.178.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.175.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 13 · trọn suất 1) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.595 → 2.533 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.325 → 2.350 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.533 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): noi_com_dien 81% · noi_chien_khong_dau 62%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 46 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 729.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~918.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 1.516 → 1.895 → 2.398 → 2.398
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.895 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 29%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 88% · noi_com_dien 28% · lo_vi_song 6% · noi_chien_khong_dau 6%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 1% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 162 ms, tối đa 615 ms
```

## Chi tiết từng hồ sơ — mức nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 8849 ms · 4 vòng · % bữa ghép mâm 43% · % có tráng miệng 100%
   chi phí món ăn 574.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~783.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 6 · trọn suất 8) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 575 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.060 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 175 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 925 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 79%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 36%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 8) · 9448 ms · 6 vòng · % bữa ghép mâm 7% · % có tráng miệng 100%
   chi phí món ăn 586.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~916.000 ₫
   bữa trưa/tối có cơm: 12/14 (mâm 1 · trọn suất 11) · phương án xếp hạng 3
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 582 → 654 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 1.750 → 1.825 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 150 g · 100% bữa mâm có ghi chú giảm cơm (12 bữa) · gạo sống cần mua 654 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 71%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 184 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 935.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.203.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 505 → 910 → 1.583 → 2.306
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.583 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 86% · lo_nuong 14%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 201 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 629.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~895.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 464 → 866 → 1.622 → 2.365
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.622 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 89% · noi_com_dien 57%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 10 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   bữa trưa/tối có cơm: 0/14 (mâm 0 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 9) · 369 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 592.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~860.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 252 → 256 → 640 → 701
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.370
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 455 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 640 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 46%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 355 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 684.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~820.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 13 · trọn suất 1) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 374 → 568 → 1.508 → 1.508
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.508 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 54%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 10) · 171 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 608.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~981.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 268 → 613 → 1.559 → 1.598
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.425
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.559 g/tuần
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 86% · noi_com_dien 54%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 4252 ms · 3 vòng · % bữa ghép mâm 86% · % có tráng miệng 100%
   chi phí món ăn 599.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~807.000 ₫
   bữa trưa/tối có cơm: 13/14 (mâm 12 · trọn suất 1) · phương án xếp hạng 7
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 522 → 797 → 825 → 682  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.355 → 1.800  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 175 g · 100% bữa mâm có ghi chú giảm cơm (13 bữa) · gạo sống cần mua 825 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 14%)
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 204 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 583.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~860.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 457 → 674 → 1.629 → 1.593  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.629 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 89% · noi_com_dien 54%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 6) · 353 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.500.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.532.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 3.082 → 3.540 → 3.800 → 4.570
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.130 → 2.175 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.800 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 46%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 9) · 1213 ms · 2 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 682.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~997.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 263 → 582 → 1.494 → 1.473  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.175
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.494 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 24%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 397 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 641.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~952.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 307 → 410 → 817 → 817
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 7
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 378 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 817 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 86% · noi_com_dien 46%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 6985 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.189.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.243.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 8
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do budget) · bữa trưa/tối đủ cơm 0/14 · bữa có cơm 14/14 · ngân sách 1.200.000 ₫, cần ≥ 1.536.000 ₫ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.672 → 3.064 → 3.064 → 2.678  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 0  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 150 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.064 g/tuần
   khẩu vị thích: không chọn · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 8 (trưa/tối 6) · 640 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.198.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.343.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.595 → 2.533 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.325 → 2.350 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.137 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 90% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 152 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 898.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~1.106.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 1.516 → 1.895 → 2.398 → 2.398
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.398 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 33%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 89%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 82% · noi_com_dien 32% · lo_vi_song 6% · noi_chien_khong_dau 6% · lo_nuong 1%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 2111 ms, tối đa 9448 ms
```

## Chi tiết từng hồ sơ — mức rat_nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 17896 ms · 12 vòng · % bữa ghép mâm 7% · % có tráng miệng 100%
   chi phí món ăn 645.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~862.000 ₫
   bữa trưa/tối có cơm: 13/14 (mâm 1 · trọn suất 12) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 575 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.060 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (13 bữa) · gạo sống cần mua 990 g/tuần
   khẩu vị thích: 0% bữa mâm khớp · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 79%, đủ dụng cụ → 57%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 36%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 6) · 18959 ms · 3 vòng · % bữa ghép mâm 29% · % có tráng miệng 100%
   chi phí món ăn 596.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~824.000 ₫
   bữa trưa/tối có cơm: 4/14 (mâm 4 · trọn suất 0) · phương án xếp hạng 7
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14 · bữa có cơm 4/14 · ngân sách 600.000 ₫, cần ≥ 806.000 ₫ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 582 → 654 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 1.750 → 1.825 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (4 bữa) · gạo sống cần mua 548 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 50%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 361 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 745.000 ₫ / ngân sách 1.000.000 ₫ ✓ · trả tại quầy ~1.050.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 505 → 910 → 1.583 → 2.306
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.306 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 86% · lo_nuong 29%

[ĐẠT ] p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu — Đường cơ bản.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 290 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 572.000 ₫ / ngân sách 800.000 ₫ ✓ · trả tại quầy ~851.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 464 → 866 → 1.622 → 2.365
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.365 g/tuần
   khẩu vị thích: không chọn · 8 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 89% · noi_com_dien 46%

[ĐẠT ] p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột — Đạt 7/7 sau lô 2–3 (thêm món chay calo cao không cơm).
   chỉ tiêu: 1663–1838 kcal, protein ≥ 100 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 9 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 424.000 ₫ / ngân sách 550.000 ₫ ✓ · trả tại quầy ~545.000 ₫
   bữa trưa/tối có cơm: 0/14 (mâm 0 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 450 g → đủ
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   khẩu vị thích: không chọn · 1 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p06_chay_lacto_nu — Ăn chay (có trứng, sữa) — Kỳ vọng đạt; nhiều món đậu phụ và trứng.
   chỉ tiêu: 1758–1943 kcal, protein ≥ 90 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 3020 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 563.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~736.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 400 g (~2.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 252 → 256 → 640 → 701
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.370
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 250 g · trung vị 405 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 701 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 46%

[ĐẠT ] p07_khong_lon_khong_sua — Không lợn, không sữa — Kỳ vọng đạt; kho còn bò, gà, cá, đậu.
   chỉ tiêu: 1900–2100 kcal, protein ≥ 155 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 3833 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 684.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~820.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 13 · trọn suất 1) · phương án xếp hạng 8
   cơm khả thi: ước lượng kcal/đạm 350 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 374 → 568 → 1.508 → 1.508
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (rat_nhieu, mức 450 g): thực tế min 300 g · trung vị 300 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.508 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 54%

[ĐẠT ] p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây — Kiểm tra: không món nào chứa lạc (kể cả món 'lạc rang muối' và 'sốt lạc').
   chỉ tiêu: 1615–1785 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 4300 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
   chi phí món ăn 481.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~627.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 0 · trọn suất 14) · phương án xếp hạng 2
   cơm khả thi: ước lượng kcal/đạm 325 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 268 → 613 → 1.559 → 1.598
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.425
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (rat_nhieu, mức 450 g): thực tế min 250 g · trung vị 313 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.598 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 75% · noi_com_dien 36%

[ĐẠT ] p09_chi_co_lo_vi_song — Chỉ có lò vi sóng — Đạt 7/7 sau lô 3 (20 món chỉ cần lò vi sóng).
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 10969 ms · 3 vòng · % bữa ghép mâm 57% · % có tráng miệng 100%
   chi phí món ăn 591.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~849.000 ₫
   bữa trưa/tối có cơm: 8/14 (mâm 8 · trọn suất 0) · phương án xếp hạng 7
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14 · bữa có cơm 8/14 · ngân sách 600.000 ₫, cần ≥ 629.000 ₫ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 522 → 797 → 825 → 682  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.355 → 1.800  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (8 bữa) · gạo sống cần mua 682 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 79%, đủ dụng cụ → 7%)
   dụng cụ (% bữa): lo_vi_song 100%

[ĐẠT ] p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) — Đạt 7/7 với ngân sách sát sàn.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 115 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 339 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 598.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~904.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 457 → 674 → 1.629 → 1.593  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.593 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 89% · noi_com_dien 50%

[ĐẠT ] p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em — Kiểm tra: danh sách đi chợ nhân số người, trẻ 0,6 suất.
   chỉ tiêu: 2280–2520 kcal, protein ≥ 125 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 640 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.469.000 ₫ / ngân sách 1.500.000 ₫ ✓ · trả tại quầy ~1.493.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 3.082 → 3.540 → 3.800 → 4.570
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.130 → 2.175 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 4.570 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 2 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 39%

[ĐẠT ] p12_bua_sang_tu_lo — Bữa sáng tự lo — Kiểm tra: bữa sáng không lên món nhưng chỉ tiêu được phân bổ.
   chỉ tiêu: 1995–2205 kcal, protein ≥ 160 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 2517 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 635.000 ₫ / ngân sách 700.000 ₫ ✓ · trả tại quầy ~897.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 263 → 582 → 1.494 → 1.473  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.175
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 250 g · trung vị 300 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 1.473 g/tuần
   khẩu vị thích: không chọn · 5 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 33%

[ĐẠT ] p13_nhieu_mon_ghet — Nhiều món không thích — Kiểm tra: không món nào chứa nguyên liệu ghét; có thể ít món hơn.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 95 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 1939 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 641.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~952.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 8
   cơm khả thi: ước lượng kcal/đạm 350 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 307 → 410 → 817 → 817
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 7
   cơm (rat_nhieu, mức 450 g): thực tế min 300 g · trung vị 378 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 817 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 86% · noi_com_dien 46%

[ĐẠT ] p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ — Kiểm tra: lunch packed chỉ dùng món 'packed' khả dụng.
   chỉ tiêu: 1520–1680 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 15285 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
   chi phí món ăn 1.137.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.212.000 ₫
   bữa trưa/tối có cơm: 0/14 (mâm 0 · trọn suất 0) · phương án xếp hạng 7
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14 · bữa có cơm 0/14 · ngân sách 1.200.000 ₫, cần ≥ 1.483.000 ₫ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.672 → 3.064 → 3.064 → 2.678  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 0  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 8
   khẩu vị thích: không chọn · 7 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 0%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 2328–2573 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 9) · 890 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.171.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.255.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.595 → 2.533 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.325 → 2.350 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 12
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.575 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 76% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 4654 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 898.000 ₫ / ngân sách 900.000 ₫ ✓ · trả tại quầy ~1.106.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 8
   cơm khả thi: ước lượng kcal/đạm 350 g (~2 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 1.516 → 1.895 → 2.398 → 2.398
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 4.200
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 300 g · trung vị 300 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.398 g/tuần
   khẩu vị thích: không chọn · 6 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_chien_khong_dau 33%

TỔNG HỢP
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Hồ sơ kỳ vọng đạt: 14/14 (100%)
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 81% · noi_com_dien 29% · lo_vi_song 6% · noi_chien_khong_dau 6% · lo_nuong 2%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 5369 ms, tối đa 18959 ms
```
