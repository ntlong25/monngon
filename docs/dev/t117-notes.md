# T-117 — Làm nóng engine khi khởi động API

Ngày đo: 2026-11-16 · máy dev 12 lõi logic · .NET 10 Release (`dotnet publish -c Release`, chạy `dotnet MonNgon.Api.dll`) · hồ sơ p01 (nữ giảm mỡ, ngân sách vừa), `POST /v1/plans`, một tiến trình mới cho mỗi dòng.

## Cách làm

- `backend/MonNgon.Api/WarmUp.cs`: `WarmUpService` (BackgroundService) lập 4 tuần mẫu (hồ sơ nặng giống p01, mỗi mức cơm `rat_nhieu, nhieu, vua, it` một tuần) và tuần tự hóa JSON kết quả, rồi bỏ kết quả. `Readiness` giữ cờ sẵn sàng.
- `GET /health` (liveness) vẫn `200` ngay. `GET /health/ready` trả `503 {"status":"warming_up"}` tới khi làm nóng xong, sau đó `200 {"status":"ready","warm_up_seconds":…,"warm_up_plans":4,"warm_up_error":null}`. Làm nóng lỗi thì vẫn báo sẵn sàng (API dùng được) và ghi `warm_up_error`.
- Cấu hình: `WarmUp__Enabled` (mặc định `true`), `WarmUp__Levels` (mặc định cả 4 mức). Bộ test Api tắt làm nóng cho cả assembly (module initializer) để khỏi tranh CPU; `WarmUpTests` bật riêng.
- `Dockerfile`: `HEALTHCHECK` gọi `/health/ready`, `start-period` 60 s (chưa chạy thử Docker).
- Engine không đổi: làm nóng chỉ gọi `WeekPlanner.Plan` như yêu cầu thường.

## Số đo

| | Không làm nóng (bản trước) | Có làm nóng |
|---|---|---|
| Thời gian khởi động thêm (đến `ready`) | 0 | **2,5 s thực** (`warm_up_seconds` 2,46) · CPU lúc sẵn sàng 7,1 s (so 0,3 s) |
| Tuần đầu, p01 `rat_nhieu` | **1,67 s thực · 4,42 s CPU** | **0,78 s thực · 2,34 s CPU** |
| Tuần thứ hai, p01 `rat_nhieu` | 1,28 s · 4,34 s CPU | 0,58 s · 1,88 s CPU |
| Tuần thứ ba, p01 `nhieu` | 1,11 s · 2,14 s CPU | 0,38 s · 0,86 s CPU |
| Băm JSON phản hồi (p01 `rat_nhieu` / `nhieu`) | `939931ff98910091` / `a187531702ced777` | **giống hệt** |

- Kế hoạch đầu tiên không còn "lạnh" như ghi ở T-105 (~12 s CPU là số của bench nhiều ô trong một tiến trình, không phải một yêu cầu API). Ở API thật, chênh lệch lớn nhất nằm ở JIT phân tầng: không làm nóng thì các yêu cầu đầu chạy mã chưa tối ưu (CPU ~4,3 s mỗi tuần `rat_nhieu`), làm nóng xong thì ~1,9–2,3 s.
- Cần lưu ý cho T-105 AC4: CPU **tiến trình API** đo ở đây (2,3 s tuần đầu, 1,9 s tuần sau) còn lớn hơn số CPU "luồng lập tuần" của bench ở p01 (1,7–2,7 s); tiến trình tính cả GC và luồng nền. Cổng phát hành 2 vCPU nên đo lại bằng chính API này.
- Tất định: băm giống bản không làm nóng; test `WarmUpTests` kiểm cùng yêu cầu trước/sau làm nóng ra cùng byte.
