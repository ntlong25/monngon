# T-105 — CPU mỗi lần lập tuần (mức nhiều / rất nhiều)

Ngày đo: 2026-11-16 · máy dev 12 lõi logic (6 lõi vật lý) · .NET 10 Release · 18 hồ sơ × 4 mức cơm × 3 seed = 216 lần lập, mỗi lần gọi `WeekPlanner.Plan` (như `POST /v1/plans`). Số đo dao động ±10–15% giữa các lần chạy (máy dùng chung với các phiên khác).

Chạy lại: `dotnet build backend/MonNgon.Tools -c Release -o <thư mục>` rồi
`dotnet <thư mục>/MonNgon.Tools.dll bench --data data --seeds 1,2,3 [--rows --hash] [--levels nhieu,rat_nhieu] [--par n] [--drt n] [--rda n]`.
Số lõi giả lập: biến môi trường `DOTNET_PROCESSOR_COUNT=2|4`. Tất định: `... determinism --data data --repeat 20`.
(Đo trong thư mục riêng, không đo trong `bin/` của dự án khi có API đang chạy.)

## Kết quả (bản cuối, ms)

| Mức | Thời gian thực p95 | max | **CPU p95** | CPU max | CPU p95 trước (T-101) |
|---|---|---|---|---|---|
| ít | 38 | 58 | **78** | 78 | 125 |
| vừa | 44 | 81 | **31** | 94 | 78 |
| nhiều | 752 | 1.221 | **922** | 2.453 | 2.047 |
| rất nhiều | 883 | 920 | **1.844** | 2.734 | 5.047 |
| **tất cả (216)** | 654 | 1.221 | **1.234** | 2.734 | — |

CPU p95 mức rất nhiều qua 5 lần đo liên tiếp: 1,69 · 1,81 · 1,84 · 1,88 · 2,08 s (nhiễu do máy dùng chung; 4 trên 5 lần ≤ 2 s). Trên máy ít lõi (`DOTNET_PROCESSOR_COUNT`, bản `RepairDessertAlts = 3` đo trước khi chốt 2): 4 lõi logic CPU p95 1,56 s, 2 lõi logic 1,69 s ở mức rất nhiều; nhiều 0,84 / 0,92 s.

### Đối chiếu AC

| AC | Kết quả |
|---|---|
| 1. CPU p95 ≤ 2 s ở mọi mức | **đạt**: ít 0,08 · vừa 0,03 · nhiều 0,92 · rất nhiều 1,84 s. Còn ô lẻ vượt 2 s (max 2,7 s: p01/p14 mức rất nhiều, p01 mức nhiều) nhưng p95 của cả 54 ô mỗi mức dưới 2 s. Biên mức rất nhiều mỏng (1,7–2,1 s giữa các lần đo) |
| 2. thời gian thực không lùi; tất định 100% | thực p95 nhiều 0,75 s / rất nhiều 0,88 s (trước 1,1 / 1,75 s); ít/vừa ≤ 0,05 s. **Tất định 216 ô × 20 lần: 0 ô khác** |
| 3. AC sản phẩm T-094/096/098 giữ nguyên | `check-tests`: Engine 248/248 (gồm Rice98Tests, BudgetTests, golden), Api 49/49; `engine-report`: 18/18 hồ sơ đạt 7/7, 126/126 ngày, vi phạm cứng 0, hồ sơ > 20% bữa giảm cơm: không, dưới sàn/không ghi chú: 0. 216/216 ô vẫn "ready" |
| 4. đo trên cấu hình máy chủ dự kiến | **chưa có cấu hình máy chủ chốt** — đã đo 12, 4 và 2 lõi logic (xem trên). Cần PM/hạ tầng cho số lõi thật trước phát hành |
| 4b. app tổng p95 ≤ 5 s ở mọi mức | server p95 ≤ 0,9 s nên đệm lớn; **chưa đo lại trên emulator** (đo T-101: ≤ 2,0 s tổng) |

## Đã làm

Nguồn CPU (đo bằng bộ đếm thời gian tạm, 12 lõi, hồ sơ p01 mức rất nhiều): bước cứu ngày bằng đổi tráng miệng (`RescueDayWithDessert`) ≈ 50% — ~36 lần thử mỗi ngày (mỗi lần = clone ngày + `RefineDay` + `PolishDay`) nhưng chỉ ~0,5% lời gọi đưa được ngày về đạt, và phương án tốt nhất hầu như luôn thuộc 3 ứng viên đầu theo dự đoán; sửa ngân sách (`RepairDesserts` + `RepairBudget`) ≈ 30%.

**Không đổi kết quả** (băm JSON từng ô trùng bản trước):
1. `RescueDayWithDessert`: thoát khỏi cả hai vòng khi ngày đã đạt (trước đây chỉ thoát vòng trong).
2. `RepairBudget`: ứng viên của từng bữa xếp sẵn theo giá một lần (`SortedByCost`; `OrderBy` ổn định nên lọc-rồi-lấy-N cho cùng thứ tự với lọc-rồi-sắp-xếp) thay vì lọc + sắp xếp lại mỗi bữa mỗi vòng (−17% CPU mức rất nhiều); danh sách phương án đổi nguyên liệu lưu theo bữa (`subAltCache`), khóa chuỗi chỉ dựng khi cần.
3. `MaxParallelAttempts` mặc định 2 → **1**: phương án xếp hạng chạy lần lượt (tuần mức dưới vẫn chạy song song). CPU −20% ở mức rất nhiều; thời gian thực vẫn dưới 1 s nhờ các bước trên.

