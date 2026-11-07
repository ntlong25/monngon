# Kiểm thử lại lượng cơm (T-050c)

Trạng thái: **một phần** (chờ T-096 của Dev để kiểm đủ 4 mức cơm và hồ sơ calo thấp). Ngày: 07/11/2026.

## Đã kiểm (xem chi tiết trong acceptance-T050b.md, mục 13)

| TC | Kết quả |
|---|---|
| TC-1-46 (nhãn chén trên bước Thói quen ăn cơm) | Đạt |
| TC-3-16 (dòng "1 chén cơm (~150 g)" trên mâm trưa) | Đạt một phần; ghi chú giảm cơm chưa kiểm |

## Chưa kiểm

- Bốn mức cơm (½ / 1 / 2 / 3 chén) qua API và UI (TC-2-15, TC-1-43).
- Hồ sơ calo thấp chọn "3 chén trở lên": ghi chú giảm cơm và sàn cơm (TC-2-16, TC-3-16).
- Hồ sơ "Ít tinh bột": không có cơm (TC-2-18, TC-1-42).

## Lượt 1 (API, 07/11/2026; build T-096, API 5097, data_version 13d35976…b124)

Script: `scratchpad/t50d/rice_check.mjs` (gọi `/v1/plans`, `start_date` 2026-11-09, seed 1).

| TC | Kết quả | Số liệu |
|---|---|---|
| TC-2-15 (p01, 4 mức) | **Đạt** | `it` 75 g, `vua` 150 g (khoai ở mâm: 225 g tương đương kcal), `nhieu` 300 g, `rat_nhieu` 450 g khi đủ kcal. Mỗi bữa có `rice.target_g` và `rice.actual_g` |
| TC-2-16 (p01 `rat_nhieu`/`nhieu`) | **Đạt** | Bữa bị giảm có `notes: [{code: "rice_reduced", target_g, actual_g, reason: "kcal"}]`. Ví dụ `nhieu` 300 → 175 g, `rat_nhieu` 450 → 225 g |
| TC-2-18 (p05, low_carb) | **Đạt** | 14/14 bữa trưa và tối không có khối `rice` và không có món cơm |
| Mâm 2 canh | **Đạt** | 0 bữa trưa/tối có hơn 1 món role `soup` (p01 cả 4 mức, p02, p05, p11, p14) |
| TC-2-16 hồ sơ kcal thấp (p02, 1.350 kcal) `rat_nhieu` | Đạt một phần | 4 bữa bị giảm (dinner 450 → 225 g). Không có bữa nào xuống 100 g |

**Chênh lệch với yêu cầu hub:** hub nêu thẻ "⅔ chén cơm (~100 g)" cho hồ sơ 3 chén kcal thấp. API không trả mức nào dưới 225 g cho `rat_nhieu`. Sàn theo PRD là max(50% target, 60 g) = 225 g, nên 100 g sẽ vi phạm sàn. Cần Dev/PM xác nhận: đây là kỳ vọng sai hay sàn cần đổi.

**Chưa kiểm:** đổi mức ở tab Bạn (cần tuần đã lưu), ảnh màn mâm và thẻ cơm trên UI, hồ sơ `low_carb` trên UI.

## Lượt 2 (UI, emulator-5554, APK profile T-096, 07/11/2026)

Tạo tuần mới bằng hồ sơ mặc định (giảm mỡ, nam 30 tuổi, 170 cm, 65 kg, 1.950 kcal) và chọn "3 chén trở lên (~450 g)" ở bước Thói quen ăn cơm. Tóm tắt hiện "Thói quen ăn cơm: 3 chén trở lên (~450 g)".

| TC | Kết quả | Ghi chú |
|---|---|---|
| TC-1-46 (nhãn chén) | **Đạt** | Đúng bốn nhãn; mặc định 1 chén; ghi chú hiện đúng (lượt 13) |
| TC-3-16 (thẻ cơm + ghi chú giảm cơm) | **Đạt** | Mâm trưa 11/08 có thẻ "1½ chén cơm (~225 g)" và dòng "Bữa này bớt còn 1½ chén cơm để giữ đúng calo." Ảnh `scratchpad/t50d/26-mam-lunch.png` |
| Mâm không có 2 canh | **Đạt** | Mâm trưa 11/08 có 1 canh (món chính), 1 rau, cơm, tráng miệng |

