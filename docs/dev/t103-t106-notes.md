# T-103 + T-106: thẻ vuốt lên bước 2 và cử chỉ quẹt kiểu Tinder

Ngày: 2026-11-16 · Dev (mobile/). Nguồn: PRD D-ONB-06, D-ONB-07, US-1.5 AC4/AC5, US-1.6 AC4; `docs/research/swipe-tinder-ux.md`.

## T-103 — Thẻ vuốt là bước 2

- Thứ tự (14 bước): Mục tiêu → **Khẩu vị (thẻ vuốt)** → Cơ thể → Vận động → Chỉ tiêu → Cửa hàng → Hộ gia đình → Ngân sách → Bữa ăn → Chế độ ăn → Thói quen ăn cơm → Không muốn thấy → Dụng cụ → Tổng kết. Đổi ở `OnboardingStep` (`onboarding_nav.dart`) và `buildOnboardingStep`; tab Bạn vẫn mở đúng từng màn theo tên bước.
- **Lưu bước theo tên:** `OnboardingState.toJson` ghi thêm `step_name`; khi đọc, tên thắng số. Trạng thái cũ chỉ có `step` (số theo thứ tự cũ) được đổi sang tên rồi sang số của thứ tự mới (`_legacyStepNames` trong `app_state.dart`); số ngoài khoảng → Tổng kết / đầu, không nhảy sai. Không đổi `kStorageSchemaVersion` vì dữ liệu cũ vẫn đọc được.
- **Bỏ qua:** nút "Bỏ qua" (`onboardingSwipeSkipAll`) trên màn vuốt khi còn thẻ: xóa `cuisine_likes`/`cuisine_less` và danh sách thẻ đã vuốt rồi sang bước kế. Hết thẻ thì không còn nút (giữ kết quả, "Vuốt lại" vẫn có). Tổng kết có dòng khẩu vị (`summary-taste`): "Khẩu vị: chưa chọn" nếu không có, hoặc tên các thẻ đã thích; nút Sửa về bước khẩu vị.
- Dòng "không ảnh hưởng calo, đạm hay dị ứng" (`onboardingSwipeSoft`) đã có trên màn vuốt.
- **L-16 (D-DATA-01):** thẻ cửa hàng ở onboarding và tab Đi chợ ghi "Giá ước lượng, chưa khảo sát tại cửa hàng này" khi `price_survey_date` là `null` (WinMart, Co.opmart); cửa hàng đã khảo sát ghi ngày như cũ. Không ẩn cửa hàng.
- Ràng buộc cứng thắng khẩu vị (TC-1-50): engine bỏ phần "thích" không còn hợp lệ (đã đúng từ D-COM-01), không đổi code; kiểm bằng test tuần chay ở backend (xem Kiểm bên dưới).

## T-106 — Màn vuốt thẻ: căn giữa + quẹt thẻ

- Nguyên nhân lệch trái: `Card` trong `Dismissible` không có ràng buộc chiều rộng, cột onboarding căn nội dung về trái → thẻ chỉ rộng bằng nội dung. Đã bỏ `Dismissible`, viết `SwipeDeck` (`swipe_deck.dart`) bằng `RawGestureDetector` + `AnimationController` + `Transform`; **không thêm package** (`pubspec.yaml` không đổi).
- Thẻ rộng = rộng khung − 2×16 dp, tối đa 400 dp, căn giữa; bo góc 20 dp, bóng; ảnh minh họa ở trên, tên/nhãn ở dưới; cao `max(300, 0,9 × rộng) × cỡ chữ` để hàng nút vẫn nằm trong màn hình đầu tiên.
- Xếp chồng: tối đa 2 thẻ sau, scale 0,95 / 0,90, lệch xuống 8 / 16 dp (neo ở đáy để lộ dải dưới thẻ trước); "tiến lên" theo độ kéo.
- Kéo cả hai trục, xoay `dx / (0,5 × rộng) × 12°` kẹp ±12°. Nhãn "Thích" (kéo phải) / "Ít hơn" (kéo trái) hiện dần, đầy đủ ở ngưỡng, có chữ và biểu tượng. Bộ nhận cử chỉ tự viết (`_DeckPan`) nhận kéo từ 18 dp (như cuộn dọc) để thắng `ListView` bao quanh.
- Ngưỡng: kéo ngang ≥ 35% chiều rộng thẻ hoặc vận tốc ngang ≥ 700 dp/s → bay ra 280 ms rồi ghi trọng số; dưới ngưỡng → bật về 300 ms.
- Nút ✕ ♥ hoàn tác thay thế giữ `Key` (`swipe-undo`, `swipe-dislike`, `swipe-replace`, `swipe-like`), ≥ 48 dp. ✕/♥ chạy cùng hoạt ảnh bay; Hoàn tác cho thẻ quay lại từ phía đã bay ra (250 ms) và trả trọng số.
- Trợ năng: `Semantics` cho thẻ (nội dung + hành động "Thích", "Ít hơn" qua `customSemanticsActions`); giảm chuyển động (`disableAnimations`): không xoay, không scale, không bay, đổi thẻ ngay.

