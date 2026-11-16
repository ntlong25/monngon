# Hướng làm UI hiện đại hơn và có chuyển động

Ngày: 2026-11-09 · Owner: RESEARCH · Trạng thái: đề xuất, chờ PM duyệt rồi giao Dev (mobile/ thuộc Dev)

## 1. Vấn đề người dùng nói

"Các component, button không bắt mắt, không trendy. Cần nhiều animation, UI hiện đại hơn."

## 2. Chẩn đoán từ code (đọc, không sửa)

Nguồn: `mobile/lib/ui/theme.dart`, `tokens.dart`, `app_button.dart`, `select_card.dart`, `bottom_cta.dart`, `dish_image.dart`, `mobile/pubspec.yaml`.

| Hạng mục | Hiện tại | Hệ quả |
|---|---|---|
| Màu | Nền kem `#FBF8F1`, thẻ trắng viền be 1 px, xanh lá `#1B6B4F`, vàng `#F2A93B` | Ấm và dễ chịu, nhưng phẳng; không có điểm nhấn lớn |
| Thẻ | `elevation: 0`, chỉ có viền | Giao diện giống form hơn là app |
| Nút | `FilledButton` / `OutlinedButton` mặc định của Material 3, bo pill, cao 48 | Đúng chuẩn nhưng không có cá tính; không có icon đi kèm mặc định, không có phản hồi nhấn |
| Chọn một (SelectCard) | Đổi viền và nền tức thời, không animation | Cảm giác "bấm xong không có gì xảy ra" |
| Chuyển màn | `AnimatedSwitcher` 200 ms, chỉ fade | Chuyển bước nhàn nhạt; không có định hướng tiến/lùi |
| Animation toàn app | Chỉ 3 chỗ: thanh tiến trình (`progress_segments.dart`), mờ chữ (`step_targets.dart`), chuyển bước | Gần như không có chuyển động vi mô |
| Haptic | Không có (không tìm thấy `HapticFeedback`) | Nút và thẻ không có xúc giác |
| Font | Mặc định của hệ thống (Roboto trên Android), không có font riêng | Không có chất riêng; chữ số calo/gram không nổi bật |
| Hình món | 7 minh họa tự vẽ bằng `CustomPainter` (`dish_image.dart`), màu nền phẳng | Nhất quán nhưng giống clip-art; trên màn công thức chỉ là một hình bát cơm nhỏ trong ô xám (xem `docs/research/screens/t50c-lk5-2chen-mam.png`) |
| Số liệu | Protein, calo, tinh bột hiển thị dạng chip nhỏ | Đây là giá trị chính của app nhưng không được đẩy lên làm điểm nhấn |
| Chế độ tối | Không có | Không phải lỗi, nhưng app 2026 thường có |

Kết luận: app đúng chuẩn Material, sạch, nhưng **phẳng và tĩnh**. Thiếu ba thứ: điểm nhấn màu/hình, phản hồi khi chạm (chuyển động + haptic), và số liệu được làm nổi bật.

## 3. Hướng đề xuất (không sao chép Mealbird)

Quy tắc: lấy nguyên tắc chung (chuyển động có mục đích, số liệu lớn, thẻ có chiều sâu). **Không** lấy màu xanh lá của Mealbird, logo, bố cục chip, câu chữ, ảnh (PRD: không dùng nhận diện, màu, câu chữ của Mealbird).

### 3.1 Hệ chuyển động (motion tokens)

- Thời lượng: **120 ms** (phản hồi nhấn), **200 ms** (đổi trạng thái chọn), **320 ms** (chuyển màn).
- Đường cong: vào dùng `Curves.easeOutCubic`, ra dùng `Curves.easeInCubic`. Nút xác nhận có thể dùng `Curves.easeOutBack` nhẹ (overshoot ≤ 5%).
- **Giảm chuyển động:** nếu `MediaQuery.disableAnimationsOf(context)` là true thì bỏ scale và trượt, chỉ giữ fade ≤ 100 ms. Đây là yêu cầu trợ năng, không phải tùy chọn.

