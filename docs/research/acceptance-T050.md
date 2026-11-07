# Kiểm thử chấp nhận T-050 (bản data đóng băng)

Ngày: 07/11/2026 · Owner: RESEARCH · Theo `docs/research/test-scenarios.md` và AC trong `docs/pm/prd.md`.
Không sửa code, `data/` hay `content/`. Chỉ ghi kết quả.

## 1. Môi trường

- **Data đóng băng:** `data_version` = `0b6c64572f5ed7ec41d73fe1eb7de4529f16c909da242982e82bd24b47c33d7d`. Khớp với `GET /v1/reference` của API đang chạy.
- **API:** `http://localhost:5095` (đã có sẵn một tiến trình trên cổng này; `dotnet run` của tôi không bind được vì cổng bận). Health `200 {"status":"ok"}`.
- **App:** `app-release.apk` build với `FITPRO_CLEARTEXT=1` (55,8 MB), cài trên `emulator-5554` (Pixel_7, 1080×2400).
- **Kiểm API:** script `scratchpad/t50_api.mjs` và `scratchpad/t50_extra.mjs`. Kết quả thô: `scratchpad/t50_api_results.json`.

## 2. Tóm tắt

| Nhóm | Kết quả |
|---|---|
| API và engine (đã chạy) | 33 đạt · 6 không đạt (lỗi thật) · 2 chưa xác nhận · 2 thuộc UI |
| App (emulator) | Đã xem tab Kế hoạch và Đi chợ. Tab Bạn **không mở được** (3 lần chạm không phản hồi). Phần lớn AC UI chưa kiểm |
| Lỗi chặn | Không tìm thấy lỗi chặn trong phạm vi đã kiểm |
| Lỗi nặng | 3 (TC-2-04, TC-1-23, TC-1-24) |
| Lỗi nhẹ | 3 (TC-1-17/E-02, TC-1-31, TC-2-04b) |

## 3. Bảng AC/TC

Ký hiệu: ✅ đạt · ❌ không đạt · ⚠️ chưa xác nhận · ➖ thuộc UI (chưa kiểm trên app)

### Epic 1 — Onboarding và chỉ tiêu

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-1-01 | Nam 30t, 177,8 cm, 81,6 kg, vừa, giảm mỡ → 2.200 kcal, 175 g đạm | ✅ | API |
| TC-1-02 | Có đủ bước trung gian BMR→TDEE→mục tiêu→đạm | ✅ | API |
| TC-1-03/04 | Tuổi, chiều cao, cân nặng ngoài biên | ✅ API · ➖ UI | API từ chối 400 |
| TC-1-05 | Tự nhập 1.800 kcal / 120 g đạm được dùng nguyên | ✅ | API |
| TC-1-06 | Nữ 30t giữ cân: bội 50 kcal, đạm ≤ trần 35% | ✅ | API, 5 mức vận động |
| TC-1-07 | Dải calo | ✅ | Theo PRD AC5 = [−5%; +5%]. **TC-1-07 trong test-scenarios ghi [−5%; mục tiêu] là lỗi tài liệu** (lệch PRD). Cần sửa tài liệu test |
| TC-1-09 | Bước ngân sách 50.000 ₫, ≥ 3 bậc | ✅ | API |
| TC-1-10 | Min/max ngân sách theo số người và bữa | ✅ | API |
| TC-1-12 | Định dạng `600.000 ₫` | ✅ | Thấy trên màn Đi chợ: `444.766 ₫`, `22.478 ₫` |
| TC-1-17 / TC-E-02 | Không cho tắt hết bữa chính | ❌ | API trả 200 khi tắt trưa và tối. Chưa kiểm app có chặn ở bước onboarding không → xem lỗi L-02 |
| TC-1-18/19 | Loại trừ lẫn nhau khi chọn kiêng | ➖ | Thuộc UI |
| TC-1-21 | Không lạc: không món nào có lạc | ✅ | API, 5 seed (nhưng xem TC-1-22) |
| TC-1-22 | Không hạt cây: lạc vẫn xuất hiện | ⚠️ | Lạc **không xuất hiện trong 30 seed**, kể cả không loại trừ gì. Không kiểm được. Xem lỗi L-05 |
| TC-1-23 | Không hạt giống: loại vừng | ❌ | `no_seed` không cấm vừng. Xem lỗi L-03 |
| TC-1-24 | Gõ "rau muong" → gợi ý "Rau muống" | ❌ | Kho không có rau muống. Xem lỗi L-04 |
| TC-1-25 | ≥ 6 chip món ghét | ✅ | API |
| TC-1-26 | "Nhiều chất xơ" là xu hướng, có miễn trừ | ✅ | API có 4 id chốt; miễn trừ là UI |
| TC-1-31 | Không chọn thiết bị nấu → chặn | ❌ | API trả 200 với `equipment: []`. Xem lỗi L-02 |
| TC-1-32 | Chỉ lò vi sóng: tạo được, không món cần bếp | ✅ | API |

