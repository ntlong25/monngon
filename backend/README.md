# backend/ — .NET 10 (engine C# + API)

| Dự án | Vai trò |
|---|---|
| `MonNgon.Engine` | Thư viện engine lập thực đơn (không phụ thuộc ASP.NET). Port 1-1 từ `src/engine/` (TS, đã đóng băng) |
| `MonNgon.Api` | Minimal API (`GET /health`, sau này `/v1/...`) |
| `MonNgon.Tools` | CLI: `validate-data [dir]`, (T-064) `engine-report` |
| `MonNgon.Engine.Tests`, `MonNgon.Api.Tests` | xUnit |

```
dotnet build backend/MonNgon.sln
dotnet test backend/MonNgon.sln
dotnet run --project backend/MonNgon.Api            # GET /health -> 200 (dữ liệu lỗi thì không khởi động)
dotnet run --project backend/MonNgon.Tools -- validate-data data
```
Thư mục dữ liệu: cấu hình `DataDir` (mặc định tìm `data/` ở thư mục cha gần nhất). `Nullable` và `TreatWarningsAsErrors` bật.

## API v1 (T-065)

Chạy: `dotnet run --project MonNgon.Api` (cấu hình `DataDir`, `ContentDir` nếu cần). JSON snake_case; lỗi đầu vào → 400 `application/problem+json` với `errors` theo đường dẫn trường (vd `profile.age`, `preferences.store_id`). CORS mở cho dev.

| Endpoint | Mô tả |
|---|---|
| `GET /v1/reference` | cửa hàng, dụng cụ, loại trừ/kiêng, thẻ vuốt, `data_version` |
| `GET /v1/ingredients?q=&limit=` | tìm nguyên liệu không dấu |
| `POST /v1/targets` | chỉ tiêu kcal/protein + các bước tính |
| `POST /v1/slots/preview` | phân bổ chỉ tiêu theo bữa |
| `POST /v1/budget-range` | khoảng ngân sách tuần gợi ý (3 mức) |
| `POST /v1/plans` | WeekPlan + trace "Cách chúng mình tính" (khớp golden) |
| `GET /v1/recipes/{id}` | công thức + macro khẩu phần chuẩn kèm nguồn |

Hợp đồng OpenAPI: `backend/openapi/openapi.json` (được `dotnet test` ghi lại mỗi lần chạy; cũng phục vụ tại `/openapi/v1.json`).

`POST /v1/plans` nhận thêm `meal_style` (`auto` mặc định | `full_meal_only` | `mam_only`) — xem `docs/dev/mam-notes.md`. Bữa trưa/tối trả `dishes[]`; golden/ khớp ở `full_meal_only`.

Bổ sung T-069/T-070/T-071: xem `docs/dev/api-notes.md` (`/v1/shopping-list`, `recipes`/`ingredients` trong `POST /v1/plans`, `targets` bắt buộc ở `/v1/budget-range`, `include_dessert`).

## Docker / triển khai (T-068)

```
docker compose up --build        # ở gốc repo -> http://localhost:5095/health
docker build -f backend/Dockerfile -t fitpro-api .   # build context là gốc repo (cần data/ và content/)
```
Image multi-stage (alpine, ~181 MB), chạy non-root, có HEALTHCHECK. `data/` và `content/` được mount vào compose nên cập nhật dữ liệu chỉ cần `docker compose restart api`. Biến môi trường, health check và quy trình cập nhật dữ liệu: `docs/dev/deploy.md`.

## `POST /v1/budget-range` (T-075)

`targets` bắt buộc. Hai dạng cấu hình: (1) `preferences` đầy đủ (khuyến nghị; lọc món theo kiêng/ghét/dụng cụ; `store_id`/`adults`/`children`/`slots` cấp ngoài bị bỏ qua) hoặc (2) không có `preferences`, gửi ít nhất một trong `store_id`, `adults`, `children`, `slots` (trường vắng dùng mặc định cho_khac / 1 / 0 / ăn sáng-trưa-tối). Không có nguồn nào → 400 (`errors.preferences`).
