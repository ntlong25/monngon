# Engine report — lượng cơm theo thói quen (T-094, T-096, cập nhật T-098)

Sinh bằng `dotnet backend/MonNgon.Tools/bin/<cfg>/net10.0/MonNgon.Tools.dll engine-report --data data --profiles data/test-profiles.json --rice <mức> [--seed n] [--levels] [--relaxed]` (auto). T-098 thêm: `bữa trưa/tối có cơm x/y (mâm a · trọn suất b) · phương án xếp hạng n`, `cơm khả thi ước lượng`, và (cờ `--levels`) `gạo sống cần mua it → vừa → nhiều → rất nhiều`, (cờ `--relaxed`) `món trưa/tối khác nhau khi nới ngân sách 20% → N`.

## Ma trận 16 hồ sơ × 4 mức (seed 1)

Mỗi ô: trạng thái · bữa trưa/tối có cơm / tổng · `f` = số bữa trọn suất có cơm trong đó · `a` = phương án xếp hạng đã dùng (1–7; 0 = một lượt, mức ít/vừa) · gạo sống cần mua (g/tuần) · thời gian lập tuần · `d` = số món trưa/tối khác nhau.

```
profile       |                 it                 |                vua                 |               nhieu                |             rat_nhieu             
p01           | ĐẠT  14/14 f0 a0 raw  290    480ms d12 | ĐẠT  14/14 f0 a0 raw  607    702ms d 9 | ĐẠT  14/14 f8 a4 raw  925   8214ms d 8 | ĐẠT  13/14 f12 a4 raw  990  16145ms d 6
p02           | ĐẠT  14/14 f0 a0 raw  359     61ms d11 | ĐẠT  14/14 f4 a0 raw  689    403ms d 9 | ĐẠT  14/14 f4 a8 raw  689   8159ms d 9 | ĐẠT  4/14 f0 a7 raw  548  16866ms d 6
p03           | ĐẠT  14/14 f0 a0 raw  505     33ms d10 | ĐẠT  14/14 f0 a0 raw  910     40ms d10 | ĐẠT  14/14 f0 a1 raw 1583    157ms d11 | ĐẠT  14/14 f0 a1 raw 2306    313ms d11
p04           | ĐẠT  14/14 f0 a0 raw  464     50ms d 8 | ĐẠT  14/14 f0 a0 raw  866     49ms d11 | ĐẠT  14/14 f0 a1 raw 1622    163ms d 8 | ĐẠT  14/14 f0 a1 raw 2365    278ms d 9
p05           | ĐẠT  0/14 f0 a0 raw    0      5ms d11 | ĐẠT  0/14 f0 a0 raw    0      6ms d11 | ĐẠT  0/14 f0 a0 raw    0      6ms d11 | ĐẠT  0/14 f0 a0 raw    0      6ms d11
p06           | ĐẠT  14/14 f0 a0 raw  252     13ms d11 | ĐẠT  14/14 f0 a0 raw  256     19ms d11 | ĐẠT  14/14 f0 a1 raw  640    287ms d 9 | ĐẠT  14/14 f0 a1 raw  701   2587ms d10
p07           | ĐẠT  14/14 f0 a0 raw  374     28ms d11 | ĐẠT  14/14 f0 a0 raw  568     49ms d11 | ĐẠT  14/14 f1 a1 raw 1508    343ms d 8 | ĐẠT  14/14 f1 a8 raw 1508   3325ms d 8
p08           | ĐẠT  14/14 f0 a0 raw  268     36ms d 8 | ĐẠT  14/14 f0 a0 raw  613     64ms d10 | ĐẠT  14/14 f0 a1 raw 1559    175ms d10 | ĐẠT  14/14 f14 a2 raw 1598   3726ms d 7
p09           | ĐẠT  14/14 f0 a0 raw  522     56ms d 3 | ĐẠT  14/14 f0 a0 raw  797    180ms d 5 | ĐẠT  13/14 f1 a7 raw  825   3661ms d 7 | ĐẠT  8/14 f0 a7 raw  682   9813ms d 8
p10           | ĐẠT  14/14 f0 a0 raw  457     29ms d10 | ĐẠT  14/14 f0 a0 raw  674     38ms d11 | ĐẠT  14/14 f0 a1 raw 1629    151ms d 8 | ĐẠT  14/14 f0 a1 raw 1593    308ms d11
p11           | ĐẠT  14/14 f0 a0 raw 3082    128ms d 7 | ĐẠT  14/14 f0 a0 raw 3540     87ms d 9 | ĐẠT  14/14 f0 a1 raw 3800    285ms d 6 | ĐẠT  14/14 f0 a1 raw 4570    530ms d10
p12           | ĐẠT  14/14 f0 a0 raw  263     27ms d11 | ĐẠT  14/14 f0 a0 raw  582     46ms d11 | ĐẠT  14/14 f0 a1 raw 1494   1091ms d 9 | ĐẠT  14/14 f0 a1 raw 1473   2196ms d10
p13           | ĐẠT  14/14 f0 a0 raw  307     21ms d11 | ĐẠT  14/14 f0 a0 raw  410     35ms d 8 | ĐẠT  14/14 f0 a1 raw  817    285ms d 8 | ĐẠT  14/14 f0 a8 raw  817   1787ms d 8
p14           | ĐẠT  14/14 f0 a0 raw 2672     47ms d11 | ĐẠT  14/14 f0 a0 raw 3064    117ms d11 | ĐẠT  14/14 f0 a8 raw 3064   6029ms d11 | ĐẠT  0/14 f0 a7 raw    0  13536ms d 7
p15           | ĐẠT  14/14 f1 a0 raw 2536    179ms d 9 | ĐẠT  14/14 f1 a0 raw 2455    256ms d 7 | ĐẠT  14/14 f0 a4 raw 3137    495ms d 6 | ĐẠT  14/14 f0 a1 raw 3575    703ms d 9
p16           | ĐẠT  14/14 f0 a0 raw 1516     24ms d10 | ĐẠT  14/14 f0 a0 raw 1895     33ms d11 | ĐẠT  14/14 f0 a1 raw 2398    150ms d10 | ĐẠT  14/14 f0 a8 raw 2398   4154ms d10
non-monotonic raw rice: [('p02', [359, 689, 689, 548]), ('p09', [522, 797, 825, 682]), ('p10', [457, 674, 1629, 1593]), ('p12', [263, 582, 1494, 1473]), ('p14', [2672, 3064, 3064, 0]), ('p15', [2536, 2455, 3137, 3575])]
```

