# L-09 — Tab "Bạn" không phản hồi trên emulator (T-093 mục 2)

**Kết luận: không phải lỗi mã app. Là treo cả tiến trình app trên emulator thiếu RAM; mở lại app là hết. Không sửa code.**

## Đã kiểm trên bản release APK
Máy: emulator-5554 (1080×2400, điều hướng cử chỉ, RAM trống ~170 MB, swap nặng). Gói `vn.fitpro.fitpro_mamdu`,
`mobile/build/app/outputs/flutter-apk/app-release.apk`. Ảnh chứng cứ: `docs/dev/screens/t093-00 … t093-07`.

| Bước | Kết quả |
|---|---|
| Hiện trạng (instance chạy lâu) | Cả UI đứng: chạm tab nào, cuộn đều không phản hồi, không ANR, tiến trình rảnh (`t093-00…04`) |
| `am force-stop` + mở lại | Chạm tab Bạn vào ngay, danh sách "Chỉ tiêu và lựa chọn" hiển thị (`t093-05`) |
| Chu kỳ chạm Kế hoạch → Đi chợ → Bạn nhanh nhiều vòng | Phản hồi bình thường (`t093-06`) |
| Để yên 100 s rồi chạm Bạn | Phản hồi bình thường (`t093-07`) |

→ Không lặp lại được trên bản mới khởi động; lỗi chỉ xuất hiện ở instance chạy lâu, khi toàn bộ UI (không riêng tab Bạn) đứng.
Không có ngoại lệ Dart, không ANR trong logcat.

## Cách tái hiện / khắc phục cho người kiểm thử
- Triệu chứng: mọi chạm đều không ăn (không riêng tab Bạn). Nếu tab Kế hoạch cũng không cuộn được thì là treo tiến trình, không phải lỗi tab Bạn.
- Khắc phục: `adb shell am force-stop vn.fitpro.fitpro_mamdu` rồi mở lại app.
- Phòng ngừa: cấp thêm RAM cho AVD (≥ 3 GB), cold boot AVD, đóng app khác; hoặc kiểm trên máy thật.
- Nếu còn gặp trên máy thật hoặc AVD đủ RAM → báo lại kèm `adb logcat -d` để điều tra tiếp.

## Test tự động
`mobile/test/app_test.dart`: "Có 3 tab … và chuyển tab được", "Tab Bạn gọi /health và báo đã kết nối", "Mất mạng → báo chưa kết nối…" — đều chạm tab Bạn và qua.
