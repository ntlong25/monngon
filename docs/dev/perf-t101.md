# T-101 — Hiệu năng lập tuần ở mức cơm cao

Ngày đo: 2026-11-09 · máy dev 12 lõi logic (6 lõi vật lý) · .NET 10 Release · 18 hồ sơ × 4 mức cơm × 3 seed = 216 lần lập, mỗi lần gọi `WeekPlanner.Plan` (như `POST /v1/plans`).

Chạy lại: `dotnet build backend/MonNgon.Tools -c Release` rồi
`dotnet backend/MonNgon.Tools/bin/Release/net10.0/MonNgon.Tools.dll bench --data data --seeds 1,2,3 [--rows] [--hash] [--edits] [--only p14] [--levels nhieu,rat_nhieu] [--attempt n --lift false]`
(`--hash` in SHA-256 rút gọn của JSON tuần từng ô để so hai bản; `--edits` đo thêm gợi ý/đổi món/lên lại 6 và 3 ngày; `--attempt n --lift false` chạy đúng một phương án tuần tự để đo chi phí).

## Kết quả (ms mỗi lần lập, phía server)

| Mức | Trước p50 | Trước p95 | Trước max | **Sau p50** | **Sau p95** | **Sau max** | CPU max trước → sau |
|---|---|---|---|---|---|---|---|
| ít | 23 | 147 | 198 | 18 | 105 | 136 | 0,2 s → 0,1 s |
| vừa | 25 | 266 | 346 | 17 | 137 | 164 | 0,4 s → 0,2 s |
| nhiều (2 chén) | 223 | 5.614 | 6.362 | 130 | 1.115 | 1.318 | 17,5 s → 6,3 s |
| rất nhiều (3+ chén) | 1.735 | 13.020 | 13.871 | 417 | 1.752 | 1.812 | 41,3 s → 7,1 s |
| **tất cả (216)** | 119 | **7.265** | **13.871** | 92 | **1.318** | **1.812** | 41,3 s → 7,1 s |

"Trước" = HEAD của nhánh `t-099-the-tinh-bot` + dữ liệu 18 hồ sơ (cùng máy, cùng ma trận). Số đo dao động ±15% giữa các lần chạy (các phiên khác dùng chung máy).

Chỉnh tuần sau T-101 (216 ô, mỗi thao tác tính riêng): gợi ý đổi món p95 20 ms · đổi món p95 10 ms · **lên lại phần còn lại 6 ngày p95 1.155 ms (max 1.659)** · 3 ngày p95 532 ms (max 912). Trước (3 ô p01, mức vừa/nhiều/rất nhiều): lên lại 6 ngày 359 → 4.284 → 8.649 ms.

### Đối chiếu AC

| AC | Kết quả |
|---|---|
| 1. p95 ≤ 1 s, max ≤ 3 s | **max 1,8 s đạt; p95 1,3 s chưa đạt** (từ 7,3 s). Nhiều: p95 1,1 s; rất nhiều: p95 1,75 s |
| 2. đổi món / lên lại p95 ≤ 1 s | đổi món/gợi ý đạt (≤ 20 ms); **lên lại 6 ngày p95 1,16 s chưa đạt** (từ 8,6 s) |
| 3. app ≤ 5 s trên emulator, không đổi timeout 30 s | **đạt**: `qa_flow_test` it-10 trên Pixel_7 (API Release cùng máy dev, hồ sơ test của it-10, 4 mức) đo từ lúc đổi mức đến lúc tuần mới hiện: ít 1,7 s · vừa 1,4 s · nhiều 1,6 s · rất nhiều **2,0 s**; test khẳng định < 5 s. Timeout Dio 30 s giữ nguyên |
| 4. giữ AC T-094/096/098, golden | **kết quả từng tuần giống hệt bản trước** (băm JSON 216/216 ô trùng) nên mọi AC giữ nguyên; golden khớp (xem dưới) |
| 5. test chặn hồi quy | `PerformanceTests` (xem dưới) |

p95 chưa đạt vì phần còn lại là chi phí thật của thuật toán ở các ô khó (p01, p02, p09, p14 ở 2–3+ chén): phương án 1–6 chạy hết 12 vòng rồi thất bại, phương án 7 hoặc mức dưới thắng; thời gian chờ = phương án thất bại chậm nhất (~0,9 s CPU, chạy song song 14 luồng trên 6 lõi vật lý). Cắt thêm cần đổi kết quả (xem "Đã thử nhưng bỏ" bên dưới) nên để PM quyết định.

## Đã làm (đều giữ nguyên kết quả: băm JSON 216 ô trùng bản trước)

