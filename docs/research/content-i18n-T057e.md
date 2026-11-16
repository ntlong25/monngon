# T-057e: chuỗi cho thẻ vuốt ở bước 2 (T-103)

Ngày: 2026-11-09 · Owner: RESEARCH · Căn cứ: PRD D-ONB-06, US-1.5 AC4, `docs/pm/backlog.md` T-103 và T-057e.

## 1. Sửa trong `content/i18n/vi.json`

| Khóa | Trước | Sau | Tên ARB sinh ra |
|---|---|---|---|
| `onboardingSwipeSoft` (dạng camelCase, không có khóa dotted `onboarding.swipe.soft`) | "Đây chỉ là ưu tiên mềm; bạn có thể đổi bất cứ lúc nào." | "Chỉ để biết bạn thích kiểu món nào. Không ảnh hưởng calo, đạm hay dị ứng; phần đó hỏi ở các bước sau." | `onboardingSwipeSoft` (không đổi tên) |

Khóa này dùng cả trên màn vuốt lẫn màn kết quả vuốt (`step_swipe.dart`). `mobile/tool/arb_extra.json` không có khóa này, nên không có bản ghi đè.

## 2. Khóa mới trong `content/i18n/vi.json`

| Khóa | Giá trị | Tên ARB sinh ra | Dùng ở |
|---|---|---|---|
| `onboarding.swipe.skip_all` | Bỏ qua | `onboardingSwipeSkipAll` | Nút "Bỏ qua" trên màn vuốt (D-ONB-06 ý 3) |
| `onboarding.summary.taste_none` | Khẩu vị: chưa chọn | `onboardingSummaryTasteNone` | Dòng tổng kết khi bỏ qua vuốt (US-1.5 AC4) |

Không trùng với khóa đang có: `onboarding.swipe.skip` ("Thay thế") giữ nguyên, nghĩa là thay một thẻ bằng thẻ khác, khác với "Bỏ qua" (bỏ cả bước).

## 3. Việc Dev làm (T-103)

1. Chạy `gen_arb.py` để sinh `app_vi.arb` (PYTHONIOENCODING=utf-8 trên Windows). Research không chạy script này vì `mobile/` thuộc Dev.
2. Dùng `onboardingSwipeSkipAll` cho nút "Bỏ qua" và `onboardingSummaryTasteNone` cho dòng tổng kết.
3. Khi bỏ qua, không gửi `cuisine_likes`/`cuisine_less`. Nút "Thay thế" và các nút vuốt vẫn như cũ.

## 4. Kiểm sau khi Dev xong

- TC-1-49 (Bỏ qua), TC-1-50 (thích thịt rồi chọn chay), TC-1-51 (làm dở, cập nhật, mở lại), và TC-1-27…30, TC-1-36, TC-1-37, TC-1-39.
- Ghi kết quả vào `docs/research/acceptance-T103.md` kèm ảnh.

## 5. Ghi chú khác

- `onboarding.progress.label` ("Bước {{count}} trên 10") chỉ dùng ở `gallery_page.dart` (màn debug), không dùng trong onboarding. Không cần sửa cho T-103.
- Khóa camelCase (`onboardingSwipe*`, `onboardingEquipment*`, …) nằm trực tiếp trong `vi.json`, khác quy ước "chỉ dạng dotted" ở `content-i18n-notes.md`. Không sửa trong đợt này; ghi nhận để T-074 xử lý.
