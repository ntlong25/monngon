# Giấy phép hình minh họa (T-057f)

Ngày: 2026-11-16 · Owner: RESEARCH · Thư mục nguồn: `docs/research/illustrations/`

## Nguyên tắc

- Tất cả hình trong bộ này **tự vẽ** cho dự án FitPro - Mâm đủ, bằng SVG viết tay theo bảng màu trong `mobile/lib/ui/tokens.dart` (chỉ đọc, không sửa code).
- **Không dùng** ảnh, icon hay hình của bên khác (bao gồm Mealbird và Tinder). Ngoại lệ duy nhất: 2 icon mục tiêu v3 lấy từ bộ Lucide (ISC), ghi ở bảng dưới và trong README.
- Giấy phép: thuộc dự án, dùng thương mại được, **không cần ghi công trong UI**.
- Hình này không phải ảnh món ăn. Ảnh món vẫn cần nguồn ảnh riêng có giấy phép rõ ràng (xem `docs/research/ui-modernization-direction.md`).

## Danh sách từng hình

| File | Dùng cho | Nguồn | Giấy phép | Ghi công | Ghi chú |
|---|---|---|---|---|---|
| `goal-giam-mo.svg` | Mục tiêu "Giảm mỡ" | Lucide `flame` (lucide-static 1.73.0), https://lucide.dev | ISC | Không bắt buộc trong UI; giữ dòng bản quyền trong file | Ngọn lửa; đổi màu và kích thước, không đổi hình |
| `goal-giu-can.svg` | Mục tiêu "Giữ cân" | Tự vẽ (v2, 2026-11-16) | Thuộc dự án | Không cần | Cân đĩa thăng bằng |
| `goal-tang-co.svg` | Mục tiêu "Tăng cơ" | Lucide `biceps-flexed` (lucide-static 1.73.0), https://lucide.dev | ISC | Không bắt buộc trong UI; giữ dòng bản quyền trong file | Bắp tay gập; đổi màu và kích thước, không đổi hình |
| `dungcu-bep.svg` | Bếp | Tự vẽ | Thuộc dự án | Không cần | Bếp 2 đầu |
| `dungcu-noi-com-dien.svg` | Nồi cơm điện | Tự vẽ | Thuộc dự án | Không cần | Nồi có nắp vòm |
| `dungcu-lo-vi-song.svg` | Lò vi sóng | Tự vẽ | Thuộc dự án | Không cần | Hộp có cửa kính |
| `dungcu-noi-chien-khong-dau.svg` | Nồi chiên không dầu | Tự vẽ | Thuộc dự án | Không cần | Thân trụ, ngăn rổ |
| `dungcu-lo-nuong.svg` | Lò nướng | Tự vẽ | Thuộc dự án | Không cần | Hộp có cửa kính và núm |
| `dungcu-noi-ap-suat.svg` | Nồi áp suất | Tự vẽ | Thuộc dự án | Không cần | Nồi có nắp, van |
| `dungcu-may-xay.svg` | Máy xay | Tự vẽ | Thuộc dự án | Không cần | Cối xay có lưỡi |

## Lưu ý cho Dev

- Thư mục asset trong `mobile/` **chưa được xác định**. PM yêu cầu hỏi Dev trước khi đặt file; chưa đặt file nào vào `mobile/`.
- Khi đưa vào app: giữ tên file và viewBox 120×120; dùng `semanticLabel` là tên mục tiêu hoặc dụng cụ.
- Chưa kiểm hình trên máy (tôi không xem được ảnh render). Dev/Design cần xem ở kích thước 200–240 dp trên thẻ quẹt.