**Chênh lệch với yêu cầu hub:** thẻ hiện "1½ chén (~225 g)", không phải "⅔ chén (~100 g)". 225 g là sàn 50% của 450 g theo PRD, nên 100 g không xuất hiện trong dữ liệu hiện tại. Cần Dev/PM xác nhận sàn.

**Chưa kiểm trong lượt này:**
- Đổi mức ở tab Bạn (TC-1-43), gồm xác nhận và tuần lên lại.
- Bốn mức trên UI (đã kiểm qua API ở lượt 1).
- Hồ sơ low_carb trên UI (đã kiểm qua API: không có cơm).
- TC-3-08 (hộ gia đình), TC-3-09 (đánh dấu bước), TC-3-10 (chế độ nấu).
- "Tạo thực đơn tuần" khi offline.
- Cỡ chữ 1.3 trên các màn còn lại (onboarding, đi chợ, tab Bạn).

## Lượt 3 (emulator, APK T-097, dữ liệu giữ nguyên, 07/11/2026)

| TC | Kết quả | Ghi chú |
|---|---|---|
| L-13 (tab Bạn offline, "Chỉ tiêu mỗi ngày") | **Đạt** | Khi tắt Wi-Fi và dữ liệu, dòng hiện "145 g protein · 1.950 kcal" từ chỉ tiêu đã lưu, không còn "…" (ảnh `scratchpad/t50d/31-offline-ban.png`) |
| Tab Bạn online, "Thói quen ăn cơm" | Đạt | Hiện "3 chén trở lên (~450 g)" (ảnh `30-ban-online.png`) |
| TC-E-04: tạo tuần khi offline | **Chưa kiểm** | Cần qua onboarding hoặc nút lên lại tuần |
| TC-1-09, TC-1-33 | **Chưa kiểm** | Không có thời gian trong lượt này |
| L-12 (câu giải thích và nút "Dùng …") | **Chưa kiểm** | Cần hồ sơ có mức tối thiểu khác nhau |
| 4 mức cơm trên UI, TC-3-08..3-10, cỡ chữ 1.3 các màn còn lại | **Chưa kiểm** | Xem các lượt trước |

## Lượt 4 (emulator, APK T-097; ảnh lưu trong docs/research/screens/)

Dừng giữa chừng: chưa xong các mục yêu cầu. Ghi lại để tiếp tục sau.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| L-12: tạo hồ sơ có hai mức tối thiểu khác nhau | **Chưa tái hiện** | Đường mặc định (1 người lớn, không kiêng, Bếp + Nồi cơm, 1 chén): tổng kết hiện 650.000 ₫, không có cảnh báo (`t50c-L12-defaults-summary.png`). Đường có "Thuần chay", chỉ Bếp, 2 người lớn + 1 trẻ: tối thiểu ở bước ngân sách là 1.650.000 ₫, tổng kết cũng 1.650.000 ₫, không có cảnh báo (`t50c-L12-tongket.png`, `t50c-L12-budget-sua.png`). Lỗi nhìn thấy trước T-097 chưa tái hiện được |
| Hộ gia đình 2 người lớn + 1 trẻ (TC-3-08, bước chọn người ăn) | Một phần | Bước người ăn nhận đúng 2 + 1; tổng kết và ngân sách tự cập nhật lên 1.650.000 ₫. Chưa kiểm cột "Phần của bạn" và "Cả nồi" trên công thức |
| TC-E-04 tạo tuần khi offline | Chưa kiểm | Chưa có bước tạo tuần khi tắt mạng |
| TC-1-09, TC-1-33 | Chưa kiểm | |
| 4 mức cơm trên UI, TC-3-09, TC-3-10, cỡ chữ 1.3 các màn còn lại | Chưa kiểm | Mục 4 đã kiểm qua API, UI chỉ kiểm một mức (xem lượt 2) |