## Kết quả (2026-11-16)

| Kiểm | Kết quả |
|---|---|
| `python backend/check-tests.py` | Engine 242/242 (thêm 2: `CuisineVsDietTests`), Api 49/49; `test-baseline.json` Engine 242 |
| `npx vitest run` | 179 đạt |
| `flutter analyze` | không có vấn đề |
| `flutter test` | 284 đạt (gồm `onboarding_t103_test`, `swipe_deck_test` 22 test, test L-16 ở tab Đi chợ) |
| Integration `main_flow_test` (emulator Pixel_7, API thật) | xanh |

### AC T-103

1. Thứ tự 14 bước, Back giữ lựa chọn: `onboarding_t103_test` (đi tiến từ Mục tiêu qua từng bước rồi lùi về) ✓.
2. Bỏ qua → không có khẩu vị; tổng kết "Khẩu vị: chưa chọn": test widget ✓ (request `POST /v1/plans` gửi `cuisine_likes`/`cuisine_less` rỗng = không có khẩu vị).
3. Thích thẻ thịt rồi chọn Chay: `CuisineVsDietTests` (vegetarian, vegan; 0 nguyên liệu bị cấm, 0 nguyên liệu quầy thịt) ✓.
4. Tiếp tục dở dang: lưu `step_name`; test chuyển trạng thái cũ (14 số cũ → đúng tên bước), TC-1-51 (bản cũ dừng ở Ngân sách mở lại đúng Ngân sách, giữ lựa chọn), tắt app giữa chừng ở bước vuốt mở lại đúng thẻ tiếp theo ✓.
5. Từ mở app tới màn vuốt = 2 thao tác (chọn mục tiêu, Tiếp tục). Số đo trên emulator (debug build, đã trừ thời gian chụp ảnh nhưng còn các khoảng chờ cố định của kịch bản): tới màn vuốt **≈ 5,2 s**; cả onboarding tới tổng kết **≈ 40,9 s** (gồm chờ API, nhập tay bằng kịch bản). Không có số "trước" cùng phương pháp để so (kịch bản cũ không đo); mục tiêu G1 ≤ 5 phút còn dư lớn. Đây là số kịch bản, không phải thời gian người dùng thật.
6. Tab Bạn mở đúng từng màn (`profile_page_test` xanh), `flutter test` và integration xanh ✓.
- L-16: 2 trạng thái (cửa hàng có ngày / `price_survey_date` rỗng) ở thẻ cửa hàng và tab Đi chợ, test widget ✓.

### AC T-106

1. Căn giữa ở 360 / 412 / 600 dp: `|lề trái − lề phải| ≤ 1`, rộng `min(rộng − 32, 400)` ✓.
2. Bo góc 20 dp, bóng, chữ 1.3× không tràn (a11y test bước 2 ở 1.3×) ✓.
3. Xếp chồng 2 thẻ sau (scale 0,95/0,90, dịch 8/16 dp), tiến lên khi kéo ✓.
4. Kéo hai trục, xoay tối đa ±12° ✓. 5. Nhãn "Thích"/"Ít hơn" hiện dần, đầy ở ngưỡng, có chữ ✓.
6. 30% → bật về 300 ms, không ghi; 40% → bay ra rồi ghi đúng hướng (phải/trái); ném nhanh 20% với 800 dp/s → đúng hướng; 20% chậm → bật về ✓.
7. 4 Key và nút ≥ 48 dp; ♥/✕ chạy hoạt ảnh bay; Hoàn tác cho thẻ quay lại từ đúng phía (250 ms) và trả trọng số ✓.
8. `Semantics` (nội dung + hành động Thích/Ít hơn, thực thi được qua trình đọc màn hình); giảm chuyển động: không xoay/scale/bay, đổi thẻ ngay ✓.
9. Hết thẻ → màn kết quả + "Vuốt lại"; "Bỏ qua" và dòng "không ảnh hưởng calo…" giữ nguyên ✓.
10. `pubspec.yaml` không đổi ✓. Thời gian viết: trong ngày công, không phải dừng báo PM.
11. Ảnh (emulator): `it-02-onb-11-vuot-the-dau.png` (thẻ đầu, căn giữa, xếp chồng), `it-02-onb-11-keo-phai.png` (nhãn Thích), `it-02-onb-11-keo-trai.png` (nhãn Ít hơn), `it-02-onb-11-vuot-the-ket-qua.png` (hết thẻ); ảnh cũ để so: `it-02-onb-11-vuot-the-dau-truoc-t106.png`. Vòng tròn/chữ thập xanh trong ảnh kéo là lớp "Pointer location" của emulator, không phải của app.

### Việc ngoài AC đã làm kèm

- `meal_pages_test` ("Không hợp với tôi"): test phụ thuộc ngày thật (khi tuần mẫu đã qua thì hộp thoại hiện thêm câu trùng); đã cố định `clockProvider` về 10/11/2026 như các test khác. Không đổi hành vi app.
- Integration: dòng "Ngân sách" của tổng kết nằm cuối danh sách (sau dòng khẩu vị mới) nên ListView chưa dựng; kịch bản cuộn tới trước khi đọc.
