# Trạng thái trước khi tắt máy (2026-11-07)

Chưa commit gì. Mọi thay đổi nằm trên ổ đĩa.

## Đã xong và đã kiểm lại
- T-094 / T-096: lượng cơm theo thói quen (½ / 1 / 2 / 3+ chén). p01 mức 1 chén: 0% bữa bị bớt cơm, trung vị 150 g. Không còn mâm 2 canh.
- T-095: bước "Thói quen ăn cơm" ở onboarding, thẻ cơm trên màn mâm, đổi mức ở tab Bạn.
- T-097: L-12 (cảnh báo ngân sách có lý do + nút "Dùng …"), L-13 (tab Bạn offline dùng chỉ tiêu đã lưu).
- Test: Engine 206, Api 47 (chạy với `-c Dev`), Flutter 239 đều đạt.
- Test tích hợp tự động trên emulator: luồng chính 9 bước + 5 test QA mới đều đạt
  (4 mức cơm, offline, TC-3-08/09/10, TC-1-09, TC-1-33). Ảnh: `docs/dev/screens/it-*.png`. Bảng TC: `docs/dev/qa-automation.md`.

## Câu hỏi chờ PM quyết (chưa gửi PM)
1. TC-E-04 trong `docs/research/test-scenarios.md` ghi "tạo tuần khi offline không báo lỗi", nhưng app cần API nên thực tế báo lỗi + Thử lại. Nên sửa TC.
2. Mâm dùng tinh bột khác cơm (khoai lang…) vẫn hiện "x chén cơm (~115 g)". Ẩn thẻ hay đổi nhãn?
3. Mức 2 chén / 3+ chén: chỉ còn 5 / 2 bữa mâm có cơm trong tuần, phần còn lại là bữa đủ món. Có chấp nhận không?
4. p01 chỉ có 9 món trưa/tối khác nhau (ngân sách sát 647k/650k).

## Việc tiếp theo
- Dev: T-093 (L-08, L-05).
- Research: đối chiếu ảnh it-10…it-14 với TC, cập nhật `acceptance-T050c.md`.
- Chốt gram/chén: đang giữ 150 g, chờ user (giữ hay tự cân).
- Commit: chờ user đồng ý.

## Ghi chú môi trường
- Các tiến trình dotnet cũ (PID 8612, 33308, 14724) sẽ mất khi tắt máy, sau đó `python backend/check-tests.py` chạy lại bình thường.
- Mở lại: API `dotnet run --project backend/MonNgon.Api --no-launch-profile --urls http://0.0.0.0:5097`; emulator đã cài APK profile trỏ 10.0.2.2:5097.
- `mobile/tool/run_integration.sh` cần `adb` trong PATH (thiếu thì ảnh rỗng mà test vẫn xanh).
