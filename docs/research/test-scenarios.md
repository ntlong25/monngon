# Kịch bản test chức năng — FitPro - Mâm đủ (T-049, sửa T-057b)

Ngày: 06/11/2026 · Cập nhật: 07/11/2026 (T-057b) · Owner: RESEARCH · Căn cứ: `docs/pm/prd.md` (US-x.y, AC, D-QA-01…07) và spec Mealbird mục 4 (F-ONB, F-ENG, F-PLN, F-RCP, F-SHP, F-CHG).

**Thay đổi ngày 07/11/2026 (T-057b):**
- TC-1-07: dải calo ±5% (D-QA-03). TC-1-07 cũ ghi [−5%; mục tiêu].
- TC-2-04: mọi gram trong [min, max]; TC-2-04b mới: chỉ dòng scale được làm tròn 5 g, dòng cố định giữ gram công thức (D-QA-04).
- TC-1-22: kiểm ở cấp bộ lọc, không đòi lạc xuất hiện trong tuần (D-QA-06).
- TC-1-23: "Không hạt giống & vừng" (id `no_seed`) loại cả vừng và hạt hướng dương; `no_sesame` vẫn chỉ cấm vừng (D-QA-01).
- TC-4-03: trạng thái ngân sách so theo chi phí món ăn; tiền tại quầy vượt ngân sách chỉ có dòng thông tin trung tính (D-QA-02).

## Quy ước

- Mã: `TC-<epic>-<số>` ↔ `US-x.y`. Ví dụ `TC-1-03` kiểm US-1.1 hoặc nhóm AC liên quan; cột "US" ghi rõ.
- **P0** = bắt buộc cho MVP chạy được (Epic 1–4). **P1** = MVP đầy đủ (Epic 5–6).
- Mỗi ca ghi: bước thực hiện, kết quả mong đợi. Thử trên bản web (`npx expo start --web`) và, khi có, trên iOS/Android.
- Giá trị trong ca lấy từ spec/PRD. Các giá trị tính toán (kcal, gram) do engine đưa ra; ca nào có số cụ thể thì đối chiếu với `docs/research/recipes-notes.md` và bảng `docs/pm/prd.md`.
- Trạng thái ghi vào `docs/qa/test-report.md` (T-050), không ghi ở đây.

---

## Epic 1 — Onboarding và chỉ tiêu (US-1.1 … US-1.6)

### US-1.1 — Đặt chỉ tiêu theo cơ thể

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-01 | P0 | Mở onboarding; chọn "Giảm mỡ"; nhập nam, 30 tuổi, 177,8 cm, 81,6 kg, vận động "vừa"; bấm Tiếp tục | Màn kết quả ra **2.200 kcal** và **175 g protein** (ví dụ spec, AC3) |
| TC-1-02 | P0 | Ở màn kết quả, xem từng dòng | Hiển thị đủ BMR → TDEE → mục tiêu → protein; mỗi dòng có giá trị trung gian (AC4) |
| TC-1-03 | P0 | Nhập tuổi 13 rồi 91 | Báo lỗi tại ô tuổi; nút Tiếp tục bị khóa (AC1) |
| TC-1-04 | P0 | Nhập chiều cao 119 cm và 221 cm; cân nặng 29 kg và 251 kg | Báo lỗi từng ô; không cho đi tiếp (AC1) |
| TC-1-05 | P0 | Chuyển sang "Tự nhập": nhập 1.800 kcal và 120 g protein | Chỉ tiêu dùng số tự nhập; công thức không ghi đè (AC4) |
| TC-1-06 | P0 | Với hồ sơ nữ 30 tuổi, mục tiêu giữ cân, mọi mức vận động | Calo làm tròn bội 50; không bao giờ vượt trần 35% calo cho protein (AC2) |
| TC-1-07 | P0 | Kiểm dải calo mặc định | Dải = [mục tiêu −5%; mục tiêu +5%] (PRD AC5, D-QA-03) |

