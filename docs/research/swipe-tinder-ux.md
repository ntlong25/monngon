# Màn vuốt chọn thẻ (T-103, bước 2 onboarding): nguyên nhân lệch trái và hướng sửa kiểu Tinder

Ngày: 2026-11-16 · Owner: RESEARCH · Đối tượng: Dev (mobile/) qua hub → PM · Chỉ là tài liệu khảo sát, không sửa code.

## 1. Nguyên nhân thẻ bị lệch trái

Căn cứ đọc code và ảnh màn hình đã có:

- `mobile/lib/features/onboarding/step_swipe.dart`: `Dismissible` bọc `_SwipeCard`, và `_SwipeCard` là `Card` có `ConstrainedBox(minHeight: 220)`. `Card` không có ràng buộc chiều rộng nên **chỉ rộng bằng nội dung** (ảnh minh họa 96 dp và chữ).
- `mobile/lib/features/onboarding/onboarding_scaffold.dart`: nội dung nằm trong `ListView` → `Column` mặc định `crossAxisAlignment.start`. Thẻ được xếp về **mép trái**, khoảng trống bên phải không được dùng.
- Ảnh bằng chứng: `docs/dev/screens/it-02-onb-11-vuot-the-dau.png` (màn "Thẻ 1/14"): thẻ chiếm khoảng 60% chiều rộng, nằm sát trái, bên phải trống, trong khi hàng nút bên dưới trải đều cả màn. Ảnh `it-02-onb-11-vuot-the-ket-qua.png` cho thấy cùng vấn đề ở màn kết quả. Ảnh bạn gửi lần này không hiển thị nội dung trong lượt này nên tôi dùng ảnh đã có trong `docs/dev/screens`.

**Sửa tối thiểu (một dòng logic):** đặt thẻ trong `SizedBox(width: double.infinity)` (hoặc `Center` + `ConstrainedBox(maxWidth: 360)` để không quá to trên máy màn rộng). Đây là lỗi bố cục, không phải lỗi cử chỉ.

## 2. Bố cục đề xuất (theo kiểu Tinder, không sao chép giao diện)

| Thành phần | Thông số đề xuất | Ghi chú |
|---|---|---|
| Chiều rộng thẻ | 100% trừ 2 × 16 dp lề (tối đa 360 dp) | Thẻ luôn ở giữa |
| Tỉ lệ thẻ | cao ≈ 1,35–1,45 × rộng, tối thiểu 380 dp | Có chỗ cho ảnh/minh họa lớn hơn hiện tại (96 dp) |
| Góc bo | 20 dp | Đồng bộ `AppRadius` (16 dp) hoặc thêm token `xl` |
| Bóng đổ | `elevation` 4–6, màu bóng xanh đậm 15–20% | Hiện `Card` có viền, elevation 0; cần đổi `cardTheme` cho thẻ này |
| Thẻ phía sau | Thẻ kế tiếp: scale 0,95, dịch xuống 12 dp; thẻ thứ ba: scale 0,90, dịch 24 dp | Hiển thị tối đa 2–3 thẻ, dùng `Stack` |
| Lề giữa các thành phần | Thẻ → hàng nút: 24 dp; hàng nút → dòng ghi chú: 16 dp | |

Cấu trúc gợi ý: `Stack` với thẻ nền trước (`scale`/`translate`), thẻ đang vuốt ở trên cùng. Thẻ trên cùng là `Dismissible` hoặc widget tự viết (xem mục 6).

## 3. Cử chỉ khi kéo

- **Đi theo ngón tay cả hai trục:** `Offset` của thẻ = vị trí ngón tay − điểm bắt đầu.
- **Xoay nhẹ:** góc xoay = `dx / chiều_rộng_màn × 12°`, kẹp trong khoảng ±12° (không vượt 15°).
- **Nhãn hiện dần:** hai nhãn góc trên, "Thích" (xanh lá, góc trái trên khi kéo phải) và "Ít hơn" (vàng, góc phải trên khi kéo trái). Độ mờ = `min(1, |dx| / (0,4 × chiều_rộng))`. Không dùng màu làm dấu hiệu duy nhất: nhãn chữ luôn có.
- **Thẻ phía sau** tiến dần lên (scale từ 0,95 đến 1,0) theo tiến độ kéo của thẻ trên cùng, để người dùng thấy thẻ kế tiếp "được đẩy lên".

## 4. Ngưỡng và vật lý

- **Ngưỡng vuốt:** quyết định khi `|dx| ≥ 35% chiều rộng thẻ` **hoặc** vận tốc ngang `|v| ≥ 700 dp/s`. Vận tốc giúp vuốt nhanh một đoạn ngắn vẫn được tính.
- **Bay khỏi màn hình:** khi vượt ngưỡng, thẻ đi tiếp theo hướng vuốt tới ngoài màn hình, `Curves.easeOutCubic`, 250–300 ms. Đổi thẻ đúng lúc thẻ bay được nửa đường để tránh khựng.
- **Bật về giữa:** khi thả dưới ngưỡng, thẻ trở lại `(0,0)` và góc về 0 bằng spring (hoặc `Curves.easeOutBack` nhẹ, ≤ 5% vượt), 300 ms.
- **Nút bấm:** khi bấm ✕ / ♥, thẻ bay theo hướng tương ứng với cùng thời lượng, không cần kéo.
- **Giảm chuyển động:** nếu `MediaQuery.disableAnimationsOf(context)` là true, bỏ xoay và scale, thẻ đổi ngay (không bay).

## 5. Nút bấm dưới thẻ, trạng thái, hoàn tác

