# Ghi chú T-055: chuyển nội dung vào `content/`

Cập nhật: 07/11/2026 (lần 2) · Owner: RESEARCH · Căn cứ: `docs/pm/backlog.md` T-055, `docs/pm/prd.md` D-ONB-04, §11, §12, US-4.1.
Chỉ sửa `content/`, `docs/research/` và `data/` (xem `prices-small-packs-notes.md`, `health-tags.md`).

## 1. Đã làm

| File | Nội dung |
|---|---|
| `content/i18n/vi.json` | 464 khóa: mọi khóa trong `docs/research/content-draft/i18n-vi.json` + mọi khóa trong `mobile/tool/arb_extra.json` + khóa mới (mục 3) |
| `content/swipe-cards.json` | 14 thẻ vuốt, copy từ nháp. Mọi `sample_recipe_ids` còn tồn tại; mọi tag có ≥ 4 công thức (ít nhất 7 ở `ngot`, `thanh_dam`) |
| `docs/research/health-tags.md` | Tiêu chí 4 thẻ sức khỏe (T-059) |
| `docs/research/prices-small-packs-notes.md` | Quy cách gói và giá (yêu cầu từ session chính) |

Nháp `docs/research/content-draft/` đã đồng bộ với `content/` (shopping labels, câu chờ). `content/` là nguồn chính thức.

## 2. Giữ nguyên tên khóa (yêu cầu session chính 07/11/2026)

- **Không xóa khóa nào.** Mọi khóa nháp (kể cả `app.name`, `onboarding.generating.wait`, `onboarding.budget.level.save|medium|comfort`) đều còn.
- **Khóa trùng tên ARB.** `app.name` và `onboarding.generating.wait` cùng tạo ra tên ARB `appName` và `onboardingGeneratingWait` đã có trong `arb_extra.json`. Nếu để cả hai dạng trong `vi.json`, `gen_arb.py` báo "trùng khóa ARB" và dừng. Nên `vi.json` chỉ giữ dạng dotted; tên ARB sinh ra vẫn là `appName` và `onboardingGeneratingWait`.
- **Kiểm chứng:** tập tên ARB sinh từ `vi.json` (464) trùng khớp đúng với `mobile/lib/l10n/app_vi.arb` hiện tại (464 khóa). Không mất khóa nào mà app đang dùng.
- **Khóa deprecated:**
  - `onboarding.budget.level.save`, `onboarding.budget.level.medium`, `onboarding.budget.level.comfort`: deprecated, thay bằng `budget.tier.economy|moderate|comfortable`. Giữ nguyên để app đang dùng không gãy.

## 3. Khóa mới

| Nhóm | Khóa | Ghi chú |
|---|---|---|
| Ngân sách | `budget.tier.economy`, `budget.tier.moderate`, `budget.tier.comfortable` + `.desc` | Theo backlog |
| Sức khỏe | `health.nhieu_xo`, `health.it_duong`, `health.tot_cho_tim`, `health.it_beo` + `.desc`; `health.disclaimer` | Theo `health-tags.md` mục 5 |
| Ảnh | `image.placeholder` | Ảnh món chưa có |
| Lỗi mạng | `errors.network.title`, `errors.offline.retry` | Thêm cạnh `errors.network.body` |
| Freemium (soạn sẵn, chưa dùng MVP) | `freemium.week.limit`, `freemium.swap.limit` ({{count}} / 3), `freemium.restore.locked`, `freemium.trial.cta`, `freemium.trial.body`, `freemium.upgrade.cta` | PRD §12 |

## 4. Thay đổi giá trị (tên khóa giữ nguyên)

| Khóa | Cũ | Mới | Lý do |
|---|---|---|---|
| `shopping.week_cost` | Chi phí theo gram dùng | Chi phí món ăn tuần này | PRD US-4.1 AC3 |
| `shopping.till_cost` | Chi phí theo gói mua | Ước tính trả tại quầy | PRD US-4.1 AC3 |
| `onboarding.generating.wait` | Thường mất khoảng một phút. | Thường mất vài giây. | D-ONB-04 |
| `app.name` | Món Ngon | FitPro - Mâm đủ | PRD §11 |
| `onboarding.targets.formula` | Dùng công thức của Món Ngon | Dùng công thức mặc định | Không hard-code tên app |

Các khóa `shop*` trong `arb_extra.json` (do Dev đã cập nhật, đúng nhãn PRD) đã có trong `vi.json` với cùng giá trị.

## 5. Việc Dev cần biết (T-074)

1. `gen_arb.py` đọc `content/i18n/vi.json` trước; nếu có thì không dùng nháp. Nên bỏ nhánh nháp.
2. `vi.json` đã chứa mọi khóa của `arb_extra.json` (trừ hai khóa trùng tên ARB đã nêu ở mục 2). Khi `gen_arb.py` vẫn merge `arb_extra.json`, nó in cảnh báo "ghi đè" cho từng khóa, không lỗi. Khi T-074 xóa `arb_extra.json`, cảnh báo sẽ hết.
3. Tôi **chưa chạy** `gen_arb.py` (ghi vào `mobile/`, ngoài phạm vi). Dev cần chạy lại để `app_vi.arb` nhận nhãn mới của `shopping.*`, `onboarding.generating.wait`, `app.name`.

## 6. Kiểm tra