### US-1.2 — Cửa hàng, ngân sách, số người ăn

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-08 | P0 | Mở danh sách cửa hàng; chọn Bách hóa Xanh, rồi WinMart | Chỉ 1 thẻ được chọn tại một thời điểm; thẻ có viền và dấu tích; có chú thích "giá là ước tính" (AC1) |
| TC-1-09 | P0 | Kéo thanh ngân sách từ min đến max | Bước nhảy 50.000 ₫; nhãn bậc chi tiêu đổi theo vị trí (≥ 3 bậc) (AC2) |
| TC-1-10 | P0 | Với 1 người lớn, 0 trẻ, 14 bữa: đọc min/max | Min/max tính theo số người và số bữa; không hiển thị số âm (AC2) |
| TC-1-11 | P0 | Tăng người lớn lên 6, giảm xuống 1; trẻ em lên 4 | Stepper giới hạn đúng 1–6 và 0–4 (AC3) |
| TC-1-12 | P0 | Kiểm định dạng tiền | Hiển thị `600.000 ₫` (dấu chấm nghìn, ký hiệu ₫ cách một khoảng) (AC4) |
| TC-1-13 | P0 | Đọc ghi chú dưới số người | Có dòng "chỉ tiêu dinh dưỡng là của riêng bạn" (AC3) |

### US-1.3 — Chọn bữa cần lên thực đơn

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-14 | P0 | Bật cả 5 slot; bật trưa "Nóng", phụ chiều "Ngọt" | Chân màn hiển thị "mỗi bữa ~X kcal và Y g protein", cập nhật ngay (AC1, AC2) |
| TC-1-15 | P0 | Chọn bữa sáng "Tôi tự lo" | Chỉ tiêu sáng vẫn giữ; tổng các slot `on` + `self` = chỉ tiêu ngày (AC3) |
| TC-1-16 | P0 | Chọn bữa sáng "Không ăn" | Chỉ tiêu sáng chia lại cho các bữa còn lại; tổng vẫn bằng chỉ tiêu ngày (AC3) |
| TC-1-17 | P0 | (a) Tắt cả sáng, trưa, tối (không bữa chính nào ở chế độ "Lên thực đơn"). (b) Tắt trưa, tối, chỉ còn sáng | (a) App khóa nút Tiếp tục và hiện lời nhắc còn ≥ 1 bữa chính; API trả 400 với trường lỗi. (b) Hợp lệ: bữa sáng là bữa chính, API trả 200 (AC4, D-QA-05; PM sửa 2026-11-07) |

### US-1.4 — Kiêng, dị ứng, món ghét

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-18 | P0 | Chọn "Không kiêng gì", rồi chọn thêm "Không lợn" | "Không kiêng gì" bỏ chọn các lựa chọn còn lại; loại trừ lẫn nhau (AC1) |
| TC-1-19 | P0 | Chọn "Chay" và "Thuần chay" cùng lúc | Chỉ được một kiểu chay; lựa chọn còn lại tự bỏ (AC1) |
| TC-1-20 | P0 | Chọn "Ít tinh bột" cùng "Thuần chay" | Cả hai cùng được chọn (AC1) |
| TC-1-21 | P0 | Chọn "Không lạc"; tạo tuần với hồ sơ này | Không công thức nào có lạc (kể cả "lạc rang muối", "đậu hũ chiên với lạc") (AC2) |
| TC-1-22 | P0 | Chọn "Không hạt cây" (không chọn "Không lạc") | Ở cấp bộ lọc (unit test `Filter`): món chứa lạc vẫn thuộc tập hợp hợp lệ; hạt điều, óc chó bị loại. Không đòi lạc xuất hiện trong tuần (D-QA-06, ưu tiên thấp). Phạm vi lựa chọn được ghi rõ trong UI (AC3) |
| TC-1-23 | P0 | Chọn "Không hạt giống & vừng" (id `no_seed`) | Vừng và hạt hướng dương bị loại (cấm cả tag `seed` và `sesame`); UI nói rõ "hạt giống" gồm những gì (AC3, D-QA-01). Chọn riêng "Không vừng" (`no_sesame`) thì chỉ cấm vừng |
| TC-1-24 | P0 | Gõ "rau muong" trong ô tìm nguyên liệu | Gợi ý "Rau muống" (tìm không dấu) (AC4) |
| TC-1-25 | P0 | Mở chip gợi ý món hay bị ghét | Có ≥ 6 chip; chọn một chip thì nguyên liệu vào danh sách loại (AC4) |
| TC-1-26 | P0 | Chọn "Nhiều xơ" trong xu hướng nấu ăn | Chỉ là ưu tiên mềm; hiển thị dòng miễn trừ y tế bên cạnh (AC5) |