Lưu ý: bước "Kiêng" đã chọn "Thuần chay" trong một đường thử; trạng thái sau đó đã reset bằng `pm clear` (dữ liệu app trên máy test đã xóa, cần tạo tuần mới để tiếp tục các mục tuần đã lưu).

## Lượt 5 (emulator, APK T-097; ảnh trong docs/research/screens/)

| Mục | Kết quả | Ghi chú |
|---|---|---|
| TC-E-04: tạo tuần khi offline | **Đạt theo thiết kế của app, lệch kỳ vọng TC-E-04 cũ** | Tắt mạng, bấm "Tạo thực đơn tuần": hiện "Chưa tạo được thực đơn. Có lỗi xảy ra. Không có mạng. Dữ liệu vẫn được giữ trên máy." có "Thử lại". Bật mạng, bấm "Thử lại" thì tạo tuần được (`t50c-E04-offline-tao-tuan.png`, `t50c-after-retry2.png`). TC-E-04 cũ ghi "tạo tuần vẫn chạy": cần PM chốt kỳ vọng |
| TC-1-33: checklist tổng kết | Đạt | Các dòng: mục tiêu Giảm mỡ, protein 145 g, calo 1.950 kcal, 4 bữa, xu hướng Không có, đã loại Không có, căn bếp Bếp + Nồi cơm điện, ngân sách 650.000 ₫ (`t50c-L12-defaults-summary.png`) |
| TC-1-09: kéo thanh ngân sách | Một phần | Một lần kéo nhỏ đưa 650.000 ₫ lên 700.000 ₫, đúng bước 50.000 ₫ (`t50c-TC109-slider1.png`). Chưa kiểm nhãn bậc khi qua các ngưỡng khác. Không bấm Lưu nên không đổi ngân sách |
| TC-3-08: "Phần của bạn" / "Cả nồi" | Chưa kiểm được | Cần đổi hộ gia đình rồi xem công thức; quá 10 phút, chuyển sang mục sau |
| TC-3-09: đánh dấu bước đã xong | Chưa kiểm được | Không vào được mục "Cách làm" trong lượt này |
| TC-3-10: giữ màn hình khi nấu | Chưa kiểm được | Chưa mở "Chế độ nấu" |
| Đổi 4 mức cơm ở tab Bạn (mỗi mức 1 màn mâm) | Chưa kiểm | Thao tác điều hướng lỗi nhiều lần, chưa vào đúng màn |
| Cỡ chữ 1.3 các màn còn lại | Chưa kiểm | |

L-12: đã có widget test tự động của Dev (theo chỉ đạo của hub), không tái hiện bằng tay.

## Lượt 6 (emulator, APK T-097; đổi mức cơm ở tab Bạn)

| Mức | Kết quả | Ghi chú |
|---|---|---|
| ½ chén (~75 g) | **Đạt** | Lưu ở tab Bạn, "Lên lại tuần này", mâm trưa hiện "½ chén cơm (~75 g)"; dòng cơm trắng 98 kcal (≈ 75 g × 1,3). Ảnh `t50c-lk5-half-mam.png` |
| 2 chén (~300 g) | **Chưa kiểm được** | Chuỗi tap tự động lệch: không chọn được mức 2 chén, sau đó mở công thức "Cơm trắng nấu nồi cơm điện" (150 g). Đã tạo lại tuần với mức 1 chén, không có mâm 2 chén. Ảnh `t50c-lk5-2chen-select.png`, `t50c-lk5-2chen-mam.png` (sai màn) |
| 1 chén, 3 chén | Chưa kiểm | Chưa thực hiện |
| Mâm 2 canh | Chưa kiểm lại trên UI | Mâm trưa ½ chén có một món canh (Canh đậu phụ bắp cải cà rốt) và một rau |

Lưu ý: không dùng chuỗi tap dài không kiểm tra màn hình; từ nay chụp màn hình sau mỗi bước chọn.

## Lượt 7: kết quả cuối (đối chiếu ảnh và bảng của Dev, 07/11/2026)

Nguồn: `docs/dev/qa-automation.md` (5/5 test xanh) và ảnh `docs/dev/screens/it-10…it-14-*.png`. Đối chiếu với `test-scenarios.md`. Không dùng emulator trong lượt này.