## Tóm tắt 4 mức (16 hồ sơ, seed 1)

```
[it]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 100%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 76 ms, tối đa 480 ms

[vua]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 98%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 133 ms, tối đa 702 ms

[nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 93%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1853 ms, tối đa 8214 ms

[rat_nhieu]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 4767 ms, tối đa 16866 ms

```

## Seed 2 và 3 (tóm tắt)

```
[vua · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 97%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 163 ms, tối đa 1229 ms

[nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 86%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1877 ms, tối đa 7991 ms

[rat_nhieu · seed 2]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 4760 ms, tối đa 16318 ms

[vua · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 97%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 159 ms, tối đa 1331 ms

[nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 83%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 28% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1930 ms, tối đa 8468 ms

[rat_nhieu · seed 3]
  Hồ sơ đạt 7/7: 16/16 · partial 0 · lỗi 0
  Ngày đạt: 112/112 (100%) · sàn protein 100% · dải calo 100%
  % bữa ghép mâm (trưa/tối ≥ 2 món): 74%
  Cơm: 14 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 64% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p06_chay_lacto_nu, p07_khong_lon_khong_sua, p08_di_ung_lac_hat_cay, p09_chi_co_lo_vi_song, p12_bua_sang_tu_lo, p13_nhieu_mon_ghet, p16_chi_bep_va_noi_chien · dưới sàn/không ghi chú: 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 4824 ms, tối đa 16663 ms

```

## Gạo sống 4 mức và số món trưa/tối khi nới ngân sách 20% (seed 1, `--rice vua --levels --relaxed`)

```
p01_nu_giam_mo_vua
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 713 ms · 2 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 607 → 925 → 990
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p02_nu_nho_can_giam_mo_1350
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 9) · 426 ms · 1 vòng · % bữa ghép mâm 71% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 689 → 689 → 548  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 12

p03_nam_tang_co_2800
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 41 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 505 → 910 → 1.583 → 2.306
   món trưa/tối khác nhau khi nới ngân sách 20% → 10

p04_nam_giu_can
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 52 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 464 → 866 → 1.622 → 2.365
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p05_thuan_chay_it_tinh_bot
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 0 → 0 → 0 → 0
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p06_chay_lacto_nu
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 19 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 252 → 256 → 640 → 701
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p07_khong_lon_khong_sua
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 45 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 374 → 568 → 1.508 → 1.508
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p08_di_ung_lac_hat_cay
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 46 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 268 → 613 → 1.559 → 1.598
   món trưa/tối khác nhau khi nới ngân sách 20% → 10

p09_chi_co_lo_vi_song
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 5) · 178 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 522 → 797 → 825 → 682  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 6

p10_ngan_sach_toi_thieu
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 38 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 457 → 674 → 1.629 → 1.593  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p11_ho_2_nguoi_lon_2_tre
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 87 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 3.082 → 3.540 → 3.800 → 4.570
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p12_bua_sang_tu_lo
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 43 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 263 → 582 → 1.494 → 1.473  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p13_nhieu_mon_ghet
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 25 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 307 → 410 → 817 → 817
   món trưa/tối khác nhau khi nới ngân sách 20% → 8

p14_ho_3_nguoi_lon
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 117 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.672 → 3.064 → 3.064 → 2.678  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

p15_chi_noi_chien_va_noi_com
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 7) · 268 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.536 → 2.455 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   món trưa/tối khác nhau khi nới ngân sách 20% → 6

p16_chi_bep_va_noi_chien
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 40 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 1.516 → 1.895 → 2.398 → 2.398
   món trưa/tối khác nhau khi nới ngân sách 20% → 11

```