Các TC 1-08, 1-11, 1-13 đến 1-16, 1-20, 1-27 đến 1-30, 1-33 đến 1-38 là thao tác UI, chưa kiểm trên app.

### Epic 2 — Lập tuần và validator

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-2-01 | Hồ sơ dễ: 7/7 ngày đạt | ✅ | API |
| TC-2-02 | Bất khả thi → `partial` | ✅ | API |
| TC-2-03 | Macro = Σ gram × giá trị/100 g | ✅ | 70 món, ±1 g đạm, ±5 kcal |
| TC-2-04 | Gram trong [min, max] | ❌ | Xem lỗi L-01 |
| TC-2-04b | Gram không phải gia vị làm tròn 5 g | ❌ | Xem lỗi L-06 |
| TC-2-05 | Cùng hồ sơ và seed → tuần giống hệt | ✅ | API |
| TC-2-06 | Banner nêu số ngày không đạt | ✅ | Kiểm trên hồ sơ thiếu đạm (`days_missing` = 7). Hồ sơ ngân sách thấp báo `partial` do vượt ngân sách, không do ngày |
| TC-2-07 | Ngày thiếu có mức thiếu cụ thể | ✅ | Ví dụ: `2026-11-09 protein_low 34,6 g` |
| TC-2-08 | Chi phí món ≤ ngân sách | ✅ | Hồ sơ mẫu |
| TC-2-09 | Số món chính khác nhau 10–12 | ✅ | Hồ sơ mẫu |
| TC-2-10 | Trưa và tối cùng ngày không trùng món chính | ✅ | |
| TC-2-11 | Ràng buộc cứng trên toàn bộ hồ sơ test | ✅ | 16/16 hồ sơ, không vi phạm kiêng, dị ứng, ghét, dụng cụ |
| TC-2-12 | Sở thích "thích món kho" tăng tỉ lệ | ⚠️ | Chưa kiểm |
| TC-2-13 | Bữa sáng "Tự lo": không món, vẫn có chỉ tiêu | ✅ | API |

### Epic 3 — Kế hoạch và công thức

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-3-01 | Thanh tab 3 mục: Kế hoạch · Đi chợ · Bạn | ✅ | Thấy trên app |
| TC-3-03 | Ngày có tiêu đề "Chủ nhật · 08/11", tổng đạm và kcal | ✅ | Ảnh tab Kế hoạch |
| TC-3-04 | Bữa có ảnh/placeholder, nhãn bữa, thời gian nấu, tên món | ✅ | "Bữa sáng · 35 phút" |
| TC-3-05 | "Ăn ngoài" hiển thị dạng dòng | ✅ | Thấy "Ăn ngoài" và nút Hoàn tác |
| TC-3-11 | kcal công thức lệch ≤ ±5% so với 4/4/9 | ⚠️ | Dữ liệu có 1 cảnh báo (`rau_den`, lệch 26%). Chưa kiểm toàn bộ |
| TC-3-12/13/14 | Bảng "Cách chúng mình tính" và nguồn | ⚠️ | Chưa mở công thức trên app |