| TC | Kết quả | Căn cứ |
|---|---|---|
| TC-1-46 (nhãn chén) | Đạt | Lượt 2, 3 (thủ công); tự động hoá lần này không nêu riêng |
| TC-3-16 / T-050c: 4 mức cơm | **Đạt** (bảng Dev), **ảnh đã mở: 2** | `it-10-com-*-tab-ban`, `-the-com`, `-bot-com`. Ảnh `it-10-com-rat_nhieu-bot-com.png` có thẻ "1½ chén cơm (~225 g)" và "Bữa này bớt còn 1½ chén cơm để giữ đúng calo." Dev ghi không có mâm 2 canh |
| TC-E-04: tạo tuần khi mất mạng | **Đạt theo app, lệch TC cũ** | `it-11-offline-*`. Ảnh `it-11-offline-thong-bao-loi.png`: "Chưa tạo được thực đơn… Không có mạng. Dữ liệu vẫn được giữ trên máy." + Thử lại. TC-E-04 trong test-scenarios.md ghi "tạo tuần vẫn chạy": cần sửa bảng (Dev đề xuất, PM quyết) |
| TC-3-08: Phần của bạn / Cả nồi | **Đạt một phần, cần Dev kiểm lại** | `it-12-cong-thuc-hai-cot.png`: bí xanh 200 g → 520 g (2,6×, khớp 1 + 1 người lớn + 0,6 trẻ). Nhưng thịt heo xay 145 g → 305 g (2,1×), không khớp cùng công thức. Cần kiểm lại nguyên liệu thịt (có thể do dòng "thêm vào bữa" 15 g) |
| TC-3-09: bước đã xong còn sau khi mở lại | Đạt (theo bảng Dev) | `it-12-cach-lam*`; chưa mở ảnh lượt này |
| TC-3-10: giữ màn hình khi nấu | Đạt (theo bảng Dev) | Log `dumpsys power`, không có ảnh |
| TC-1-09: thanh ngân sách | Đạt (theo bảng Dev) | `it-13-ngan-sach-min/max`, chưa mở ảnh lượt này. Lượt 5 tôi đã kiểm một bước 650k→700k |
| TC-1-33: tổng kết | **Đạt** | `it-14-tong-ket-checklist.png`: Giảm mỡ, 120 g, 1.400 kcal, 4 bữa, Nhiều chất xơ, 2 chén (~300 g), Bếp + Nồi cơm điện, 900.000 ₫. Khớp lựa chọn |
| Cỡ chữ 1.3 | **Chưa phủ bằng ảnh** | Dev chỉ có widget test (`accessibility_test.dart`, 30 test không overflow). Chưa có ảnh 1.3 trên máy thật |
| L-12: câu giải thích và nút "Dùng …" | Phủ bằng test tự động | Theo chỉ đạo hub; không kiểm tay |
| Offline, tab Bạn (L-13) | Đạt | `it-11-offline-tab-ban-chi-tieu-da-luu.png` (đã kiểm tay lượt 13) |

### Điểm cần Dev/PM quyết (từ bảng QA của Dev, tôi đồng ý)
1. TC-E-04 trong test-scenarios.md cần sửa theo hành vi hiện tại.
2. Thẻ "x chén cơm" hiện trên bữa khoai lang (rice.target_g là gram của khoai, không phải cơm). Nhãn "cơm" chưa đúng; cần PM quyết (ẩn thẻ hay đổi nhãn).
3. Mức "rất nhiều" hiếm bữa có cơm (2/14 bữa trong tuần mẫu, 2 bữa đều bớt cơm). Đúng thiết kế T-096 nhưng ảnh hưởng trải nghiệm.
4. Kiểm lại tỉ lệ "Cả nồi" của dòng thịt heo xay (xem TC-3-08 ở trên).

### Chưa phủ
- Cỡ chữ 1.3 trên máy thật (chỉ có widget test).
- Ảnh của TC-3-09, TC-3-10, TC-1-09 (lượt này chỉ có bảng, không mở ảnh).