- **Vị trí và thứ tự** (giữ như hiện tại, đã đúng ý): Hoàn tác | Không thích | Thay thế | Thích. Nút tròn 56 dp (vùng chạm ≥ 48 dp, PRD §7 yêu cầu ≥ 44 pt), nhãn chữ dưới nút.
- **Nút Hoàn tác** mờ khi chưa có lịch sử (hiện đã làm).
- **Thẻ tiếp theo:** hiện ngay phía sau với scale 0,95, không chờ thẻ trước bay xong (dùng 2 thẻ trong `Stack`).
- **Hết thẻ:** chuyển sang màn kết quả hiện có (Bạn thích / Ít hơn / Vuốt lại) — giữ nguyên.
- **Hoàn tác:** thẻ vừa bỏ quay lại từ phía bên hướng đã vuốt, 250 ms, và trả lại trọng số cũ (logic hiện có `_undo`).

## 6. Cách làm trên Flutter: tự viết hay dùng package

| Lựa chọn | Ưu | Nhược | Ghi chú |
|---|---|---|---|
| Tự viết (`GestureDetector` / `Listener` + `AnimationController` + `Transform`) | Không thêm dependency; kiểm soát nhãn, trợ năng, hoàn tác; khớp `_decide/_undo/_replace` hiện có | Dev phải tự viết ~150–200 dòng và test | **Khuyến nghị**, vì PRD cấm thêm dependency chưa được PM và Dev duyệt |
| `flutter_card_swiper` 3.1.0 | MIT (theo trang license của pub.dev, bản quyền 2023); không có dependency; có undo và vuốt bằng nút | Các bản cũ (2.0.x, 1.1.0) được ghi "unknown" license trên pub.dev, cần ghim 3.1.0; API thay đổi giữa các bản | Phù hợp nếu PM duyệt dependency |
| `appinio_swiper` 2.1.1 | MIT, bản quyền APPINIO GmbH (2021); phỏng theo Tinder | Nguồn ghi ngày mới nhất không thống nhất (Flutter Gems: Apr 2024; ecosyste.ms: "gần đây"), cần kiểm lại trước khi ghim; bản 1.0.x và 2.0.0 ghi "unknown" | Phù hợp nếu PM duyệt, nhưng cần kiểm tra lại ngày phát hành |

Kết luận: nên tự viết trước, vì màn này chỉ có một loại thẻ và đã có logic riêng. Nếu PM duyệt dependency, `flutter_card_swiper` ghim 3.1.0 là lựa chọn gọn hơn. Không dùng bản cũ có license "unknown". Đây là khuyến nghị về phương án, quyết định vẫn thuộc PM và Dev.

## 7. Trợ năng

- Mọi thao tác vuốt có nút thay thế (đã có: ✕, ♥, Hoàn tác, Thay thế). Đây là yêu cầu PRD US-1.5 AC1 và NFR trợ năng.
- Thẻ có `Semantics` (tên món + "Thích" / "Ít hơn" làm hành động), và nhãn kéo không chỉ dựa vào màu.
- Cỡ nút ≥ 48 dp; khoảng cách giữa các nút ≥ 8 dp.
- Kiểm trên cỡ chữ 1,3× (đã có kiểm trong T-092): thẻ cao thêm, không cắt chữ.
- Với bàn phím hoặc trình đọc màn hình: nút là đường đi chính; vuốt chỉ là cách thêm.

## 8. Bảng đối chiếu: hành vi Tinder → thẻ món ăn

| Tinder | Áp vào thẻ món ăn của FitPro | Kết quả trong dữ liệu |
|---|---|---|
| Vuốt phải = thích | Vuốt phải = **Thích** | `cuisine_likes` += tag của thẻ (đã có) |
| Vuốt trái = bỏ qua | Vuốt trái = **Ít hơn** (không phải "xóa") | `cuisine_less` += tag (đã có); nhãn "Không thích" trên nút ✕ |
| Thẻ "để sau" | **Thay thế**: đưa thẻ xuống cuối hàng đợi | Không ghi trọng số (đã có `_replace`) |
| Nút quay lại / hoàn tác | **Hoàn tác** | Bỏ trọng số vừa ghi, quay về thẻ trước (đã có `_undo`) |
| Hết thẻ | Màn kết quả "Khẩu vị của bạn" | Trọng số mềm, có "Vuốt lại" (đã có) |
| Vuốt lên (superlike) | **Không dùng** | Không có ý nghĩa rõ cho khẩu vị; tránh thêm lựa chọn |
| Bỏ qua cả bước | **Bỏ qua** (T-103) | Không gửi khẩu vị; tổng kết "Khẩu vị: chưa chọn" |

Lưu ý: thẻ ảnh-minh họa, nhãn và câu chữ là của FitPro (PRD: không sao chép giao diện hay câu chữ của sản phẩm khác). Tài liệu này chỉ tóm tắt cơ chế chung.

## 9. Việc cần Dev làm (tóm tắt)

1. Sửa lỗi lệch trái: bọc thẻ trong ràng buộc chiều rộng (mục 1). Đây là việc nhỏ, làm trước.
2. Thêm lớp thẻ phía sau và `Stack` (mục 2).
3. Thêm kéo đa trục, xoay, nhãn hiện dần (mục 3).
4. Đặt ngưỡng và animation (mục 4).
5. Kiểm trợ năng và giảm chuyển động (mục 7).
6. Test: thêm widget test cho ngưỡng vuốt (vuốt dưới ngưỡng → bật về; vượt ngưỡng → gọi `_decide`), và giữ các `Key` hiện có (`swipe-like`, `swipe-dislike`, `swipe-undo`, `swipe-replace`).
