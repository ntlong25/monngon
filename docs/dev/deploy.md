# Chạy và triển khai API (T-068)

API là một ứng dụng ASP.NET (.NET 10) không trạng thái: không có cơ sở dữ liệu, mọi dữ liệu (công thức, nguyên liệu, giá, cửa hàng) đọc từ thư mục `data/` lúc khởi động, nội dung (thẻ vuốt…) từ `content/`.

## 1. Chạy cục bộ

### Docker Compose (khuyến nghị)

Ở gốc repo:

```bash
docker compose up --build
```

- API ở `http://localhost:5095` (đổi cổng: `API_PORT=9000 docker compose up`).
- Kiểm tra: `curl http://localhost:5095/health` → `{"status":"ok"}`.
- Thử lập tuần: `POST http://localhost:5095/v1/plans` (xem `backend/README.md` và `backend/openapi/openapi.json`).
- Dừng: `docker compose down`.

Compose mount `./data` và `./content` (chỉ đọc) đè lên bản đã COPY trong image, nên sửa dữ liệu không cần build lại.

### Không dùng Docker

```bash
dotnet run --project backend/MonNgon.Api --urls http://0.0.0.0:5095
```

Tự tìm `data/` và `content/` ở thư mục cha gần nhất. Ứng dụng Android emulator dùng `http://10.0.2.2:5095` (mặc định của app).

## 2. Image

`backend/Dockerfile` (build context phải là **gốc repo**, vì cần `data/` và `content/`):

```bash
docker build -f backend/Dockerfile -t fitpro-api .
docker run --rm -p 5095:8080 fitpro-api
```

- Multi-stage: `sdk:10.0-alpine` build → `aspnet:10.0-alpine` runtime. Chỉ chứa API đã publish + `data/` + `content/`; không có test, công cụ, mã TS.
- Chạy bằng user không phải root (`app`, UID 1654), cổng 8080, hệ thống tập tin gốc để read-only trong compose.
- Dung lượng image: 181 MB (đo bằng `docker images`, mục tiêu < 250 MB).

## 3. Biến môi trường

| Biến | Mặc định trong image | Ý nghĩa |
|---|---|---|
| `DataDir` | `/app/data` | Thư mục có `recipes.json`, `ingredients.json`, `prices.json`, `stores.json`. Dữ liệu lỗi → API **không khởi động** (log nêu file/id/trường, thoát mã 1) |
| `ContentDir` | `/app/content` | Thư mục có `swipe-cards.json` (và `i18n/`) |
| `ASPNETCORE_HTTP_PORTS` | `8080` | Cổng lắng nghe trong container |
| `ASPNETCORE_ENVIRONMENT` | `Production` | `Development` bật log chi tiết hơn |
| `Logging__LogLevel__Default` | `Information` | Mức log (ASP.NET cho phép đặt mọi key cấu hình bằng `__`) |

API không cần khóa bí mật nào. CORS hiện mở cho mọi nguồn (chính sách "dev"); đặt sau reverse proxy và siết lại trước khi mở ra Internet, nếu có web client.

## 4. Health check

- `GET /health` → `200 {"status":"ok"}` khi tiến trình lên (dữ liệu hợp lệ mới tới được bước này).
- Dockerfile có `HEALTHCHECK` gọi `/health` mỗi 30 giây (`docker ps` hiện `healthy`).
- Phiên bản dữ liệu đang chạy: `GET /v1/reference` → `data_version` (băm nội dung `data/`).
- Hợp đồng API: `GET /openapi/v1.json`.

## 5. Cập nhật dữ liệu không build lại ứng dụng

`data/` và `content/` được đọc **một lần lúc khởi động**. Quy trình:

1. Sửa file trong `data/` (hoặc `content/`).
2. Kiểm tra: `dotnet run --project backend/MonNgon.Tools -- validate-data data`.
3. Với compose (đang mount thư mục): `docker compose restart api`. Kiểm `data_version` ở `/v1/reference` đã đổi.
4. Với môi trường triển khai khác: đặt thư mục dữ liệu mới vào volume/đường dẫn được mount vào `/app/data` rồi khởi động lại container. Không cần build lại image; nếu dữ liệu sai, container sẽ không lên và bản cũ vẫn chạy khi dùng rolling restart (đợi `healthy` rồi mới tắt bản cũ).

Muốn đóng gói dữ liệu vào image (không mount) thì build lại: `docker build -f backend/Dockerfile -t fitpro-api:<tag> .`.

## 6. Ghi chú vận hành

- Không trạng thái: có thể chạy nhiều bản sao sau load balancer, không cần session dính.
- App di động chỉ định API qua `--dart-define=API_BASE_URL=https://api.example.com` lúc build (xem `docs/dev/build-android.md`). Bản release mặc định chỉ cho HTTPS, nên cần TLS ở reverse proxy.
- Dữ liệu cá nhân (hồ sơ, lựa chọn) do app gửi kèm mỗi yêu cầu và API **không lưu**; đừng bật log body ở proxy.

## Kết quả kiểm tra (T-068)

- `docker compose up --build` → container `healthy`, `GET /health` 200, `GET /v1/reference` có `data_version`, `POST /v1/plans` (hồ sơ golden p01) trả tuần 7 ngày.
- Image `fitpro-api:local`: 181 MB. Tiến trình chạy `uid=1654(app)`, không phải root.
- `docker compose restart api` chạy lại bình thường (đọc lại `data/` đã mount).
- Cổng mặc định 5095 trùng với app; nếu cổng bận, đặt `API_PORT`.