### US-1.5 — Thẻ vuốt và dụng cụ bếp

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-27 | P0 | Vuốt phải 1 thẻ, trái 1 thẻ | Thẻ phải ghi "thích", thẻ trái ghi "ít hơn"; tiến đến thẻ kế tiếp (AC1) |
| TC-1-28 | P0 | Dùng nút ✕, ♥ thay vì vuốt; bấm "Hoàn tác" | Nút hoạt động như vuốt; hoàn tác quay lại thẻ trước (AC1) |
| TC-1-29 | P0 | Kiểm trên bàn phím và trình đọc màn hình | Mọi thao tác vuốt có nút thay thế (NFR trợ năng) |
| TC-1-30 | P0 | Ở màn kết quả, bấm "Vuốt lại" | Kết quả xóa, thẻ hiện lại từ đầu (AC2) |
| TC-1-31 | P0 | Bỏ chọn hết thiết bị nấu | App khóa nút Tiếp tục kèm lời nhắc cần ≥ 1 thiết bị nấu; API trả 400 khi `equipment` rỗng (AC3, D-QA-05) |
| TC-1-32 | P0 | Chọn chỉ "Lò vi sóng" | Tạo tuần được; công thức cần bếp không xuất hiện (AC3) |

### US-1.6 — Tổng kết và tạo tuần

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-33 | P0 | Đi tới màn tổng kết với các lựa chọn đã đặt | Checklist hiện lần lượt: mục tiêu, protein, calo, số bữa, xu hướng, đã loại, căn bếp, ngân sách; giá trị khớp lựa chọn (AC1) |
| TC-1-34 | P0 | Bấm "Tạo thực đơn tuần" | UI không đơ; hoàn tất ≤ 5 giây với dữ liệu MVP trên máy tầm trung (AC2, hiệu năng) |
| TC-1-35 | P0 | Tạo tuần xong | Chuyển sang tab Kế hoạch; ngày đầu tiên là ngày mai theo giờ máy (AC3) |
| TC-1-36 | P0 | Quay lại từ bước 6 về bước 2 rồi tiến lại | Mọi lựa chọn giữ nguyên (AC4) |
| TC-1-37 | P0 | Đóng app ở bước 5; mở lại | Tiếp tục đúng bước 5 với dữ liệu đã nhập (AC4) |
| TC-1-38 | P0 | Ở màn tổng kết, kiểm xem có nút trả phí không | Không có paywall; chỉ có chỗ trống sau màn tổng kết (PRD 4.1, P2) |

### US-1.4b — Thói quen ăn cơm (D-COM-01, T-059c)

| ID | P | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC-1-39 | P0 | Vào bước "Thói quen ăn cơm" sau bước Kiêng/Ghét/Vuốt (giữa US-1.4 và US-1.5) | Có câu "Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?" và 4 nhãn đúng `onboarding.rice.*` trong vi.json; mặc định "Vừa (1 chén)" được chọn (US-1.4b AC1) |
| TC-1-40 | P0 | Đọc ghi chú dưới các nhãn | Có "Chỉ áp cho bạn. Người lớn khác ăn mức Vừa, trẻ em ăn 0,6 suất." (US-1.4b AC1) |
| TC-1-41 | P0 | Hồ sơ giảm mỡ 1.400 kcal, 4 bữa: chọn "Rất nhiều (3 chén trở lên)" | Hiện "Với mức calo hiện tại, một số bữa sẽ phải bớt cơm. Bạn vẫn có thể giữ lựa chọn này."; nút Tiếp tục vẫn bật (không chặn). Quy tắc: kcal cơm của mức > 45% kcal trung bình một bữa chính (trưa và tối, lấy từ phân bổ US-1.3) (US-1.4b AC2). Tham số "bữa chính" cần PM xác nhận |
| TC-1-42 | P0 | Ở US-1.4 chọn "Ít tinh bột" (`low_carb`), rồi đi tới bước thói quen | Bước được bỏ qua; tuần sau đó không có món cơm ở mâm trưa/tối (US-1.4b, D-COM-01) |
| TC-1-43 | P0 | Tab Bạn → "Thói quen ăn cơm" → đổi từ "Vừa" sang "Nhiều" | Hỏi xác nhận trước khi đổi. Sau khi xác nhận: các ngày đã qua và hôm nay giữ nguyên, các ngày sau được lên lại; danh sách đi chợ cập nhật lượng gạo (US-1.4b, US-5.5) |
| TC-1-44 | P0 | Hồ sơ 2 người lớn + 1 trẻ; người dùng chính chọn "Rất nhiều"; mở một mâm trưa có cơm | Cơm của người dùng chính 450 g; người lớn khác 150 g; trẻ 90 g (0,6 × 150 g). Danh sách đi chợ cộng gạo theo tổng cơm cả nhà với hệ số 0,36 (gạo trắng) hoặc 0,34 (gạo lứt) (US-1.4b, hộ gia đình) |
| TC-1-45 | P0 | Kiểm chuỗi i18n sau khi chạy `gen_arb.py` | Mọi khóa `onboarding.rice.*`, `meal.rice_*`, `profile.rice_habit.title` có trong `mobile/lib/l10n/app_vi.arb` (dạng camelCase). `mealRiceReduced` có 3 tham số `v1` (cơm thực tế), `v2` (cơm đã chọn), `v3` (kcal); app phải truyền đúng thứ tự này (T-059c) |
| TC-1-46 | P0 | Đọc 4 nhãn ở bước "Thói quen ăn cơm" | Nhãn đúng chữ: "½ chén (~75 g)", "1 chén (~150 g)", "2 chén (~300 g)", "3 chén trở lên (~450 g)". Gram trong ngoặc là gợi ý, cùng số với engine (`rice_habit` = `it`/`vua`/`nhieu`/`rat_nhieu`). Không có nhãn mô tả dài kiểu "Ít cơm, ăn nhiều thức ăn" (T-059c, chuỗi chén) |
| TC-1-47 | P0 | Hồ sơ mặc định, ở bước ngân sách chọn 650.000 ₫ (mức tối thiểu hiện trên bước này), rồi quay lại chọn chế độ ăn "Ít tinh bột" hoặc đổi dụng cụ bếp, rồi đi tới tổng kết (L-12) | Nếu mức tối thiểu gợi ý ở tổng kết khác mức đã chọn, hiện khối cảnh báo `onboardingSummaryBudgetLow` và dòng giải thích `onboardingSummaryBudgetLowReason` (có {min} = mức gợi ý và {earlier} = mức lúc chọn ngân sách). Hai con số trong câu phải khớp với hai mức thực tế. Nếu không khác, không hiện cảnh báo |
| TC-1-48 | P0 | Ở tổng kết có cảnh báo L-12, bấm nút "Dùng {min}" (`onboardingSummaryUseMinAmount`) | Ngân sách đổi thành mức tối thiểu gợi ý; cảnh báo biến mất; dòng Ngân sách ở tổng kết và tab Bạn cùng hiện mức mới; bấm Tạo thực đơn tuần dùng mức đó |

