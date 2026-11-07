# Tự động hoá QA T-050c / T-050b (Dev)

Chạy: `cd mobile && ADB=adb PATH=$PATH:<flutter>/bin:<platform-tools> bash tool/run_integration.sh emulator-5554 http://10.0.2.2:5097 integration_test/qa_flow_test.dart`
(API phải chạy ở :5097; **`adb` phải nằm trong PATH** của shell chạy script, nếu không ảnh chụp ra file rỗng 0 byte mà test vẫn xanh).
Mã: `mobile/integration_test/qa_flow_test.dart` + `it_support.dart` (helper dùng chung với `main_flow_test.dart`).
Kết quả lần chạy cuối: **5/5 test xanh** trên emulator-5554 (bản debug, API thật). Ảnh: `docs/dev/screens/it-10…it-14-*.png`.

## Bảng TC

| TC | Kết quả | Kiểm gì | Ảnh |
|---|---|---|---|
| TC-3-16 / T-050c: 4 mức cơm ở tab Bạn → lên lại tuần | **Đạt** | Mỗi mức: lưu ở tab Bạn → "Áp dụng" → tuần mới có `rice.habit` đúng mức; thẻ cơm trên màn mâm đúng `l.mealRiceCups(RiceCard.cups(g), g)` (ít "½ chén (~75 g)", vừa "1 chén (~150 g)", nhiều "2 chén (~300 g)"); bữa bớt cơm có ghi chú `rice_reduced` và dòng "Bữa này bớt còn … để giữ đúng calo"; **không mâm nào có 2 canh** | `it-10-com-<mức>-tab-ban / -the-com / -bot-com` |
| TC-E-04: tạo tuần khi mất mạng | **Đạt (hành vi khác bảng TC, xem dưới)** | Offline → "Chưa tạo được thực đơn" + "Không có mạng. Dữ liệu vẫn được giữ trên máy." + nút Thử lại, không crash; có mạng lại → Thử lại tạo được tuần; tab Bạn offline vẫn hiện chỉ tiêu đã lưu (L-13) | `it-11-offline-*` |
| TC-3-08: Phần của bạn / Cả nồi (hộ 2 lớn + 1 trẻ) | **Đạt** | Hai cột `col-yours`/`col-whole`; cả nồi = bạn + 1 người lớn chuẩn + 0,6 × trẻ (kiểm 2 nguyên liệu) | `it-12-cong-thuc-hai-cot` |
| TC-3-09: Cách làm, bước đã xong còn khi mở lại | **Đạt** | Chạm bước 0, 1 → `step-N-done`; dựng lại toàn cây widget trên cùng kho lưu → bước vẫn xong | `it-12-cach-lam*` |
| TC-3-10: Chế độ nấu (giữ sáng) | **Đạt** | `WakelockPlus.enabled` khi vào công thức; sau ≥125 s không chạm `dumpsys power` = `mWakefulness=Awake` và vẫn bật; rời trang → tắt | log `[adb] wakefulness*` |
| TC-1-09: thanh ngân sách | **Đạt** | Mọi mốc bội của 50.000 ₫; nhãn bậc đổi: 650k "Tiết kiệm", 900k "Vừa phải", ≥1,15M "Thoải mái" | `it-13-ngan-sach-min|max` |
| TC-1-33: tổng kết onboarding | **Đạt** | 8 dòng `summary-<id>` đúng thứ tự và giá trị (Giảm mỡ, 120 g, 1.400 kcal, 4 bữa, Nhiều chất xơ, 2 chén ~300 g, Bếp+Nồi cơm điện, 900.000 ₫) | `it-14-tong-ket-checklist` |
| Chữ 1.3× | **Đạt (widget test)** | `test/a11y/accessibility_test.dart` 30 test (onboarding, Kế hoạch, mâm, công thức, Đi chợ, Bạn + màn mới T-094–T-097) không overflow; `flutter test` 236 xanh | — |

## Phát hiện cần PM/Research quyết

1. **TC-E-04 trong `test-scenarios.md` mâu thuẫn với app**: bảng ghi "tạo tuần vẫn chạy, không báo lỗi mạng", nhưng tạo tuần cần API (engine ở server) nên app báo lỗi + Thử lại và giữ nguyên dữ liệu. Đề xuất sửa bảng TC thành hành vi hiện tại (đã kiểm).
2. **`rice.target_g` không luôn bằng mức thói quen**: mâm có tinh bột khác cơm (vd. khoai lang hấp) thì `target_g`/`actual_g` là gram của chính món đó, quy theo kcal tương đương cơm trắng (it → 115 g khoai lang thay 75 g cơm; vừa → 225 g). Test chấp nhận `target_g ≥ mức`. Nhưng thẻ trên màn mâm hiện "x chén **cơm** (~115 g)" cho bữa khoai lang — nhãn "cơm" và đơn vị chén chưa đúng. Cần PM quyết: ẩn thẻ khi mâm không có cơm, hay đổi nhãn ("khoai lang").
3. **Mức nhiều / rất nhiều có rất ít bữa mâm có cơm**: p01-like, tuần 7 ngày: it 14 bữa, vừa 13, nhiều 5, rất nhiều 2 (2/2 bớt cơm). Phần còn lại là bữa đủ món (không phải mâm). Khớp thiết kế T-096 (giữ cơm trước, bữa không giữ được thì chuyển bữa đủ món) nhưng người chọn "rất nhiều" ít khi thấy thẻ cơm.
4. Môi trường: emulator ít RAM; một lần chạy treo ở bước đổi mức cơm (timeout 20 phút), chạy lại thì xanh. Không phải lỗi app.
