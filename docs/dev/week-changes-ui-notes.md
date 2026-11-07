# T-090 — UI thay đổi tuần (Flutter)

Dựa trên API T-067 (`docs/dev/week-changes-notes.md`). Mã: `mobile/lib/state/week_changes.dart`, `mobile/lib/features/meal/change_sheets.dart`, chỉnh `meal_page.dart`, `recipe_page.dart`, `recipe_widgets.dart`, `plan/plan_page.dart`. Test: `mobile/test/plan/week_changes_test.dart` (15 test mới; toàn bộ 166/166 pass, `flutter analyze` sạch).

## Luồng

| Việc | Ở đâu | Hành vi |
|---|---|---|
| **Đổi món này** (US-5.1) | trang bữa, nút `change-meal` | Sheet gợi ý 2–3 món: chênh lệch protein/kcal/giá, "Ngày vẫn đạt / Ngày sẽ không đạt". Nếu `any_keeps_day=false` có cảnh báo `swap-none-keep`. Chọn → `apply-swap`, thanh thông báo + Hoàn tác. |
| **Đổi nguyên liệu** (US-5.2) | thẻ nguyên liệu, nút ⇄ cạnh dòng có `swap_group` | Sheet `ingredient-options` (đã lọc ±5% protein) → `swap-ingredient`. |
| **Ăn ngoài / bỏ bữa** (US-5.3) | trang bữa, nút `eat-out` | Sheet 2 lựa chọn. Kế hoạch hiện dòng mờ "Ăn ngoài"/"Bỏ bữa" + nút Hoàn tác (`mode=undo`), chip "Có bữa ngoài" ở ngày. Đi chợ tự rút (server), nhưng món **đã mua** vẫn được giữ lại (`keepBoughtItems`). |
| **Không hợp với tôi** (US-5.4) | trang bữa | Hộp thoại: "Chặn và lên lại" (→ `regenerate-rest` kèm món bị chặn) hoặc "Chỉ chặn, không lên lại" (cục bộ, có Hoàn tác). |
| **Lên lại phần còn lại** (US-5.5) | cuối tab Kế hoạch, `replan-rest` | Hỏi xác nhận → `regenerate-rest(today)`; tuần cũ vào "Tuần đã lưu"; banner "Đã lên lại tuần" kèm kết quả validator (đóng được). Nút ẩn khi không còn ngày sau hôm nay. |

Sau mỗi thay đổi tuần mới (đã validator + đi chợ tính lại) thay `currentPlan`; mọi thao tác lưu ảnh chụp trước đó để **Hoàn tác** (snackbar). "Hôm nay" lấy từ `clockProvider` (test cố định được).

## Chi tiết đáng lưu ý

- Hoàn tác là phía máy khách (giữ bản tuần trước); không lưu xuống máy — thoát app thì mất khả năng hoàn tác (riêng ăn ngoài vẫn có nút Hoàn tác trên dòng).
- Lỗi mạng: thông báo thân thiện (`errorsNetworkBody`), tuần giữ nguyên; trong sheet có nút Thử lại.
- Đã sửa trong lúc test: nút Thử lại của sheet gọi `setState` với hàm trả Future (assert) — nay bọc đúng.
- Chuỗi mới ở `mobile/tool/arb_extra.json` (≈40 khóa `change*`, `plan*`) → sinh lại `app_vi.arb`; không có chuỗi cứng trong widget (test NFR-03 pass).
- Chưa có UI cho `relaxed_preferences` (server có trả).

## Ảnh chụp (emulator, API thật) — `docs/dev/screens/`

- `t090-01-bua-trua.png` trang bữa có nút "Đổi món này" / "Ăn ngoài / bỏ bữa"
- `t090-02-doi-mon.png` sheet gợi ý (3 món, chênh lệch, "Ngày vẫn đạt")
- `t090-03-da-doi-hoan-tac.png` sau khi chọn: trang cập nhật + "Đã đổi món / Hoàn tác"
- `t090-04-an-ngoai-sheet.png` sheet Ăn ngoài / Bỏ bữa
- `t090-05-an-ngoai-ke-hoach.png` dòng "Ăn ngoài" + Hoàn tác + chip "Có bữa ngoài", tổng ngày đã đổi
- `t090-06-nut-len-lai.png`, `t090-07-xac-nhan-len-lai.png` nút và hộp thoại lên lại
- `t090-08-da-len-lai.png` banner "Đã lên lại tuần"

Cảnh báo "không món nào giữ ngày đạt" kiểm bằng test (khó tái hiện trên dữ liệu thật). Máy ảo thiếu dung lượng cho bản debug 200 MB nên chụp bằng bản profile x64 (manifest profile được tạm thêm cleartext rồi hoàn lại).