---

## Epic 2 — Bộ máy lập tuần và validator (US-2.1 … US-2.4)

| ID | US | P | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-2-01 | 2.1 | P0 | Tạo tuần cho hồ sơ dễ (nữ 30t, giữ cân, 2 bữa chính) | 7/7 ngày đạt: mỗi ngày protein ≥ sàn và calo trong dải; không dựa trung bình tuần |
| TC-2-02 | 2.1 | P0 | Với hồ sơ bất khả thi (ngân sách sát sàn, 180 g protein) | Trả tuần kèm trạng thái `partial`; danh sách ngày thiếu và mức thiếu (US-2.2) |
| TC-2-03 | 2.1 | P0 | Mở một món và kiểm macro bằng tay: Σ gram × giá trị/100 g | Khớp kết quả hiển thị ±1 g protein, ±5 kcal (AC2) |
| TC-2-04 | 2.1 | P0 | Kiểm gram của mọi nguyên liệu trong mọi món | Mọi gram nằm trong [min, max] của công thức, kể cả dòng cố định (US-2.1 AC3, D-QA-04) |
| TC-2-04b | 2.1 | P0 | Kiểm làm tròn gram | Chỉ dòng scale được (đạm, tinh bột, dòng chính tráng miệng) làm tròn bội 5 g; dòng cố định (dầu, gia vị, rau cố định, đường trong chè) giữ gram công thức, không làm tròn, ví dụ dầu 3 g là hợp lệ (D-QA-04) |
| TC-2-05 | 2.1 | P0 | Tạo tuần 2 lần với cùng hồ sơ và seed | Hai tuần giống hệt từng món, từng gram (AC4, tất định) |
| TC-2-06 | 2.2 | P0 | Hồ sơ bất khả thi: tạo tuần | Có banner nêu số ngày không đạt; banner không bị ẩn khi cuộn (US-2.2 AC2) |
| TC-2-07 | 2.2 | P0 | Với `partial`, đọc chi tiết ngày thiếu | Có dạng "Thứ Năm thiếu 8 g protein" (không nói chung chung) |
| TC-2-08 | 2.3 | P0 | Kiểm tổng chi phí tuần so với ngân sách | Chi phí món ăn ≤ ngân sách; nếu vượt, báo vượt bao nhiêu |
| TC-2-09 | 2.3 | P0 | Đếm món chính khác nhau trong tuần (hồ sơ 14 bữa trưa+tối) | Khoảng 10–12 món khác nhau; món lặp có nhãn "Nấu 1 lần cho 2 bữa" |
| TC-2-10 | 2.3 | P0 | Kiểm 7 ngày, mỗi ngày bữa trưa và tối | Không có món chính giống hệt nhau ở 2 bữa liên tiếp cùng ngày (AC3) |
| TC-2-11 | 2.4 | P0 | Chạy bộ ≥ 10 hồ sơ có ràng buộc cứng (không lợn, thuần chay, dị ứng lạc, ít dụng cụ…) | Không có nguyên liệu bị loại xuất hiện trong bất kỳ tuần nào (tự động, xem `data/test-profiles.json`) |
| TC-2-12 | 2.4 | P0 | So hai tuần: một có sở thích "thích món kho", một không có | Tỉ lệ món thuộc xu hướng "thích" cao hơn ở tuần có sở thích (AC2) |
| TC-2-13 | 2.1 | P0 | Tạo tuần cho hồ sơ có bữa sáng "Tự lo" | Bữa sáng không có món, nhưng chỉ tiêu sáng được cộng vào tổng ngày |
| TC-2-14 | 2.4 | P0 | Kiểm `max_g` của mọi công thức `carb_base` (script đọc `data/recipes.json`) | Cơm trắng, gạo lứt, cơm hâm, cơm mang đi: `max_g` ≥ 450 g; bún: ≥ 542 g (585 kcal ÷ 108 kcal/100 g); khoai: ≥ 681 g (585 kcal ÷ 86 kcal/100 g). Hiện: cơm 500 g, bún 550 g, khoai 700 g (T-059c, D-COM-01) |
| TC-2-15 | 2.1 | P0 | Gọi `/v1/plans` cho p01 với lần lượt `rice_habit` = `it`, `vua`, `nhieu`, `rat_nhieu` | Mỗi bữa mâm trả `rice.target_g` = 75 / 150 / 300 / 450 g. `actual_g` ≥ max(50% target, 60 g). Protein ≥ sàn và kcal trong ±5% (US-1.4b, engine) |
| TC-2-16 | 2.1 | P0 | Hồ sơ kcal thấp chọn `rat_nhieu`, mâm không giữ được 450 g | Cơm giảm theo bước 25 g, không dưới sàn. Mỗi bữa có `actual_g < target_g − 10` đều có `notes: [{code: "rice_reduced", target_g, actual_g, reason}]`. Không có bữa nào bị giảm cơm mà thiếu ghi chú (US-1.4b, "Khi không vừa") |
| TC-2-17 | 2.4 | P0 | Gọi `/v1/plans` không có trường `preferences.rice_habit` | Không lỗi 400; API coi như `vua` (150 g), kết quả giống hệt khi gửi `vua` (tương thích máy khách cũ và golden) |
| TC-2-18 | 2.4 | P0 | Gọi `/v1/plans` với `low_carb` = true | Mâm trưa/tối không có món cơm và không có khối `rice` (bỏ bước, D-COM-01) |