- `npm run validate-data`: 0 lỗi, 1 cảnh báo (kcal `rau_den`, đã ghi).
- `npm run export-golden`: 55 tệp.
- `npm test`: 173/173.
- `engine-report` (C#): 16/16 hồ sơ đạt 7/7 (112/112 ngày).
- Kiểm tra tên ARB: 464 khóa `vi.json` = 464 khóa `app_vi.arb` hiện tại; không thiếu, không thừa.

## 7. Bốn văn bản pháp lý (07/11/2026)

Khóa (tên giữ nguyên, đang dùng trong app): `profileDisclaimerTitle`, `profileDisclaimerBody`, `profileSourcesBody`, `profilePricesTitle`, `profilePricesBody`, `profilePrivacyTitle`, `profilePrivacyBody`, `profileSectionAbout`.

- `profileDisclaimerBody` trong `vi.json` đã sửa: danh sách lựa chọn theo D-ONB-03 ("Nhiều chất xơ", "Ít đường", "Tốt cho tim mạch", "Ít béo"). Bản trong `mobile/tool/arb_extra.json` còn "Hợp người tiểu đường" và "Chống viêm", hai lựa chọn không có trong MVP.
- **Lưu ý cho Dev:** `gen_arb.py` merge `arb_extra.json` sau `vi.json` và để giá trị ở `arb_extra.json` thắng. Vì vậy app vẫn hiện bản cũ cho đến khi Dev sửa hoặc xóa `arb_extra.json` (T-074). Cần sửa `profileDisclaimerBody` trong `arb_extra.json` cùng lúc.
- `profilePrivacyBody`, `profileSourcesBody`, `profilePricesBody`: giữ nguyên nội dung của Dev, đã đối chiếu với `legal-notes.md` mục 2–4 và với code (không có tài khoản, không analytics, API không lưu). Lưu ý "máy chủ không lưu lại" chỉ đúng khi backend chưa triển khai (xem `legal-notes.md` mục 4).

## 8. Câu ngân sách mới (T-057b, D-QA-02, 07/11/2026)

Thêm vào `content/i18n/vi.json` (khóa mới, không đổi khóa cũ):
- `shopping.budget.food_under`: "Chi phí món ăn tuần này nằm trong ngân sách (dư {amount})."
- `shopping.budget.food_over`: "Chi phí món ăn tuần này vượt ngân sách {amount}."
- `shopping.budget.till_info`: "Lần đi chợ này ước tính {amount}, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau."

Tên ARB tương ứng: `shoppingBudgetFoodUnder`, `shoppingBudgetFoodOver`, `shoppingBudgetTillInfo`. Không trùng khóa cũ. `gen_arb.py` cần được chạy lại để app nhận các khóa này (Dev).

## L-12: chuỗi cảnh báo ngân sách ở tổng kết (07/11/2026)

Thêm vào `content/i18n/vi.json` (giữ nguyên `onboardingSummaryBudgetLow`), rồi chạy `gen_arb.py`:

| Khóa vi.json | Khóa ARB | Tham số ARB (theo thứ tự) |
|---|---|---|
| `onboardingSummaryBudgetLowReason` | `onboardingSummaryBudgetLowReason` | `v1` = min (mức gợi ý), `v2` = earlier (mức lúc chọn ngân sách) |
| `onboardingSummaryUseMinAmount` | `onboardingSummaryUseMinAmount` | `min` |

Lưu ý: `gen_arb.py` đổi tên tham số thành `v1`, `v2` khi một chuỗi có từ hai tham số trở lên, nên Dev phải truyền đúng thứ tự trên. Với `onboardingSummaryBudgetLow` (đã có sẵn), ARB là `{v1}` = budget, `{v2}` = min.

Chưa gửi được cho Dev qua hub (hub tạm dừng nhắn). Dev cần đọc mục này.

## T-057c (07/11/2026): rà TC có giả định offline

- TC-E-04: sửa kết quả theo D-QA-10 (báo không có mạng + Thử lại, dữ liệu giữ nguyên). Ghi lý do ở chính dòng TC.
- Thêm TC-E-11 (tuần đã tạo xem được offline) và TC-E-12 (Thử lại khi có mạng).
- Rà các TC khác: không có TC nào khác giả định tạo tuần offline. TC-6-05 (xóa dữ liệu), TC-1-37/TC-E-05 (đóng app giữa onboarding) đều không cần mạng. TC-E-09 (riêng tư: "không gửi dữ liệu ra ngoài máy") cần PM xem lại: tạo tuần đi qua API, nên câu này chỉ đúng nếu API là máy dev của chính người dùng. Chưa sửa, cần quyết định của PM.

## TC-E-09 theo D-QA-11 (07/11/2026, gộp vào T-057c)

- Kết quả mong đợi thay "không gửi dữ liệu ra ngoài máy" bằng: chỉ gửi dữ liệu cần để lập thực đơn, chỉ tới máy chủ của app, không tới bên thứ ba, không gửi tên/email/mã thiết bị, máy chủ không lưu nội dung yêu cầu sau khi trả kết quả.
- Ba bước kiểm: (1) host duy nhất; (2) payload đúng OpenAPI; (3) log API không ghi body.
- Ngoài phạm vi TC: log truy cập của hosting/proxy, điểm mở trước phát hành (legal-notes).
