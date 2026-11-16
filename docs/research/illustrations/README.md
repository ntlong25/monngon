# Hình minh họa: 3 mục tiêu và 7 dụng cụ bếp (bộ thử nghiệm)

Ngày: 2026-11-16 · Owner: RESEARCH · Trạng thái: **bộ thử nghiệm, chưa kiểm trên máy**. Tôi viết SVG bằng tay nhưng không có công cụ để xem ảnh render, nên Dev hoặc Design cần mở từng file và xem.

**Nguồn chuẩn là file SVG trong thư mục này.** Dev sinh PNG 1x/2x/3x vào `mobile/assets/illustrations/` bằng `tools/svg_to_png.py`. Khi sửa SVG, giữ nguyên tên file rồi báo Dev chạy lại script. Không thêm `flutter_svg` (PM đã chọn không thêm dependency).

## 1. Nội dung

| File | Dùng cho | Mô tả |
|---|---|---|
| `goal-giam-mo.svg` | Mục tiêu "Giảm mỡ" (v3) | Icon Lucide "flame" (ngọn lửa, đốt mỡ) |
| `goal-giu-can.svg` | Mục tiêu "Giữ cân" (v2) | Cân đĩa thăng bằng, thanh ngang và hai đĩa to hơn |
| `goal-tang-co.svg` | Mục tiêu "Tăng cơ" (v3) | Icon Lucide "biceps-flexed" (bắp tay gập) |

### Nguồn icon mục tiêu (v3, 2026-11-16)

| File | Icon gốc | Bộ icon | Phiên bản | Giấy phép | Nguồn kiểm tra |
|---|---|---|---|---|---|
| `goal-giam-mo.svg` | `flame` | Lucide (lucide-static) | 1.73.0 | ISC | https://unpkg.com/lucide-static@1.73.0/icons/flame.svg |
| `goal-tang-co.svg` | `biceps-flexed` | Lucide (lucide-static) | 1.73.0 | ISC | https://unpkg.com/lucide-static@1.73.0/icons/biceps-flexed.svg |

- Lấy nguyên đường đi nét (path) của icon gốc (viewBox 24×24), đặt trong `<g transform="translate(12 12) scale(4)">` để đủ khung 120 và stroke-width 1.25 (≈ 5 đơn vị ở khung 120, khớp 7 icon dụng cụ).
- Màu: xanh lá `#1B6B4F` cho nét, nền `#F1ECE0`. Không đổi hình gốc, chỉ đổi màu và vị trí.
- Giấy phép ISC cho phép dùng thương mại, không bắt buộc ghi công trong UI; giữ dòng ghi chú bản quyền trong file SVG và trong `illustrations-licenses.md`.
- Icon `goal-giu-can.svg` vẫn là hình tự vẽ (không đổi).
| `dungcu-bep.svg` | Bếp | Bếp gas 2 đầu |
| `dungcu-noi-com-dien.svg` | Nồi cơm điện | Nồi có nắp vòm và nút điều khiển |
| `dungcu-lo-vi-song.svg` | Lò vi sóng | Hộp có cửa kính và nút |
| `dungcu-noi-chien-khong-dau.svg` | Nồi chiên không dầu | Thân trụ, ngăn kéo rổ |
| `dungcu-lo-nuong.svg` | Lò nướng | Hộp có cửa kính và núm |
| `dungcu-noi-ap-suat.svg` | Nồi áp suất | Nồi có nắp, van và tay cầm |
| `dungcu-may-xay.svg` | Máy xay | Cối xay có lưỡi |

Kích thước: viewBox 120×120, nền bo góc màu `#F1ECE0` (`surfaceVariant` của `AppColors`).

**Lần sửa 2026-11-16 (theo góp ý của hub):** ba icon mục tiêu được vẽ lại để đọc rõ khi hiển thị lớn (200–240 dp trên thẻ quẹt): nét dày hơn, hình to hơn trong khung, bỏ chi tiết lạ. Bảy icon dụng cụ không đổi. Ảnh render của bản v2 do hub xem; tôi vẫn không xem được ảnh render nên kiểm bố cục trên máy vẫn là việc của Dev/Design.

## 2. Phong cách và bảng màu

- Phẳng, không gradient, không bóng. Mỗi hình dùng tối đa 4 màu.
- Màu lấy từ `mobile/lib/ui/tokens.dart` (đọc lúc viết, không sửa code): xanh lá `#1B6B4F`, vàng nghệ `#F2A93B`, kem `#FBF8F1`, nền `#F1ECE0`, chữ `#1E2420`, xám `#55605A`, nhạt `#D7EFE3` và `#FFE9C9`.
- Đường nét 3–5 đơn vị, bo đầu nét, khớp với icon hiện có.

## 3. Nguồn và giấy phép

- **Nguồn:** tự vẽ cho dự án này, không sao chép từ bộ icon hay ảnh nào. Không có tác giả bên thứ ba.
- **Giấy phép:** thuộc dự án (dùng nội bộ và thương mại). Không cần ghi công trong UI.
- **Ảnh món ăn:** không thuộc bộ này. Vẫn cần nguồn ảnh có giấy phép (xem `docs/research/ui-modernization-direction.md`).

## 4. So sánh với bộ icon mã nguồn mở (không đã dùng)

Tôi chưa kiểm lại trang license của từng bộ. Thông tin dưới đây theo kiến thức chung, **cần kiểm lại trước khi chọn**:

| Bộ | Giấy phép (theo kiến thức chung) | Ghi công | Ghi chú |
|---|---|---|---|
| Phosphor | MIT | Thường không bắt buộc trong UI, nhưng kèm file license khi phân phối | Có icon đồ gia dụng, nhưng ít hình mục tiêu |
| Lucide | ISC | Như trên | Nét đều, thiếu icon nồi chiên không dầu |
| Tabler | MIT | Như trên | Nhiều icon bếp |
| Material Symbols | Apache 2.0 | Cần giữ thông báo bản quyền khi phân phối | Phong cách Material, khác bảng màu hiện tại |
| Twemoji | CC-BY 4.0 | **Bắt buộc ghi công** | Loại khỏi danh sách |

Nhận xét: bộ icon sẵn có khó khớp đủ 10 hình với một phong cách thống nhất, nên tự vẽ là phương án an toàn về giấy phép. Nhược điểm: cần Design duyệt lại và tốn thời gian.

## 5. Việc tiếp theo

1. Dev hoặc Design mở từng SVG trong trình duyệt hoặc Figma để xem bố cục, cân đối và độ tương phản.
2. Nếu cần vẽ lại, giữ bảng màu và viewBox để dễ thay thế trong Flutter (dùng `flutter_svg` hoặc `SvgPicture`, cần PM duyệt dependency).
3. Dùng `semanticLabel` là tên mục tiêu/dụng cụ khi hiển thị.