---

## Epic 3 — Tab Kế hoạch và trang công thức (US-3.1 … US-3.3)

| ID | US | P | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-3-01 | 3.1 | P0 | Mở app sau khi có tuần | Thanh tab dưới có đúng 3 tab: Kế hoạch · Đi chợ · Bạn (AC1) |
| TC-3-02 | 3.1 | P0 | Mở tab Kế hoạch vào buổi sáng và buổi tối | Lời chào theo giờ; trạng thái tuần đúng ("Tuần của bạn bắt đầu từ ngày mai" hoặc "Hôm nay là ngày N") (AC2) |
| TC-3-03 | 3.1 | P0 | Cuộn 7 ngày | Mỗi ngày có tiêu đề "Thứ Hai · 26/10"; tổng protein và kcal đúng tiêu đề (AC3) |
| TC-3-04 | 3.1 | P0 | Xem một bữa có món | Có ảnh (hoặc placeholder), nhãn bữa, thời gian nấu, tên món (AC3) |
| TC-3-05 | 3.1 | P0 | Xem bữa "Tôi tự lo" và "Ăn ngoài" | Hiển thị dạng dòng mờ, không có món (AC4) |
| TC-3-06 | 3.2 | P0 | Mở một công thức | Có ảnh, ngữ cảnh "THỨ HAI · BỮA TRƯA", tên, thời gian, chip macro (protein, kcal, tinh bột, béo), link "Cách chúng mình tính", "Đổi món này", "Ăn ngoài / bỏ bữa", thẻ Nguyên liệu, Cách làm, "Không hợp với tôi" (AC1) |
| TC-3-07 | 3.2 | P0 | Xem nguyên liệu có quy đổi | Có dạng "410 g (≈ 2 thìa canh)" khi có quy đổi; bỏ qua nếu không có (AC2) |
| TC-3-08 | 3.2 | P0 | Hồ sơ 2 người lớn + 1 trẻ; mở công thức | Hai cột "Phần của bạn" và "Cả nồi"; người lớn khác = khẩu phần chuẩn, trẻ = 0,6 (AC3) |
| TC-3-09 | 3.2 | P0 | Chạm từng bước để đánh dấu xong; tắt app; mở lại | Trạng thái bước đã xong được giữ theo bữa (T-020) |
| TC-3-10 | 3.2 | P0 | Mở "Chế độ nấu"; đợi 2 phút không chạm | Màn hình không tắt; rời trang, màn hình trở về cài đặt bình thường (AC4, NFR-06) |
| TC-3-11 | 3.2 | P0 | Đọc kcal của một công thức, nhân lại 4/4/9 từ macro | Sai lệch ≤ ±5% (AC5) |
| TC-3-12 | 3.3 | P0 | Mở "Cách chúng mình tính" | Bảng: gram × giá trị/100 g = protein, kcal, tinh bột, béo cho từng nguyên liệu (AC1) |
| TC-3-13 | 3.3 | P0 | Cộng tổng bảng và so với chip macro | Tổng khớp chip macro (cùng hàm tính) |
| TC-3-14 | 3.3 | P0 | Đọc nguồn từng dòng | Mỗi dòng ghi "Bảng TPDD VN 2007 · mã …" hoặc "USDA FDC #…" (AC2, NFR-01) |
| TC-3-15 | 3.1 | P0 | Mở một bữa trưa có cơm trên tab Kế hoạch, với `rice_habit` = `nhieu` | Dòng cơm hiện đúng gram của mức (300 g của người dùng chính, khớp `rice.actual_g`). Khi `notes` có `rice_reduced`, hiện câu "Bữa này cơm còn khoảng … g (bạn chọn … g) để vẫn đủ đạm trong mức … kcal của bạn." với số đúng (T-095) |
| TC-3-16 | 3.1 | P0 | Mở một bữa trưa có cơm trên tab Kế hoạch. Với `rice_habit` = `vua`, sau đó với `it` | Dòng cơm hiện "1 chén cơm (~150 g)" (với `it`: "½ chén cơm (~75 g)"). Khi engine giảm cơm (`rice_reduced`), hiện "Bữa này bớt còn 1 chén cơm để giữ đúng calo." (chuỗi `meal.rice_reduced_cups`, số chén làm tròn về ½ chén). Đây là chuỗi nằm trên màn mâm, không đổi số gram trong dữ liệu |

