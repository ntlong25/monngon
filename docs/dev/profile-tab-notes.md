# T-091 — Tab Bạn (Flutter)

Mã: `mobile/lib/features/profile/profile_page.dart`, `profile_subpages.dart`; chế độ sửa: `features/onboarding/onboarding_edit.dart` (+ `OnboardingScaffold`); route trong `router.dart`; `choicesDirtyProvider`, `blockedNamesProvider` (state). Test: `mobile/test/profile/profile_page_test.dart` (18). Toàn bộ 184/184 pass, `flutter analyze` sạch.

## US-6.1 Sửa chỉ tiêu và lựa chọn
- Danh sách 12 dòng tóm tắt (mục tiêu, cơ thể, vận động, chỉ tiêu mỗi ngày, cửa hàng, người ăn, ngân sách, số bữa, xu hướng, đã loại, khẩu vị, căn bếp). Bấm một dòng → mở **đúng màn onboarding của bước đó ở chế độ sửa** (`OnboardingEditScope`: không thanh tiến độ, nút Quay lại đóng màn, nút chính "Lưu"; `OnboardingNav` không đổi bước khi onboarding đã hoàn tất).
- Thay đổi áp dụng cho tuần tạo kế tiếp: tuần hiện tại **không đổi** cho tới khi bấm "Lên lại tuần này với lựa chọn mới" (`regenerate-rest` với hồ sơ/lựa chọn mới; tuần cũ vào Tuần đã lưu). Khi có thay đổi chưa áp dụng hiện banner `profile-dirty`.
- Tuần đã kết thúc → nút "Tạo tuần mới với lựa chọn hiện tại" (`POST /v1/plans`, bắt đầu từ ngày mai).

## US-6.2 Món đã chặn
Màn riêng: tên món (nhớ tên lúc chặn qua `blockedNamesProvider`, fallback tên công thức), nút "Bỏ chặn" từng món + thông báo; bỏ chặn đánh dấu "chưa áp dụng".

## US-6.3 Miễn trừ y tế, nguồn dữ liệu, xóa dữ liệu
- 4 văn bản: miễn trừ y tế, nguồn dữ liệu (USDA CC0 + proxy), giá ước tính, quyền riêng tư (từ `docs/research/legal-notes.md`, thương hiệu đã đổi thành "FitPro - Mâm đủ"). Nằm trong `arb_extra.json` (khóa `profile*Body`) — T-074 nên chuyển sang `content/`.
- Xóa toàn bộ dữ liệu: **xác nhận 2 bước** (hai hộp thoại, Hủy ở bước nào cũng giữ nguyên); xong → `clearAll` → router về onboarding; không còn tuần, tuần đã lưu, lựa chọn.
- Thêm: danh sách "Tuần đã lưu" (khoảng ngày + ngày lưu), mục "Kết nối máy chủ" giữ lại cho QA.

## Lưu ý cho PM/Research
- Đoạn riêng tư trong legal-notes nói "không gửi dữ liệu đi đâu" — **không đúng với app hiện tại** (hồ sơ/lựa chọn được gửi tới API để tính, API không lưu). Bản trong app đã viết lại cho đúng; Research nên cập nhật legal-notes.
- Khẩu vị (vuốt thẻ) sửa lại qua đúng bước vuốt của onboarding.