### Epic 4 — Đi chợ

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-4-01 | Nhóm theo quầy | ✅ | Thấy "Thịt", "Trứng & đậu phụ" |
| TC-4-02 | Gram cần so với số gói, có phần dư | ✅ | "Cần 35 g · Dư 165 g" |
| TC-4-03 | Hai con số chi phí, nhãn ước tính, ngày khảo sát | ✅ | "Chi phí món ăn tuần này" và "Ước tính trả tại quầy"; "Giá khảo sát ngày 06/11/2026" |
| TC-4-04 | Đã mua, nhà có sẵn, lưu sau khi tắt app | ⚠️ | Thấy nút "Nhà có sẵn". Chưa kiểm lưu trạng thái |
| TC-4-05 | Chia sẻ danh sách | ⚠️ | Có nút chia sẻ, chưa bấm |
| TC-4-06 | Tăng người ăn 1 → 3: chi phí tăng | ✅ | API |
| TC-4-07 | Thiếu giá cửa hàng → dùng giá chợ | ✅ | API, `price_fallback` = true |

### Epic 5 — Thay đổi tuần

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-5-01 | 2–3 gợi ý kèm chênh lệch | ✅ | API |
| TC-5-02 | Chọn gợi ý → validator chạy lại | ✅ | API |
| TC-5-04 | Đổi nguyên liệu cùng `swap_group` | ⚠️ | Lỗi trong script (bữa tối ngày đó không có ức gà), chưa chạy lại |
| TC-5-06 | Ăn ngoài: đánh dấu, bữa khác giữ nguyên | ✅ | API |
| TC-5-12 | Lên lại phần còn lại: ngày đã qua giữ nguyên | ✅ | API |
| TC-5-03, 05, 07–11, 13, 14 | | ➖ | Chưa kiểm |

### Epic 6, phi chức năng

| TC | Nội dung | Kết quả | Ghi chú |
|---|---|---|---|
| TC-6-01…05 | Tab Bạn | ⚠️ | **Không mở được tab Bạn trên emulator.** Không kiểm |
| TC-E-03 | Loại gần hết nguồn đạm: không crash | ✅ | API trả 200 `partial` |
| TC-E-07 | Tạo tuần ≤ 1 s (server) | ✅ | 4 hồ sơ khó, đều dưới 1 s |
| TC-E-08 | Vùng chạm ≥ 44 pt, tương phản | ⚠️ | Chưa đo |
| TC-E-09 | Không gửi dữ liệu người dùng ra ngoài | ⚠️ | Đọc mã: API không lưu, app không có SDK phân tích. Chưa đo mạng trên thiết bị |
| TC-E-04 | Mất mạng vẫn tạo tuần | ⚠️ | Chưa kiểm |
| TC-E-10 | Dữ liệu lỗi → báo rõ file và id | ⚠️ | Chưa kiểm (không sửa data) |

## 4. Lỗi

Mức độ: **chặn** = không dùng được luồng chính; **nặng** = sai AC hoặc sai dữ liệu người dùng thấy; **nhẹ** = lệch nhỏ, không sai số liệu.

### L-01 — Gram vượt [min, max] của công thức (nặng, engine)
- **Bước:** `POST /v1/plans` với hồ sơ `female, 30, hold, moderate, formula`, ngân sách 900.000 ₫, seed 1.
- **Thực tế:** `dessert_che_dau_xanh` (chè đậu xanh) có `duong` = 5 g. Công thức khai `duong` min = max = 8 g. Lặp lại ở nhiều ngày và seed 1–2.
- **Mong đợi:** mọi gram nằm trong [min, max] (TC-2-04).
- **Ghi chú:** 2 món khác cùng kiểu (`dessert_che_dau_do`) cũng có lỗi. Có thể engine điều chỉnh đường khi scale tráng miệng.

### L-02 — API không chặn đầu vào mà TC yêu cầu (nặng nếu app cũng không chặn, nhẹ nếu app chặn)
- **Bước:** (a) tắt trưa và tối, chỉ còn sáng; (b) `equipment: []`.
- **Thực tế:** cả hai trả `200` và tạo tuần.
- **Mong đợi:** `400` với thông báo (TC-1-17, TC-1-31).
- **Chưa biết:** app có chặn trước khi gọi API không (bước onboarding chưa kiểm được).