---

## Epic 4 — Tab Đi chợ (US-4.1)

| ID | US | P | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-4-01 | 4.1 | P0 | Mở tab Đi chợ với tuần đã tạo | Nhóm theo quầy: Thịt · Cá & hải sản · Trứng & đậu phụ · Rau củ · Trái cây · Gạo & đồ khô · Gia vị & dầu · Sữa (AC1) |
| TC-4-02 | 4.1 | P0 | Đối chiếu gram cần với số gói | Ví dụ 410 g ức gà → 1 khay 500 g; phần dư hiển thị (AC2) |
| TC-4-03 | 4.1 | P0 | Xem hai con số chi phí | "Chi phí món ăn tuần này" và "Ước tính trả tại quầy" đều có. Trạng thái ngân sách so theo chi phí món ăn: "Chi phí món ăn tuần này nằm trong ngân sách (dư X ₫)" hoặc "…vượt ngân sách". Nếu tiền tại quầy vượt ngân sách, hiện thêm dòng thông tin trung tính ("Lần đi chợ này ước tính Y ₫, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau"), không cảnh báo đỏ. Nhãn "ước tính" và ngày khảo sát ở mọi nơi có giá (US-4.1 AC3, D-QA-02) |
| TC-4-04 | 4.1 | P0 | Đánh dấu "đã mua" một mục; đánh dấu "nhà có sẵn" cho gia vị | Trạng thái lưu; tắt app mở lại vẫn giữ (AC4) |
| TC-4-05 | 4.1 | P0 | Bấm "Chia sẻ danh sách" | Mở share sheet với văn bản danh sách; trên web thì chép vào bộ nhớ tạm (AC5) |
| TC-4-06 | 4.1 | P0 | Đổi số người ăn từ 1 sang 3 | Gram và chi phí tăng tương ứng; trẻ 0,6 suất |
| TC-4-07 | 4.1 | P0 | Với cửa hàng thiếu giá nguyên liệu | Engine dùng giá "Chợ / nơi khác" (fallback); không có ô trống (ENG-09) |

