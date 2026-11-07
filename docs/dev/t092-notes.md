# T-092 — Trợ năng, hiệu năng, build Android

## 1. Trợ năng (chữ lớn 1.3×, vùng chạm, nhãn, tương phản)

Test: `mobile/test/a11y/accessibility_test.dart` — 26 test chạy trên khung điện thoại 360 × 780 dp với `textScaleFactor = 1.3`:
- 13 bước onboarding, 3 tab chính (kể cả cuộn tới cuối), màn bữa ghép mâm + "Cách chúng mình tính", bữa một món, sheet đổi món, sheet ăn ngoài, 4 văn bản (miễn trừ…), sửa lựa chọn, món đã chặn, hộp thoại xóa dữ liệu.
- Mỗi màn kiểm: **không tràn bố cục** (RenderFlex overflow = lỗi), `androidTapTargetGuideline` (≥ 48 dp), `labeledTapTargetGuideline` (mọi nút/vùng chạm có nhãn đọc), `textContrastGuideline`.

Đã sửa (test bắt được):
| Lỗi ở 1.3× | Sửa |
|---|---|
| Bước ngân sách: hàng "700.000 ₫ mỗi tuần" và "Tối thiểu / Tối đa" tràn phải | `Wrap` + `Flexible` (`budget_view.dart`) |
| Bước vuốt thẻ: 4 nút tròn tràn phải 184 px, thẻ cắt chữ 51 px | `Wrap` căn đều, nhãn ≤ 80 px; thẻ `minHeight 220` thay vì cao cố định (`step_swipe.dart`) |
| Chip chọn (chế độ ăn, món loại…) cao 44 dp < 48 | `kMinTouch` 44 → 48 (chip, ô nhập, nút) |
| Nút đổi nguyên liệu ⇄ 44 dp | 48 dp |

Nhãn semantics: mọi `IconButton` có `tooltip` (quay lại, chia sẻ, bước tăng/giảm, 4 nút vuốt, đổi nguyên liệu); chip/thẻ chọn có `selected`; nút "Bỏ chặn" đọc kèm tên món. Kiểm thủ công trên máy ảo với `font_scale 1.3` (ảnh `t092-03`, `t092-05`).

## 2. Hiệu năng — mở tab ≤ 300 ms

Đo trên máy ảo Android x86_64 bằng bản **profile** (AOT), `--dart-define=PERF_PROBE=true` (mã `lib/core/perf_probe.dart`, mặc định tắt): thời gian từ lúc bấm tab tới khi khung hình đầu vẽ xong.

| Lần mở | Đi chợ | Bạn | Kế hoạch |
|---|---|---|---|
| Lần đầu sau khi mở app | 82 ms | 37 ms | — |
| Các lần sau (tab được giữ trong IndexedStack) | 23 ms | 22 ms | 22 ms |

Đạt rất rộng (< 300 ms). Khởi động nguội (`am start -W`): ~2,0–2,1 s trên máy ảo (không nằm trong tiêu chí; máy thật nhanh hơn).

## 3. Build Android

Chạy tại `mobile/`. Cả hai ký bằng **khóa debug** (CN=Android Debug), chỉ để test nội bộ.

| Bản | Lệnh | File | Cỡ |
|---|---|---|---|
| Debug | `flutter build apk --debug` | `F:\WORKING\outside\mon-ngon\mobile\build\app\outputs\flutter-apk\app-debug.apk` | 191 MB |
| Release | `FITPRO_CLEARTEXT=1 flutter build apk --release` | `F:\WORKING\outside\mon-ngon\mobile\build\app\outputs\flutter-apk\app-release.apk` | 55 MB (3 ABI) |

- Debug đã có `usesCleartextTraffic` (gọi API dev `http://10.0.2.2:5095`). **Release mặc định chỉ HTTPS**; biến môi trường `FITPRO_CLEARTEXT=1` bật http để test nội bộ với API dev/LAN (`android/app/build.gradle.kts` + `android/app/src/release/AndroidManifest.xml`). Bản phát hành thật phải build **không** đặt biến này và dùng `--dart-define=API_BASE_URL=https://…`.
- Đổi địa chỉ API: `--dart-define=API_BASE_URL=http://<ip-lan>:5095`.
- Đã cài và chạy thử bản release trên máy ảo: tab Kế hoạch, Bạn, sửa ngân sách hoạt động với API thật.
- Máy ảo dev chỉ còn ~440 MB trống nên không cài được APK debug 191 MB; chụp ảnh bằng bản release/profile x86_64. Máy thật không gặp vấn đề này.

Ảnh: `docs/dev/screens/t092-01…t092-05` (release, chữ lớn).
