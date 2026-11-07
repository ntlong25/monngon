# Phương pháp khảo sát giá (T-042)

Ngày khảo sát: 06/11/2026. File dữ liệu: `data/stores.json`, `data/prices.json` (43 dòng giá, 4 cửa hàng).

## Trạng thái, nói rõ trước

- **Chỉ có 3 dòng giá đã xác minh** (thịt heo tại Bách hóa Xanh, mục "Khuyến mãi sốc", trang https://www.bachhoaxanh.com/thit-heo). Đó là giá khuyến mãi, không phải giá thường.
- **40 dòng `cho_khac` là ước tính** (`pack_label` ghi "ước tính"). Khoảng giá lấy từ tham khảo chung, chưa đối chiếu với chợ hay website. Phải thay bằng số liệu thu thập thực tế trước khi tính toán ngân sách thật.
- **WinMart và Co.opmart: chưa có dữ liệu giá.** Trang WinMart chủ yếu là banner; Co.opmart chỉ có tin khuyến mãi. Hai cửa hàng này chưa đạt AC "≥ 80% có giá ở ≥ 2 cửa hàng".
- Trang danh mục Bách hóa Xanh (thịt gà, trứng, cá, rau) render bằng JavaScript, nên công cụ đọc trang không lấy được danh sách. Cần mở trên trình duyệt có JS hoặc nhờ người dùng chụp màn hình.

## Quy ước

- `price_vnd` là giá gói `pack_g` (gram). Engine tính giá theo gram: giá/gram = `price_vnd / pack_g`.
- `cho_khac` là dòng bắt buộc cho mọi nguyên liệu (fallback). Hiện đủ 40/40.
- `shelf_life_days`: ước tính bảo quản tủ lạnh (thịt/cá 2–3 ngày, rau 5–7 ngày, trứng 21 ngày, củ 14–30 ngày, gia vị khô 365+ ngày). Chưa đối chiếu nguồn.
- `com_trang`: giá gạo tẻ 5 kg quy đổi sang cơm chín, cần thống nhất hệ số khi tính chi phí (cơm chín ≈ 2,5 lần gạo khô theo khối lượng; kiểm lại trước khi dùng).
- `source_url` rỗng với dòng ước tính; BHX có URL và ngày khảo sát.

## Ngân sách tuần (T-042 đề xuất, chưa xác nhận)

Chưa làm trong lượt này. Cần số liệu giá thật để đặt ngưỡng. Đề xuất bước tiếp: đo tổng chi phí của một tuần thực đơn mẫu (theo `data/recipes.json`) rồi chia thành 3–4 bậc.

## Kết quả tra cứu WinMart và Co.opmart (cập nhật 06/11/2026)

- **WinMart** (winmart.vn, trang tìm kiếm `search?q=ức gà`): trang yêu cầu chọn cửa hàng (storeCode) trước khi hiện sản phẩm; khi chưa chọn, kết quả trống ("sản phẩm chưa được phục vụ tại cửa hàng"). Không lấy được giá ức gà, trứng hay cá. Một bài khuyến mãi cũ ghi khay ức gà CP 500 g từng là 44.900 ₫, nhưng không rõ thời điểm, không dùng làm giá tham chiếu.
- **Co.opmart / Co.op Online** (cooponline.vn, `search?q=ức gà`): trang yêu cầu chọn siêu thị giao hàng trước; văn bản trang không có danh sách sản phẩm. Tìm kiếm tin tức chỉ có khuyến mãi chung, không có giá niêm yết theo mặt hàng năm 2026.
- Kết luận: **chưa có giá WinMart và Co.opmart nào** từ web công khai trong lượt này. Cần người dùng chọn cửa hàng gần nhất trên trang/app rồi chụp màn hình, hoặc khảo sát tại cửa hàng.

## Việc còn lại để đạt AC

1. Thu giá thực tế cho 40 nguyên liệu tại Bách hóa Xanh (mở trên trình duyệt có JS hoặc nhờ người dùng).
2. Khảo sát WinMart và Co.opmart cho các nguyên liệu có sẵn trên trang bán lẻ của họ.
3. Đặt `surveyed_on` đúng ngày khảo sát từng dòng.