## Chi tiết từng hồ sơ — mức vua (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 702 ms · 2 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 639.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~924.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 607 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 607 g/tuần
   khẩu vị thích: 86% bữa mâm khớp · 4 loại tráng miệng/tuần
   dụng cụ (% bữa): bep 100% · noi_com_dien 32%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 9) · 403 ms · 1 vòng · % bữa ghép mâm 71% · % có tráng miệng 100%
   chi phí món ăn 595.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~866.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 10 · trọn suất 4) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 125 g (~0.5 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 689 → 689 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 12
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 689 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 40 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 49 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 49 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 64 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 10 (trưa/tối 5) · 180 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 87 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 46 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 35 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 117 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 9 (trưa/tối 7) · 256 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
   chi phí món ăn 1.192.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.176.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 13 · trọn suất 1) · phương án xếp hạng 0
   cơm khả thi: ước lượng kcal/đạm 150 g (~1 chén) / mức chọn 150 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.536 → 2.455 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (vua, mức 150 g): thực tế min 150 g · trung vị 150 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 2.455 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 100%)
   dụng cụ (% bữa): noi_com_dien 81% · noi_chien_khong_dau 62%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 11) · 33 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 0% · hồ sơ >20% bữa có ghi chú: không · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 133 ms, tối đa 702 ms
```

## Chi tiết từng hồ sơ — mức nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 8214 ms · 4 vòng · % bữa ghép mâm 43% · % có tráng miệng 100%
   chi phí món ăn 574.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~783.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 6 · trọn suất 8) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 607 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 11
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 175 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 925 g/tuần
   khẩu vị thích: 100% bữa mâm khớp · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 79%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 36%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 9) · 8159 ms · 1 vòng · % bữa ghép mâm 71% · % có tráng miệng 100%
   chi phí món ăn 595.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~866.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 10 · trọn suất 4) · phương án xếp hạng 8
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 300 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 689 → 689 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (nhieu, mức 300 g): thực tế min 150 g · trung vị 150 g · 100% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 689 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 71%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 157 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 163 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 9) · 287 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 343 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 10) · 175 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 3661 ms · 3 vòng · % bữa ghép mâm 86% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 151 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 6) · 285 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 9) · 1091 ms · 2 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 285 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 6029 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 8 (trưa/tối 6) · 495 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.198.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.343.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 300 g (~2 chén) / mức chọn 300 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.536 → 2.455 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 6
   cơm (nhieu, mức 300 g): thực tế min 300 g · trung vị 300 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.137 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 90% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 150 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
  % bữa ghép mâm (trưa/tối ≥ 2 món): 93%
  Dụng cụ (% bữa, trung bình các hồ sơ): bep 82% · noi_com_dien 32% · lo_vi_song 6% · noi_chien_khong_dau 6% · lo_nuong 1%
  Cơm: 15 hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB 27% · hồ sơ >20% bữa có ghi chú: p01_nu_giam_mo_vua, p02_nu_nho_can_giam_mo_1350, p09_chi_co_lo_vi_song, p14_ho_3_nguoi_lon · dưới sàn/không ghi chú: 0
  % bữa trưa/tối có tráng miệng: 100% · thiếu (dessert_missing): 0
  Vi phạm ràng buộc cứng: 0 · thời gian TB 1853 ms, tối đa 8214 ms
```

## Chi tiết từng hồ sơ — mức rat_nhieu (seed 1)