---

## Epic 5 — Thay đổi tuần (P1)

| ID | US | P | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-5-01 | 5.1 | P1 | Bấm "Đổi món này" ở bữa trưa thứ Ba | Gợi ý 2–3 món cùng loại bữa; mỗi món ghi chênh lệch protein, kcal, chi phí (AC1) |
| TC-5-02 | 5.1 | P1 | Chọn một món gợi ý | Validator chạy lại; ngày vẫn đạt; danh sách đi chợ cập nhật (AC2) |
| TC-5-03 | 5.1 | P1 | Đổi món ở ngày đã sát ngưỡng, không có món nào giữ ngày đạt | Nói rõ "không có món giữ ngày đạt", cho chọn món "gần đạt nhất" kèm cảnh báo (AC1) |
| TC-5-04 | 5.2 | P1 | Bấm "Đổi nguyên liệu" ở ức gà | Chỉ hiện nguyên liệu cùng `swap_group`; không có nguyên liệu bị loại (AC1) |
| TC-5-05 | 5.2 | P1 | Đổi ức gà sang đùi gà | Gram tính lại; protein bữa trong ±5% so với trước (AC2) |
| TC-5-06 | 5.3 | P1 | Đánh dấu "Ăn ngoài" bữa trưa thứ Năm | Bữa trưa ghi "Ăn ngoài"; các bữa khác giữ nguyên (AC1) |
| TC-5-07 | 5.3 | P1 | Xem ngày thứ Năm sau khi đánh dấu | Ngày không bị tính "không đạt"; hiển thị "có bữa ngoài" (AC2) |
| TC-5-08 | 5.3 | P1 | Đánh dấu ăn ngoài rồi xem danh sách đi chợ | Nguyên liệu của bữa đó được rút khỏi danh sách nếu chưa đánh dấu đã mua (AC3) |
| TC-5-09 | 5.3 | P1 | Bấm "Hoàn tác" sau khi đánh dấu ăn ngoài | Bữa trở về trạng thái cũ; danh sách đi chợ phục hồi (AC4) |
| TC-5-10 | 5.4 | P1 | Bấm "Không hợp với tôi" ở một món | Món không xuất hiện trong các tuần sau (AC1) |
| TC-5-11 | 5.4 | P1 | Ở tab Bạn, bỏ chặn món đó | Món trở lại danh sách hợp lệ (AC2) |
| TC-5-12 | 5.5 | P1 | Hôm nay là thứ Tư; bấm "Lên lại phần còn lại" | Các ngày đã qua và hôm nay giữ nguyên; các ngày sau được tạo lại (AC1) |
| TC-5-13 | 5.5 | P1 | Sau khi lên lại | Banner "Đã lên lại tuần" và kết quả validator hiển thị; tuần cũ có trong "Tuần đã lưu" (AC2, AC3) |
| TC-5-14 | 5.5 | P1 | Sang Chủ nhật, mở app | Tuần cũ hết hạn; có nút "Tạo tuần tới" (T-026) |

## Epic 6 — Tab Bạn (P1)

| ID | US | P | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-6-01 | 6.1 | P1 | Sửa chỉ tiêu ở tab Bạn | Thay đổi áp dụng cho tuần tạo kế tiếp; có nút "Lên lại tuần này với lựa chọn mới" |
| TC-6-02 | 6.1 | P1 | Sửa một lựa chọn kiêng | Tuần hiện tại không đổi cho đến khi người dùng bấm lên lại |
| TC-6-03 | 6.2 | P1 | Mở danh sách món đã chặn | Hiển thị đúng món đã chặn; có nút bỏ chặn |
| TC-6-04 | 6.3 | P1 | Mở "Miễn trừ y tế" và "Nguồn dữ liệu" | Có đủ văn bản (xem `docs/research/legal-notes.md`); đọc được trong ≤ 1 phút |
| TC-6-05 | 6.3 | P1 | Bấm "Xóa toàn bộ dữ liệu" | Có xác nhận 2 bước; sau khi xóa, app trở về onboarding; không còn tuần đã lưu |