### L-03 — "Không hạt giống" không loại vừng (nặng, lệch AC)
- **Bước:** `exclusions: ["no_seed"]`, 5 seed.
- **Thực tế:** vừng (`vung`) vẫn xuất hiện. `no_seed` chỉ cấm tag `seed`; vừng chỉ có tag `sesame`.
- **Mô tả trong API:** "Không loại nguyên liệu nào trong kho hiện tại". Đây là mô tả đúng với dữ liệu, nhưng TC-1-23 mong đợi vừng bị loại.
- **Cần quyết định PM:** gộp "Không vừng" vào "Không hạt giống", hoặc sửa TC-1-23. Sửa dữ liệu thuộc Research, nhưng data đang đóng băng.

### L-04 — Không tìm được "rau muống" (nặng, thiếu dữ liệu)
- **Bước:** `GET /v1/ingredients?q=rau muong`.
- **Thực tế:** không có kết quả. Kho không có rau muống (ghi nhận trong `recipes-mam-notes.md`).
- **Mong đợi:** gợi ý "Rau muống" (TC-1-24, cũng là ví dụ trong PRD).

### L-05 — Lạc không bao giờ được chọn (không xác nhận được)
- **Bước:** 30 seed, hồ sơ mặc định, không loại trừ gì.
- **Thực tế:** 0/30 tuần có món chứa lạc.
- **Ảnh hưởng:** TC-1-22 không kiểm được. Có thể là kết quả thiết kế (ít món lạc, bị điểm thấp) hoặc lỗi.
- **Cần:** Dev kiểm vì sao món lạc không vào được. Research có thể đếm số món lạc khả dụng.

### L-06 — Gram chất béo cố định không bội 5 g (nhẹ, dữ liệu)
- **Bước:** `main_dau_xanh_nam_hap_chay`, `dau_an` role `fat`, min = max = 3 g.
- **Thực tế:** 3 g.
- **Mong đợi:** làm tròn 5 g. AC chỉ miễn cho gia vị 1 g; dầu ăn là `fat`, không phải gia vị. TC cần làm rõ.

### L-07 — Tài liệu test lệch PRD (nhẹ, tài liệu)
- `test-scenarios.md` TC-1-07 ghi dải calo [−5%; mục tiêu]. PRD AC5 là [−5%; +5%]. Sửa tài liệu test.

### L-08 — Nút "Ngân sách" báo "Còn trong ngân sách" theo món ăn, không theo "trả tại quầy" (nhẹ, cần làm rõ)
- Trên màn Đi chợ: ngân sách 700.000 ₫, món ăn 444.766 ₫ → "Còn trong ngân sách, dư 255.234 ₫". Trả tại quầy 1.040.478 ₫ vượt ngân sách.
- PRD AC3 yêu cầu "so với ngân sách" nhưng không nói so với số nào. Cần PM quyết định.

### L-09 — Tab Bạn không phản hồi khi chạm (chưa rõ, cần Dev xem)
- Chạm tab Bạn ba lần (các vị trí khác nhau) không chuyển màn hình. Tab Đi chợ và Kế hoạch chuyển được.
- Có thể là lỗi của emulator/input hoặc của app. Chưa xác định.

## 5. Chưa kiểm

- Onboarding (TC-1-08…1-38 phần UI), tab Bạn, công thức (TC-3-06…3-10), đổi món và đổi nguyên liệu trên UI, trợ năng, mất mạng, đổi múi giờ, xóa dữ liệu.
- Phía API cũng chưa kiểm: TC-2-12 (sở thích), TC-E-10 (dữ liệu lỗi, không được sửa data).

## 6. Số liệu kiểm thử API

Script: `scratchpad/t50_api.mjs`. Lần chạy đầu: 43 mục, 31 đạt, 10 không đạt, 2 thuộc UI. Sau khi xem lại:
- TC-2-06 và TC-2-07 đạt (lần đầu kiểm sai hồ sơ, xem mục 3).
- TC-1-22 chuyển sang "chưa xác nhận" (L-05).
- TC-5-04 chuyển sang "chưa xác nhận" (lỗi script).
- 6 mục không đạt ứng với 5 lỗi (L-02 gồm TC-1-17 và TC-1-31); TC-1-07 là lỗi tài liệu, không tính vào sản phẩm.
