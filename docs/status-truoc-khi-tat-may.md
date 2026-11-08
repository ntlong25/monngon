# Trạng thái trước khi tắt máy (2026-11-08)

## Đã xong
- **T-098** (đủ bữa có cơm cho mức 2 chén / 3+ chén): commit `37128a6`, nhánh `t-098-com-nhieu-chen`, đã push.
  PR https://github.com/ntlong25/monngon/pull/1 đã chuyển "ready for review", merge được.
- Test (main session tự chạy lại): Engine 221/221, Api 49/49 (`check-tests.py` mặc định), `flutter analyze` sạch, Flutter 239/239.
- AC 1–7 đạt. Ngoại lệ duy nhất (PM duyệt D-COM-05): p02, p09, p14 ở mức 3+ chén không đủ 12/14 bữa có cơm vì ngân sách sát; app cảnh báo (AC4 64/64).

## Chưa commit (trên đĩa, nhánh t-098-com-nhieu-chen)
- **T-099** (thẻ tinh bột theo tên món "Khoai lang hấp · ~115 g (thay ½ chén cơm)", cảnh báo số chén khả thi + ngân sách ở bước onboarding): Dev làm dở.
  Còn thiếu: chạy full flutter test, ảnh khoai lang, cập nhật luồng it-10 bốn mức.
  6 chuỗi i18n mới Research đã thêm vào `content/i18n/vi.json`.
  Nên làm trên nhánh mới tách từ master sau khi merge PR #1.

## Rủi ro
- Lập tuần mức 3+ chén tối đa ~16,9 s (TB ~4,8 s), dưới timeout 30 s nhưng biên ~2×. Có thể tối ưu ở task riêng.

## Chờ user
- Review + merge PR #1.
- Chốt gram/chén (đang giữ 150 g).

## Ghi chú môi trường
- API cho emulator: `dotnet run --project backend/MonNgon.Api --no-launch-profile --urls http://0.0.0.0:5097`.
- `gh` đã cài và đăng nhập (ntlong25).
