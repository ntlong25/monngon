# Rà UX/UI và đề xuất đưa thẻ vuốt lên đầu onboarding

Ngày: 2026-11-09 · Owner: RESEARCH · Trạng thái: đã chốt phương án A (D-ONB-06, PRD §10, 2026-11-09). Thứ tự và TC đã cập nhật theo T-057e; mục 5–8 là lịch sử quyết định

## 1. Câu hỏi

1. App hiện đã ổn về UX/UI chưa?
2. Có UX nào nên lấy từ Mealbird không, đặc biệt là thẻ vuốt trái/phải (kiểu Tinder) để hỏi khẩu vị ngay lúc mở app, thay vì bắt người dùng điền form?

## 2. Nguồn đã dùng

- Video Mealbird trong repo: `docs/video-frames/sheet_00.jpg` … `sheet_06.jpg` (khung hình 0–31 giây, đã xem từng tấm).
- Code app hiện tại: `mobile/lib/features/onboarding/onboarding_nav.dart` (thứ tự 14 bước), `onboarding_flow.dart`, `step_swipe.dart`.
- PRD `docs/pm/prd.md` (US-1.5, Epic 1, rủi ro "nhầm sản phẩm là bản sao Mealbird").
- Tìm web (chế độ standard): không thấy nguồn nào xác nhận Mealbird có thẻ vuốt ngay khi mở app. Các app có thẻ vuốt khác (SwipeBite, Herbi, Swoodie…) không liên quan trực tiếp. Kết luận dựa trên video trong repo.

## 3. Thứ tự onboarding của Mealbird (theo video)

| Giây | Màn | Nội dung |
|---|---|---|
| 0–3 | Nơi mua | Chọn chuỗi siêu thị (WinMart, Co.opmart, Aeon, …) hoặc "Nơi khác" |
| 4–5 | Ngân sách | Số lớn "600.000 / mỗi tuần" + thanh trượt |
| 6–7 | Ai sẽ ăn | Stepper "Người lớn", hỏi có trẻ em không |
| 8–10 | Bữa ăn | Chọn bữa sáng/trưa/tối/phụ, "Tôi không ăn bữa này", nóng/nguội |
| 11–13 | Chế độ ăn | Ăn chay, thuần chay, ít tinh bột… |
| 14–15 | Loại bỏ | Không gluten, không sữa, không hạt…; "Xu hướng nấu ăn" |
| 16–19 | Không ăn được | Chip nguyên liệu + ô tìm kiếm |
| **20–28** | **Thẻ vuốt** | "Bạn muốn một tuần như thế nào?" Ảnh món lớn, nhãn (Châu Á, Mexico, Cay, Nhanh và dễ, Hợp cả nhà). Nút ✕ / hoàn tác / ♥. Cuối có "Xu hướng của bạn" với "Vuốt lại" |
| 29–30 | Bếp | Lưới ảnh dụng cụ: bếp, lò, nồi chiên không dầu… |
| 31 | Đang thiết lập | Checklist: mục tiêu, protein tối thiểu, calo, bữa ăn, xu hướng, dụng cụ, ngân sách |

**Điểm quan trọng:** trong video, thẻ vuốt không phải màn đầu tiên. Trước nó có khoảng 6 màn hỏi (nơi mua, ngân sách, người ăn, bữa, chế độ, loại bỏ). Cảm giác "quẹt ngay khi mở app" có thể đến từ việc thẻ vuốt là màn có hình và dễ chơi nhất, nằm giữa một chuỗi form ngắn.

## 4. Onboarding hiện tại của FitPro - Mâm đủ

Thứ tự (`OnboardingStep`):

1. goal (mục tiêu) → 2. body (chỉ số cơ thể) → 3. activity (vận động) → 4. targets (chỉ tiêu) → 5. store → 6. household → 7. budget → 8. meals → 9. diet → 10. rice (thói quen ăn cơm, mới ở T-059) → 11. dislike → 12. **swipe** → 13. equipment → 14. summary.

- Thẻ vuốt đã có trong app (`step_swipe.dart`): vuốt phải = thích, trái = ít hơn; có ✕, ♥, hoàn tác, "thay thế", thẻ có ảnh minh họa theo nhóm món. Đúng với US-1.5.
- Thẻ vuốt đứng **sau 11 bước form**, ở vị trí 12/14. Mealbird đặt sau 6 màn.
- Bước đầu tiên là chỉ số cơ thể (cân nặng, chiều cao, tuổi, vận động). Đây là phần người dùng thấy nặng nhất khi mới mở app. Mealbird bắt đầu bằng việc chọn nơi mua và ngân sách.

## 5. Có nên đưa thẻ vuốt lên đầu không?

**Có, và không cần đổi dữ liệu.** Lý do:

- Kết quả vuốt chỉ là trọng số mềm (`cuisine_likes` / `cuisine_less`, PRD US-1.5 AC2). Không bước nào khác phụ thuộc kết quả vuốt, nên đặt nó sớm không làm sai số liệu.
- Bước `budget-range` và `targets` không cần vuốt. Đổi thứ tự chỉ là đổi `OnboardingNav` và các `next()/back()`.