### 3.2 Nút (AppButton)

- Chiều cao 56 dp (từ 48), bo pill giữ nguyên.
- Khi nhấn: scale 0.97 trong 120 ms, trả về trong 200 ms.
- Nút chính có bóng nhẹ (`elevation` 2–3 dp, màu bóng là xanh đậm 20% độ mờ).
- Icon đi kèm (Tiếp tục → mũi tên; Thêm → dấu cộng) để nút có "nhịp".
- `HapticFeedback.lightImpact()` khi nhấn nút chính; `selectionClick()` khi chọn chip/thẻ.
- Trạng thái đang tải: giữ kích thước nút, thay chữ bằng chấm chạy (không đổi chiều rộng, tránh giật).

### 3.3 Thẻ chọn một (SelectCard) và chip

- Đổi viền, nền, màu chữ bằng `AnimatedContainer` 200 ms, không đổi tức thời.
- Dấu ✓ phóng to từ 0.6 → 1.0 bằng `AnimatedScale` 250 ms (easeOutBack).
- Thẻ có độ nâng khi chạm (elevation 0 → 2 trong 120 ms).
- Giữ nguyên `Semantics` và `selected` để trình đọc màn hình đọc đúng (đã có).

### 3.4 Chuyển bước onboarding

- Thay `AnimatedSwitcher` fade bằng **trượt + mờ** 280 ms: tiến thì trượt từ phải sang trái, lùi thì ngược lại. Hướng trượt cho người dùng biết mình đang đi tới hay đi lùi.
- Thanh tiến trình: phần đã đi đầy dần trong 320 ms khi sang bước mới (đã có `AnimatedContainer`, chỉ cần chỉnh thời lượng và đường cong).

### 3.5 Thẻ vuốt (SwipeStep)

Bổ sung chuyển động, giữ nguyên nút thay thế (PRD trợ năng):

- Khi kéo: thẻ nghiêng theo hướng kéo (tối đa ±12°), lớp màu phủ tăng dần (xanh "Thích", vàng "Ít hơn") theo quãng đường kéo.
- Khi thả dưới ngưỡng 35% chiều ngang: thẻ trở lại bằng spring 300 ms.
- Khi vượt ngưỡng: thẻ bay ra và thẻ kế tiếp phóng lên từ 0.94 → 1.0 trong 250 ms.
- Nút ✕ / ♥ có hiệu ứng nổ nhẹ (scale 1.0 → 1.15 → 1.0 trong 220 ms) cùng haptic.

### 3.6 Màn kết quả (mâm, tuần, tổng kết)

- Danh sách hiện theo nhóm: mỗi mục trượt lên + mờ, lệch nhau 30 ms, tối đa 6 mục đầu (không làm chậm danh sách dài).
- Số calo, protein, ngân sách: đếm từ 0 lên giá trị trong 600 ms khi vào màn. Chỉ làm lần đầu mỗi lần mở màn.
- Chip macro (protein, kcal, tinh bột, béo) lớn hơn: số ~28 sp, nhãn ~12 sp. Protein dùng nền vàng nghệ (đã là màu của đạm trong app).

### 3.7 Typography

- Chọn một font có hỗ trợ đủ dấu tiếng Việt và giấy phép mở. Đề xuất để PM chọn từ hai ứng viên: **Be Vietnam Pro** (thiết kế cho tiếng Việt, OFL) hoặc **Inter** (OFL, dấu tiếng Việt đầy đủ). Cả hai đều có chữ số đẹp cho con số lớn.
- Cần quyết định cách nạp: gói `google_fonts` (thêm dependency, cần PM + Dev duyệt) hoặc đưa file .ttf vào `mobile/assets/fonts/` (không thêm dependency).
- Đặt bậc chữ: display 32/40, số lớn 28/34, tiêu đề 20/26, nội dung 16/24. Chữ 1.3× vẫn phải không cắt (đã có kiểm tra ở T-092).