**Đổi kết quả (thuật toán):**
4. `PlanOptions.DessertRescueTrials = 3`: khi cứu ngày bằng tráng miệng chỉ thử 3 ứng viên (bữa, món thay) có vi phạm dự đoán thấp nhất (đạm/kcal ngày sau khi đổi, chưa chỉnh lại; ổn định theo thứ tự cũ khi bằng nhau). Chỉ áp dụng khi có > 3 ứng viên.
5. `PlanOptions.RepairDessertAlts = 2`: `RepairDesserts` chỉ thử đổi sang 2 tráng miệng rẻ hơn rẻ nhất của mỗi bữa (mục tiêu là giảm chi phí).

Hai thay đổi 4–5 làm **62/216 ô đổi kết quả** (it 6, vừa 12, nhiều 23, rất nhiều 21; hồ sơ p01, p02, p03, p06, p08, p09, p12, p13, p15, p16) — đổi chủ yếu là chọn món tráng miệng khác nên khác băm, không phải ô mất 7/7. Trạng thái 216/216 vẫn "ready". Đổi phương án thắng ở 5 ô: p01 nhiều seed 2 (phương án 3 → tuần mức vừa nâng lên), p01 rất nhiều seed 3 (1 → 2), p02 rất nhiều seed 3 (3 → 6), p16 rất nhiều seed 2 và 3 (3 → tuần mức dưới); các ô này đều qua các AC D-COM-05 (test Rice98).
Golden (`full_meal_only`, parity TS): các ca không đổi (test golden đạt); chỉ `manifest.json` / `README.md` đổi phiên bản dữ liệu do thêm `data/storage.json` (T-112).

## Đã thử nhưng bỏ / không đủ

- `SkipRankedOverBudgetRatio = 0,03` (bỏ phương án xếp hạng sau khi một phương án vượt ngân sách > 3%): đổi 4 ô, giảm CPU ít; vẫn tắt.
- Bỏ tuần mức dưới (`--lift false`): CPU mức rất nhiều −40% nhưng 10 ô mất lift (vi phạm D-COM-05 AC1) → không.
- Lập tuần mức dưới lười (chỉ khi cần): các ô nặng là ô tuần mức này bị giảm cơm (tổng cơm < mức dưới) nên đúng là cần tuần mức dưới; không có cận trên đủ chặt để bỏ qua an toàn.
- `DessertRescueTrials` 2 / 3 / 4 / 6 / 8: 3 là điểm hòa vốn (2 đổi thêm ô, 6–8 giảm CPU kém đi).
- `RepairDessertAlts` 4 / 3 / 2: p95 rất nhiều 1,98 / 1,69–2,08 / 1,81 s; chọn 2 để có biên.
- Giới hạn spin của thread pool (`DOTNET_ThreadPool_UnfairSemaphoreSpinLimit=0`): không đổi CPU đáng kể.

## Việc còn lại / rủi ro

- Biên CPU p95 mức rất nhiều còn mỏng (1,7–2,1 s). Muốn dư hơn cần cắt tiếp chi phí lặp trong `RescueDayWithFullMeal`/chọn ứng viên (`select`) hoặc đổi cấu trúc phương án (nhiều phương án thất bại chạy đủ 12 vòng ở p01/p02/p14).
- Cấu hình máy chủ dự kiến (số lõi thật) chưa chốt; lần đầu mỗi tiến trình chậm hơn (nạp bộ nhớ đệm của `Scaler`: ~12 s CPU cho kế hoạch đầu tiên của hồ sơ nặng ở tiến trình lạnh) — cân nhắc "làm nóng" khi khởi động API.
- Kiểm thời gian thực/CPU trong CI: `PerformanceTests` (T-101) giữ nguyên; `bench --cpu-p95-ms 2000` dùng để chặn CPU khi chạy tay.
- `python backend/check-tests.py` cần `backend/MonNgon.Api/bin/Debug` không bị khóa: khi API (cổng 5097) đang chạy từ thư mục đó thì `dotnet test MonNgon.Api.Tests` mặc định thất bại vì không ghi đè được `MonNgon.Engine.dll`; chạy `-c Dev` thì đạt. `test-baseline.json` Engine 242 → 248 (6 test `storage` của T-112).

## Đề xuất (chưa làm, chờ PM trả lời — theo yêu cầu của hub)

Mục tiêu: tăng biên CPU p95 mức rất nhiều (hiện 1,7–2,1 s) mà **giữ nguyên kết quả** (băm từng ô trùng bản hiện tại).
1. **Làm nóng khi khởi động API:** lập một tuần nhỏ (mức vừa) lúc khởi động để nạp bộ nhớ đệm của `Scaler` và JIT; không đổi kết quả, giảm kế hoạch đầu tiên của tiến trình lạnh (~12 s CPU với hồ sơ nặng).
2. **Cache đầu ra `RefineDay`/`PolishDay` theo khóa (bữa, ngày, phương án)** trong `RescueDayWithFullMeal`/`select`: các ứng viên lặp lại giữa các vòng; chỉ là memo nên kết quả giữ nguyên. Cần đo trước (chưa có số).
3. **Dùng lại kết quả tuần mức dưới** khi cả hai mức cùng sinh một chuỗi phương án đầu (nhieu/rat_nhieu): tránh chạy hai lần các bước chung. Cần chứng minh tính tất định bằng băm 216 ô.
Cả ba chưa đo; mục 2–3 cần một vòng đo CPU trước khi hứa số.