Đề xuất (chờ PM chọn):

- **A (khuyến nghị):** đưa swipe lên vị trí 2, ngay sau màn "Mục tiêu" (hoặc ngay sau màn mở đầu). Người dùng thử thẻ vuốt trong 10–20 giây đầu. Phần chỉ số cơ thể và chỉ tiêu đẩy xuống sau.
- **B:** giữ thứ tự, thêm một màn mở đầu "Vuốt 5 món để bắt đầu" (5 thẻ) trước goal. Tốn thêm một màn, nhưng không đổi thứ tự bước.
- **C:** giữ nguyên, chỉ thêm chữ gợi ý ở màn goal "Bạn sẽ được hỏi khẩu vị ở bước 12". Ít rủi ro nhất, ít giá trị nhất.

Rủi ro cần ghi nhận:

- Người dùng chưa khai báo gì mà đã vuốt: thẻ chỉ là khẩu vị, không ảnh hưởng calo. Nội dung dưới thẻ phải nói rõ điều này (chuỗi `onboarding.swipe.soft` đã có).
- Test lại: TC-1-27…30 (vuốt, nút thay thế, hoàn tác, "Vuốt lại") và TC-1-39 (bước cơm sau kiêng/ghét/vuốt) phải cập nhật vị trí bước. Test chạy theo thứ tự, nên sẽ thay đổi.
- Bước cơm (T-059c) đặt sau "Kiểu ăn" và trước "Ghét"; nếu đưa swipe lên đầu thì không ảnh hưởng `rice` vì `rice` không đọc swipe.

## 6. UX nên lấy từ Mealbird (chỉ cơ chế, không lấy giao diện)

| Ý tưởng | Có lấy không | Ghi chú |
|---|---|---|
| Thẻ vuốt trái/phải + nút ✕ ♥ hoàn tác | Có, đã có trong app | Chỉ cần đưa lên sớm |
| Chọn nơi mua trước, ngân sách ngay sau | Đáng cân nhắc | Ngân sách là số lớn dễ hiểu; nhưng `budget-range` cần chỉ tiêu (T-086 AC). Cần PM quyết |
| Stepper "Ai sẽ ăn" có số người lớn/trẻ | Đã có (bước household) | Giữ |
| Màn "Đang thiết lập tuần của bạn" với checklist | Đã có ở T-086 | Giữ, có thể thêm dòng "Ngân sách" như video |
| Lưới ảnh dụng cụ bếp | Đã có (bước equipment) | Giữ |
| Màu xanh lá, logo, linh vật, bố cục chip, câu chữ | **Không lấy** | PRD: không dùng nhận diện, màu, câu chữ của Mealbird |
| Phụ đề chữ to giữa video | Không liên quan | Chỉ là cách quảng bá |

PRD đã có rủi ro "nhầm sản phẩm là bản sao Mealbird". Việc đưa thẻ vuốt lên đầu là cơ chế chung, không phải sao chép. Nhưng nếu copy bố cục thẻ, màu hoặc câu chữ thì vi phạm PRD.

## 7. Rà UX/UI hiện tại (tóm tắt)

Dựa trên tài liệu đã có, không chạy lại app hôm nay (Dev giữ emulator).

Đã ổn:
- Lỗi mạng ở tab Bạn (L-13) và lỗi bước tổng kết (L-12) đã sửa, đã kiểm trên máy (`docs/research/acceptance-T050b.md`, `acceptance-T050c.md`).
- Gạo hiển thị theo chén kèm gram trong ngoặc (T-059c, `docs/research/data-batch-T059c.md`).
- Thẻ vuốt có nút thay thế và hoàn tác, đủ tooltip (`t092-notes.md`).

Chưa xong / cần lưu ý:
- Cỡ chữ 1.3 mới chỉ kiểm bằng widget test, chưa kiểm trên máy (blocked, `acceptance-T050b.md` §12).
- Đường 2 chén cơm trên máy: automation có, kiểm tay chưa.
- TC-3-08: tỉ lệ "Cả nồi" của thịt heo xay (145→305) lệch với bí (200→520) trong ảnh của Dev. Cần Dev kiểm.
- Thẻ khoai mâm ghi "chén cơm": PM chưa quyết nhãn.
- Onboarding có 14 bước. Đây là điểm UX lớn nhất. Đề xuất ở mục 5 giảm cảm giác "form dài" mà không bỏ dữ liệu nào.

## 8. Việc cần PM quyết

1. Chọn phương án A, B hay C ở mục 5.
2. Thứ tự "nơi mua → ngân sách" có đổi không (mục 6), vì ngân sách phụ thuộc chỉ tiêu.
3. Nếu chọn A, RESEARCH cập nhật TC-1-27…30 và TC-1-39 và báo Dev đổi `OnboardingStep`.

Không đổi code, không đổi dữ liệu, không commit. File này là đề xuất.