```
BÁO CÁO ENGINE (C#)

[ĐẠT ] p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa — Đường cơ bản; kỳ vọng đạt 7/7 ngày.
   chỉ tiêu: 1330–1470 kcal, protein ≥ 120 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 6) · 16145 ms · 12 vòng · % bữa ghép mâm 7% · % có tráng miệng 100%
   chi phí món ăn 645.000 ₫ / ngân sách 650.000 ₫ ✓ · trả tại quầy ~862.000 ₫
   bữa trưa/tối có cơm: 13/14 (mâm 1 · trọn suất 12) · phương án xếp hạng 4
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 290 → 607 → 925 → 990
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.600 → 2.985
   món trưa/tối khác nhau khi nới ngân sách 20% → 10
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (13 bữa) · gạo sống cần mua 990 g/tuần
   khẩu vị thích: 0% bữa mâm khớp · 5 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 79%, đủ dụng cụ → 57%)
   dụng cụ (% bữa): bep 89% · noi_com_dien 36%

[ĐẠT ] p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g — Ca khó nhất theo video; nếu không đạt thì kiểm tra số món đạm ít béo.
   chỉ tiêu: 1283–1418 kcal, protein ≥ 110 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 6) · 16866 ms · 3 vòng · % bữa ghép mâm 29% · % có tráng miệng 100%
   chi phí món ăn 596.000 ₫ / ngân sách 600.000 ₫ ✓ · trả tại quầy ~824.000 ₫
   bữa trưa/tối có cơm: 4/14 (mâm 4 · trọn suất 0) · phương án xếp hạng 7
   cơm khả thi: ước lượng kcal/đạm 225 g (~1.5 chén) / mức chọn 450 g → CẢNH BÁO onboarding (lý do kcal_protein) · bữa trưa/tối đủ cơm 0/14 · bữa có cơm 4/14 · ngân sách 600.000 ₫, cần ≥ 806.000 ₫ để ≥ 12/14 bữa có cơm
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 359 → 689 → 689 → 548  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 2.100 → 900  ✗ GIẢM > 2%
   món trưa/tối khác nhau khi nới ngân sách 20% → 9
   cơm (rat_nhieu, mức 450 g): thực tế min 225 g · trung vị 225 g · 100% bữa mâm có ghi chú giảm cơm (4 bữa) · gạo sống cần mua 548 g/tuần
   khẩu vị thích: không chọn · 4 loại tráng miệng/tuần
   lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 50%)
   dụng cụ (% bữa): bep 100%

[ĐẠT ] p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal — Đạt 7/7 sau lô 3 (bổ sung món phụ và tinh chỉnh ngày).
   chỉ tiêu: 2660–2940 kcal, protein ≥ 180 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 19 (trưa/tối 11) · 313 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 15 (trưa/tối 9) · 278 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 11) · 6 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 18 (trưa/tối 10) · 2587 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 14 (trưa/tối 8) · 3325 ms · 1 vòng · % bữa ghép mâm 93% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 3726 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 9813 ms · 3 vòng · % bữa ghép mâm 57% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 17 (trưa/tối 11) · 308 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 16 (trưa/tối 10) · 530 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 2196 ms · 3 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 8) · 1787 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 12 (trưa/tối 7) · 13536 ms · 7 vòng · % bữa ghép mâm 0% · % có tráng miệng 100%
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
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 11 (trưa/tối 9) · 703 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
   chi phí món ăn 1.171.000 ₫ / ngân sách 1.200.000 ₫ ✓ · trả tại quầy ~1.255.000 ₫
   bữa trưa/tối có cơm: 14/14 (mâm 14 · trọn suất 0) · phương án xếp hạng 1
   cơm khả thi: ước lượng kcal/đạm 450 g (~3 chén) / mức chọn 450 g → đủ · bữa trưa/tối đủ cơm 14/14
   gạo sống cần mua (g/tuần) it → vừa → nhiều → rất nhiều: 2.536 → 2.455 → 3.137 → 3.575  ✗ KHÔNG TĂNG DẦN
   cơm quy đổi cả tuần (g) it → vừa → nhiều → rất nhiều: 1.050 → 2.100 → 4.200 → 6.300
   món trưa/tối khác nhau khi nới ngân sách 20% → 12
   cơm (rat_nhieu, mức 450 g): thực tế min 450 g · trung vị 450 g · 0% bữa mâm có ghi chú giảm cơm (14 bữa) · gạo sống cần mua 3.575 g/tuần
   khẩu vị thích: không chọn · 3 loại tráng miệng/tuần
   dụng cụ (% bữa): noi_com_dien 76% · noi_chien_khong_dau 67%

[ĐẠT ] p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu — Mới thêm: kiểm tra phủ món theo dụng cụ; kỳ vọng sẽ cập nhật theo kết quả đo.
   chỉ tiêu: 1615–1785 kcal, protein ≥ 105 g
   ngày đạt 7/7 (protein 7/7, kcal 7/7) · món khác nhau 13 (trưa/tối 10) · 4154 ms · 1 vòng · % bữa ghép mâm 100% · % có tráng miệng 100%
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
  Vi phạm ràng buộc cứng: 0 · thời gian TB 4767 ms, tối đa 16866 ms
```