### 3.8 Màu và chiều sâu

- Giữ xanh lá và vàng nghệ (nhận diện riêng của FitPro, đã ghi trong `app_colors`). Thêm một gradient nhẹ cho nền màn chào và thẻ tuần (xanh đậm → xanh lá, 135°), không dùng màu của Mealbird.
- Thêm một bậc bóng: `surface` (elevation 0), `raised` (elevation 2), `floating` (elevation 6, cho CTA cố định).
- Chế độ tối: P2, không bắt buộc cho đợt này.

### 3.9 Hình món

- Ngắn hạn (không đổi nguồn ảnh): đưa minh họa lên lớn hơn trên thẻ (120–160 dp), thêm nền gradient theo nhóm món thay vì màu phẳng.
- Trung hạn: vẽ bộ minh họa có chiều sâu (hai tông, đổ bóng nhẹ) cho 7 nhóm. Việc này thuộc RESEARCH/Design, không phải code.
- Dài hạn: ảnh món thật. Cần nguồn ảnh có giấy phép (setup-notes đã ghi: không dùng ảnh Mealbird).

## 4. Ràng buộc

- PRD §7: vùng chạm ≥ 44 pt, tương phản WCAG AA, mọi thao tác vuốt có nút thay thế, giảm chuyển động.
- Không thêm dependency vào `pubspec.yaml` nếu chưa được PM và Dev duyệt (font, Lottie, Rive, flutter_animate đều là dependency mới).
- Giữ nguyên `Key` và `Semantics` đang dùng trong test (`integration_test`, `onboarding_t086_test.dart`), để không gãy test.
- Không đổi chuỗi i18n chỉ vì đổi giao diện. Nếu thêm chữ mới thì qua `content/i18n/vi.json` và `gen_arb.py`.

## 5. Đề xuất chia đợt (cho Dev)

| Đợt | Nội dung | Rủi ro | Ước lượng |
|---|---|---|---|
| 1 | Motion tokens, nhấn nút, chọn thẻ, chuyển bước trượt, haptic | Thấp (không đổi dữ liệu, không đổi màn) | Nhỏ |
| 2 | Thẻ vuốt có nghiêng và lớp màu, màn kết quả đếm số, chip macro lớn | Trung bình | Vừa |
| 3 | Font riêng, bậc chữ mới, gradient, bóng | Trung bình (cần kiểm cỡ chữ 1.3) | Vừa |
| 4 | Bộ minh họa mới, ảnh món thật | Phụ thuộc Design/nguồn ảnh | Lớn |

Đợt 1 làm được trước mà không cần chờ quyết định về thứ tự thẻ vuốt (xem `docs/research/ux-review-swipe-first.md`).

## 6. Kiểm thử đề xuất (RESEARCH sẽ viết TC khi PM duyệt)

- Bật "Loại bỏ hiệu ứng" trên Android: mọi chuyển động phải về tức thời hoặc fade ngắn.
- Font 1.3×: nút, thẻ, chip không cắt chữ.
- Tương phản: chữ trên nền gradient ≥ 4.5:1; viền thẻ chọn ≥ 3:1.
- Haptic: chạm nút chính có rung nhẹ, không rung khi chỉ cuộn.
- Hiệu năng: không rớt khung trên thiết bị tầm trung khi chạy đếm số và trượt thẻ (Dev đo bằng DevTools, RESEARCH không có máy để đo).

## 7. Việc cần quyết định

1. Đợt 1 có duyệt không?
2. Font: Be Vietnam Pro hay Inter?
3. Có thêm dependency không (`google_fonts`), hay bundle file font?
4. Thứ tự với thẻ vuốt lên đầu (phương án A/B/C trong `ux-review-swipe-first.md`).

Không đổi `mobile/`, không đổi `pubspec.yaml`, không commit. Tài liệu này là đề xuất.