---

## Ca biên và ca phi chức năng (P0 nếu ghi chú)

| ID | P | Tình huống | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| TC-E-01 | P0 | Nhập ngoài khoảng (đã có TC-1-03/04) | Nhập số ngoài biên | Báo lỗi, chặn đi tiếp |
| TC-E-02 | P0 | Tắt hết bữa chính | Tắt cả sáng, trưa và tối | Chặn (app khóa, API 400); còn ≥ 1 bữa chính (TC-1-17) |
| TC-E-03 | P0 | Loại hết nguồn đạm | Chọn kiêng thịt, cá, trứng, đậu phụ cùng lúc | Thông báo không đủ món; không crash; tuần `partial` hoặc báo lỗi thân thiện |
| TC-E-04 | P0 | Mất mạng khi tạo tuần | Tắt mạng (Wi-Fi và dữ liệu) rồi bấm "Tạo thực đơn tuần" | Hiện "Chưa tạo được thực đơn" + thông báo "Không có mạng. Dữ liệu vẫn được giữ trên máy." + nút "Thử lại"; không crash; dữ liệu onboarding và tuần cũ trên máy giữ nguyên (D-QA-10, ADR-001). Sửa 2026-11-07 (T-057c), thay "tạo tuần vẫn chạy" |
| TC-E-11 | P0 | Xem tuần đã tạo khi mất mạng | Tạo tuần khi có mạng; tắt mạng; mở tab Kế hoạch, mở một bữa và một công thức, mở tab Đi chợ | Kế hoạch, mâm, công thức (kể cả "Cách chúng mình tính") và danh sách đi chợ hiển thị đầy đủ từ dữ liệu trên máy, không lỗi mạng (D-QA-10, ADR-001). Tab Bạn hiện chỉ tiêu đã lưu (L-13) |
| TC-E-12 | P0 | Thử lại khi có mạng trở lại | Từ TC-E-04 (màn lỗi), bật mạng, bấm "Thử lại" | Tuần được tạo; tab Kế hoạch hiện tuần mới (ngày đầu là ngày mai); không cần đóng và mở lại app (D-QA-10) |
| TC-E-05 | P0 | Tắt app giữa onboarding | Đóng app ở bước 5; mở lại | Tiếp tục đúng bước (TC-1-37) |
| TC-E-06 | P0 | Đổi múi giờ hoặc qua ngày sang tuần mới | Đổi giờ máy sang ngày Chủ nhật 23:59 rồi sang thứ Hai | Tuần mới theo giờ máy; tuần cũ chuyển sang "Tuần đã lưu" |
| TC-E-07 | P0 | Hiệu năng | Mở tab Kế hoạch | Mở ≤ 300 ms; tạo tuần ≤ 5 s (PRD 7) |
| TC-E-08 | P0 | Trợ năng | Kiểm vùng chạm và tương phản | Vùng chạm ≥ 44 pt; tương phản WCAG AA |
| TC-E-09 | P0 | Riêng tư khi dùng app (D-QA-11) | Quan sát mạng khi tạo tuần, đổi món, mở công thức; kiểm payload và cấu hình log API | (1) Mọi request chỉ đi tới host API đã cấu hình; không có domain khác (không analytics, không SDK báo lỗi). (2) Payload chỉ gồm dữ liệu cần để lập thực đơn (chỉ số cơ thể, mục tiêu, lựa chọn ăn uống) theo OpenAPI; không có tên, email hay mã định danh thiết bị. (3) Cấu hình log API không ghi body request. Ngoài phạm vi: log truy cập của hosting/proxy (IP, thời gian, đường dẫn) là điểm mở trước phát hành (legal-notes). Sửa 2026-11-07 (T-057c, D-QA-11), thay "không gửi dữ liệu ra ngoài máy" vì mâu thuẫn với ADR-001 (tạo tuần đi qua API) |
| TC-E-10 | P0 | Dữ liệu thiếu | Xóa một công thức trong bản seed và khởi động | Hệ thống báo lỗi dữ liệu rõ file + id (validate-data), không crash |

---

## Phạm vi và phần chưa có

- Không có ca cho paywall (P2), giao hàng, thông báo đẩy, đa ngôn ngữ, ghi nhật ký.
- Các ca phụ thuộc engine (TC-2-*) cần `npm run engine-report` của Dev để đo định lượng; ca thủ công chỉ kiểm thông số hiển thị.
- Ảnh món (Q5) chưa rõ: ca hiển thị ảnh dùng placeholder cho đến khi có quyết định.
