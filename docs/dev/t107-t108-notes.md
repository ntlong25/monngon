# T-107 + T-108: Mục tiêu thành bộ thẻ quẹt chọn 1, Dụng cụ thành lưới thẻ có hình

Ngày: 2026-11-16 · Dev (mobile/). Nguồn: PRD D-ONB-08, D-ONB-09, D-SHP-07; backlog T-107, T-108.

## Hình minh họa (dùng chung cho T-107, T-108)

- Nguồn: 10 SVG tự vẽ của Research ở `docs/research/illustrations/` (`goal-*.svg`, `dungcu-*.svg`). Không thêm `flutter_svg`.
- Script `tools/svg_to_png.py` (chỉ dùng thư viện chuẩn của Python): vẽ từng SVG bằng Edge/Chrome có sẵn ở chế độ headless, nền trong suốt, ra PNG 1x/2x/3x theo bố cục ảnh nhiều độ phân giải của Flutter: `mobile/assets/illustrations/<tên>.png`, `2.0x/`, `3.0x/`. Cạnh 1x: hình mục tiêu 240 px (hiện tới 200 dp trên thẻ), hình dụng cụ 128 px (hiện 72 dp). Chạy lại khi SVG đổi: `python tools/svg_to_png.py`.
- `pubspec.yaml`: chỉ thêm khai báo tài nguyên `assets/illustrations/` (không thêm dependency).
- Widget `Illustration` (`mobile/lib/ui/illustration.dart`): đọc PNG, lỗi/thiếu file thì vẽ biểu tượng dự phòng (`illustration-fallback-<tên>`), không bao giờ lỗi; hình trang trí nên không đọc cho TalkBack (tên đã có ở chữ).

## T-107 — Mục tiêu

- `SwipeDeck` (T-106) thành widget dùng chung: `SwipeDeck<T>` (kiểu thẻ tuỳ ý, `idOf`), biểu tượng nhãn cấu hình được, `keepOnLike` (chế độ chọn 1: quẹt phải báo chọn rồi thẻ bật về giữa, không bay ra), `onGrab` (nơi gọi hủy việc chờ khi người dùng chạm vào thẻ). Bước Khẩu vị chạy như cũ (chế độ chọn nhiều/loại).
- `GoalStep` (`step_goal.dart`): 3 thẻ Giảm mỡ / Giữ cân / Tăng cơ (hình, tên, mô tả), xoay vòng bằng danh sách thứ tự trong state của widget.
  - Quẹt phải / "Chọn mục tiêu này" (`goal-choose`): ghi `profile.goal`, đánh dấu đã chọn, dấu "Đã chọn" trên thẻ; sau 400 ms tự sang bước Khẩu vị (không tự sang khi bật giảm chuyển động). Chạm thẻ để kéo, hoặc bấm "Xem mục tiêu khác" trong 400 ms thì hủy việc tự sang.
  - Quẹt trái / "Xem mục tiêu khác" (`goal-other`): thẻ bay ra rồi xuống cuối bộ; không bao giờ hết thẻ.
  - Hàng 3 chấm (`goal-dot-<id>`, vùng chạm 48 × 48 dp): chạm chấm đưa thẻ đó lên trên; `Semantics` "Mục tiêu 2 trên 3: Giữ cân".
  - Tiêu đề giữ "Bạn muốn đạt mục tiêu nào?"; dòng hướng dẫn mới `onboarding.goal.swipe_hint` (Research) khác bước Khẩu vị.
- **Cờ đã chọn:** `Profile.goal` luôn có giá trị mặc định ('lose') nên không dùng để biết đã chọn hay chưa. Thêm `OnboardingState.goalChosen` (lưu `goal_chosen`; dữ liệu cũ không có cờ → coi là đã chọn nếu đã qua bước Mục tiêu hoặc đã xong onboarding). Chưa chọn thì "Tiếp tục" khóa.
- Mở lại bước: thẻ đã chọn nằm trên cùng. Sửa mục tiêu từ tab Bạn dùng đúng màn này (Lưu thay cho Tiếp tục; không tự sang bước kế).

## T-108 — Dụng cụ bếp

- `EquipmentStep`: lưới thẻ 2 cột (3 cột khi chiều rộng màn hình ≥ 600 dp; tính theo màn hình, không theo bề rộng đã trừ lề), mỗi thẻ hình 72 dp + tên. Các hàng cao bằng nhau (`IntrinsicHeight`).
- Thẻ đã chọn: viền dày 2,5 dp + nền nhạt + dấu ✓ (`equip-check`), không chỉ đổi màu. Cả thẻ là vùng chạm (≥ 48 dp). `Semantics` kiểu ô chọn (`checked`).
- Giữ `Key('equip-<id>')`, cảnh báo "cần ít nhất 1 thiết bị nấu" (`equipment-need-one`) và khóa Tiếp tục khi chỉ còn máy xay (US-1.5 AC3). Dữ liệu vẫn là `preferences.equipment` nên request gửi đúng như trước.

## Kết quả

- `flutter analyze` sạch; `flutter test` 320 đạt (trước T-107: 284; thêm `goal_deck_test` 22, `equipment_grid_test` 13…, sửa test cũ của Mục tiêu theo bộ thẻ). Không đổi backend (check-tests 242/49 như cũ, không chạy lại).
- Integration `main_flow_test` xanh trên emulator riêng Pixel_7 (cổng 5556, API riêng 5096). Đo (số của kịch bản, không tính ảnh): tới màn vuốt khẩu vị ≈ 5,0 s, cả onboarding tới Tổng kết ≈ 40 s.
- Ảnh: `docs/dev/screens/it-02-onb-01-muc-tieu.png`, `-keo-phai.png`, `-keo-trai.png`, `-da-chon.png`, `it-02-onb-12-dung-cu.png` (lưới 2 cột, đã chọn có ✓ + viền).
- Lưu ý: 2 icon Lucide (nét viền) và 5 icon tô màu trông khác phong cách nhau; thẻ mục tiêu dùng nền kem của `surfaceVariant` nên vẫn hài hòa, nhưng nếu Design muốn đồng bộ thì cần vẽ lại.