1. **Scaler (`Scale.cs`)**: trước đây mỗi lần `Scaler.Scale` dựng lại danh sách ứng viên (~800 vector gram) cho nhóm đạm/carb và tính lại dinh dưỡng — chiếm ~80% thời gian lập ở 3+ chén (hàng triệu lần gọi/tuần). Nay dựng một lần mỗi (công thức, ép 0 carb, bước) dưới dạng mảng song song (kcal, đạm, khoảng cách, vector gram) và dùng chung giữa 7 phương án + mức dưới (khoá theo nội dung công thức, trần 4.000 mục, xoá hết khi vượt). Vòng tìm vét cạn chỉ còn phép cộng/so sánh trên mảng, cùng thứ tự cộng nên chọn đúng cùng nghiệm.
2. **`UsedCost`** (vòng sửa ngân sách gọi hàng nghìn lần): tính chi phí theo gram dùng trực tiếp (cùng thứ tự cộng như `ShoppingOf`) thay vì dựng cả danh sách đi chợ (sắp xếp ViCollator, regex hiển thị).
3. **`RepairDesserts`**: nhớ kết quả thử mỗi (ngày, bữa, tráng miệng thay thế); chỉ xoá của ngày vừa đổi, nên mỗi vòng không thử lại hàng trăm phương án của các ngày không đổi.
4. **`PolishDay`**: ứng viên tốt nhất lưu dạng giá trị thay vì closure + mảng mới mỗi ứng viên (−40% thời gian polish, cùng thứ tự duyệt).
5. **Tinh chỉnh theo ngày song song** (`Parallel.ForEach` trên 7 ngày): các ngày độc lập (chỉ đọc dữ liệu chung, chỉ ghi vào bữa của ngày mình). `RiceOnlyAttempt` (chẩn đoán/test) chạy tuần tự trên luồng gọi.

## Đã thử nhưng bỏ

- **Bỏ bước cứu ngày bằng đổi tráng miệng khi ngày lệch nặng** (`DessertRescueMaxBad` 60/100/150): giảm p95 xuống ~0,95 s và max xuống ~1,5 s nhưng **đổi kết quả** — p01 mức 3+ chén đạt 7/7 ngay ở phương án 1 với chỉ 8/14 bữa trưa/tối có cơm (trước: phương án 4, đủ cơm), làm hỏng Rice98 AC1/AC2 (D-COM-05). Đã gỡ khỏi code.
- Cấu hình GC (server/concurrent/tiered PGO): trong dao động đo, không đổi p95.
- Tìm lặp lại ngày giống hệt giữa các vòng để dùng lại: chỉ ~13% ngày lặp, không đáng.

## Test chặn hồi quy (`MonNgon.Engine.Tests/PerformanceTests.cs`, chạy trong check-tests)

- **Ngân sách công việc (không phụ thuộc máy)**: số byte cấp phát trên luồng gọi của MỘT phương án (`RiceOnlyAttempt`, tuần tự): p01 3+ chén phương án 1 đo ~0,85 GB → ngưỡng 1,7 GB; p02 3+ chén phương án 7 đo ~62 MB → ngưỡng 130 MB (gấp đôi). Quay lại dựng ứng viên scale mỗi lần gọi hoặc thử cứu ngày vô ích sẽ vượt ngưỡng ngay cả trên máy nhanh.
- **Thời gian thật** (4 ca nặng nhất: p01/p02/p14 3+ chén, p09 2 chén; cả lần lập như `POST /v1/plans`, bản Debug trên máy CI): ngưỡng **25 s** (đo 3–6 s trên máy dev, Release ~1–2 s) — nới ~4–8 lần cho máy CI ít lõi, vẫn thấp hơn timeout 30 s của app; chỉ bắt lỗi nặng (trước T-101: 12–17 s ở Release).

## Ghi chú khác

- Sửa test cho 18 hồ sơ (p17/p18 do T-057d): `RiceTests` mức Vừa ép mọi hồ sơ về `vua` (p18 mặc định `nhieu`), đếm hồ sơ/ô theo `Profiles.Count`.
- Golden: chạy lại `npm run export-golden` (dữ liệu đổi → hash phiên bản đổi, thêm 6 case p17/p18). Với hộ có trẻ em, tiền dùng (`used_cost_vnd`) chênh nhiễu 2e-12 giữa TS và C# (thứ tự cộng số thực) → so sánh tiền dùng dung sai 1e-6 ₫ thay vì 0.
- `backend/test-baseline.json`: Engine 236 (trước 224: +6 case golden p17/p18, +6 test hiệu năng (2 ngân sách công việc + 4 thời gian)).

## Cập nhật 2026-11-10 — sau sửa ngân sách (T-104) và ngưỡng mới của PM (D-PERF-01)

Sau khi mở rộng bước sửa ngân sách (xem `price-d2-t104.md`) thời gian tăng (p95 ~1,7 s, max ~2,4 s) và CPU mỗi lần lập là 5–11 s. Đã làm thêm, **đều giữ nguyên kết quả** (băm JSON 216 ô trùng bản trước các thay đổi này; kiểm tất định bên dưới):

- `RepairBudget` nhớ (co giãn + tiết kiệm) từng phương án thay thế giữa các vòng.
- `PlanOptions.MaxParallelAttempts = 2`: phương án xếp hạng cơm chạy theo thứ tự ưu tiên, tối đa 2 phương án cùng lúc (chọn kết quả vẫn theo thứ tự ưu tiên nên không đổi); phương án đứng trước thắng thì các phương án chưa bắt đầu không bao giờ chạy. Đo thử: =1 cho CPU thấp nhất nhưng thời gian thực mức rất nhiều p95 2,38 s (✗ > 2 s); =2 thời gian thực p95 1,89 s (✓); =3 không tốt hơn (p95 1,94 s, CPU cao hơn).
- `PlanOptions.SkipRankedOverBudgetRatio = 0` (tắt). Quy tắc "phương án xếp hạng 1–6 vượt ngân sách > 3% thì bỏ qua các phương án sau" giảm CPU nhiều nhưng ĐỔI kết quả 4 ô → chuyển sang T-105; mã vẫn còn, bật bằng tuỳ chọn.
- `RescueDayWithDessert` thoát sớm khi đã đạt tối ưu (không đổi kết quả, hiệu quả không đáng kể).
- Đã thử, bỏ: dừng sớm khi nhiều vòng liền không cải thiện (CPU −8%, đổi 3 ô); bỏ hẳn phương án 2/5/6 (không bao giờ thắng trong 216 ô nhưng CPU không giảm đáng kể); giới hạn số ngày song song (không giảm CPU đáng kể).
- Đo cấu hình (một phương án nặng nhất): chọn món 140–280 ms, các ngày 540–1600 ms (`RescueDayWithDessert` chiếm 460–1270 ms: ~12 nghìn lần thử, mỗi lần ~35 ms gồm co giãn + RefineDay + PolishDay), sửa ngân sách trong vòng 250–650 ms, bước 4 140–850 ms. Mỗi lần `Scale` chỉ ~5 µs nên đòn bẩy là số lần thử. Có 23–35% lời gọi `RescueDayWithDessert` lặp đúng trạng thái ngày → nhớ kết quả có thể tiết kiệm 25–35% nhưng phải có khoá ngữ cảnh chính xác (rủi ro đổi kết quả), không đủ để từ 5 s xuống 2 s; chưa làm.

Kết quả (216 ô, `bench --rows --hash`, cấu hình mặc định cuối: song song 2, không bỏ phương án):

| Mức | p50 | **p95** | **max** | CPU p95 | CPU max |
|---|---|---|---|---|---|
| ít | 16 ms | 65 ms | 72 ms | 125 ms | 203 ms |
| vừa | 14 ms | 86 ms | 162 ms | 94 ms | 141 ms |
| nhiều (2 chén) | 75 ms | **1,24 s** | 1,88 s | 2,7 s | 5,2 s |
| rất nhiều (3+ chén) | 153 ms | **1,89 s** | 1,98 s | **5,2 s** | 5,5 s |
| **tất cả** | 42 ms | 1,28 s | 1,98 s | 3,5 s | 5,5 s |

(Băm JSON 216 ô trùng bản chuẩn "không bỏ phương án", song song 1/2/3 đều 0 ô khác.)

### Đối chiếu ngưỡng PM (D-PERF-01)

| Điều kiện | Ngưỡng | Đo | |
|---|---|---|---|
| Ít/vừa p95 | ≤ 1 s | 0,07 / 0,09 s | ✓ |
| Nhiều p95 · max | ≤ 2 s · ≤ 3 s | 1,24 s · 1,88 s | ✓ |
| Rất nhiều p95 · max | ≤ 2 s · ≤ 3 s | 1,89 s · 1,98 s | ✓ |
| CPU mỗi lần lập p95 (từng mức) | ≤ 2 s | nhiều **2,7 s**, rất nhiều **5,2 s** | ✗ |

Chỉ còn điều kiện CPU từng mức chưa đạt; mọi cách giữ nguyên kết quả đã dùng hết. Muốn xuống ≤ 2 s cần cách ĐỔI kết quả (bỏ phương án sau khi vượt ngân sách > 3%: CPU p95 rất nhiều 3,7 s ở mức này vẫn chưa đủ) hoặc đổi thuật toán (T-105).

Chạy lại: `bench ... --cpu-p95-ms 2000 --p95-ms ... --max-ms ...` (mã thoát 1 nếu vượt). Kiểm tất định: `MonNgon.Tools determinism [--repeat 20]` (xem dưới).

### Kiểm tính tất định (PM)

`MonNgon.Tools determinism --repeat 20`: mỗi ô (18 hồ sơ × 4 mức × 3 seed = 216) lập 20 lần liên tiếp (phương án/ngày vẫn chạy song song như thật), so băm SHA-256 JSON của tuần. Kết quả: **216/216 ô giống nhau 20/20 lần** (cả trước và sau khi thêm giới hạn song song/bỏ qua phương án). Lần chạy chẩn đoán "640k/12 cơm" ghi trong `price-d2-t104.md` không tái hiện được; vì 216 ô × 20 lần đều tất định nên nguyên nhân không phải thứ tự luồng (nhiều khả năng do tổ hợp tuỳ chọn độ rộng sửa ngân sách đặt tay lúc chẩn đoán, chưa xác minh).
