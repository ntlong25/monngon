# Nguồn dữ liệu dinh dưỡng

Ngày truy cập: 06/11/2026. Người thực hiện: Research session.

## Tóm tắt

- **USDA FoodData Central (FDC)** là nguồn dùng được ngay: API mở, dữ liệu thuộc public domain (CC0 1.0), có thể gọi bằng khóa miễn phí. Phù hợp làm nguồn chính cho macro/calo của nguyên liệu nhập khẩu hoặc có tương đương chuẩn quốc tế (ức gà, trứng, cá, đậu phụ, gạo, rau...).
- **Bảng thành phần thực phẩm Việt Nam (Viện Dinh dưỡng)** là nguồn gốc cho món Việt, nhưng **chưa lấy được file/bản số hóa** trong đợt này. Cần người dùng hoặc đội xác nhận bản có thể dùng và điều kiện sử dụng.
- Khuyến nghị: dùng FDC làm nguồn chính; với nguyên liệu VN (mắm, nước mắm, bún, phở, rau thơm VN...) ưu tiên bảng VN nếu lấy được, không thì dùng mục gần nhất trong FDC và ghi rõ là ước tính.

## 1. USDA FoodData Central API

**Nguồn đã mở:**
- https://fdc.nal.usda.gov/api-guide/ (qua http redirect, truy cập 06/11/2026)

**Cách gọi:**
- Base URL: `https://api.nal.usda.gov/fdc/v1/`
- Tìm kiếm: `GET /foods/search?api_key=KEY&query=chicken%20breast`
- Chi tiết theo FDC ID: `GET /food/{fdcId}?api_key=KEY`
- Nhiều món cùng lúc: `/foods` (POST, body có danh sách `fdcIds`); danh sách rút gọn: `/foods/list`.
- Lọc loại dữ liệu bằng `dataType`: `Foundation`, `SR Legacy`, `Branded`, `Survey (FNDDS)`, `Experimental`. Với POST, `dataType` là mảng, ví dụ `["Branded"]`.
- Khóa: đăng ký miễn phí tại api.data.gov, truyền qua tham số `api_key`.

**Giới hạn:**
- Khóa thường: 1.000 request/giờ/IP. Vượt quá trả HTTP 429 và khóa bị chặn 1 giờ. Header `X-RateLimit-Limit`, `X-RateLimit-Remaining` cho biết mức dùng.
- `DEMO_KEY`: chỉ để thử, 30 request/giờ và 50 request/ngày/IP (theo trang hướng dẫn). Không dùng cho app thật.
- Có thể xin nâng hạn mức qua trang liên hệ của FDC.

**Giấy phép:** dữ liệu USDA thuộc public domain, CC0 1.0 Universal. Không cần xin phép; nên ghi nguồn "U.S. Department of Agriculture, Agricultural Research Service. FoodData Central" trong phần "Cách chúng mình tính" (khớp với yêu cầu của spec về truy vết tới mã bản ghi USDA).

**Lưu ý kỹ thuật cho đội Dev:**
- Lưu `fdcId` và `dataType` vào bảng nguyên liệu, không gọi API lúc người dùng xem thực đơn. Cache kết quả cục bộ.
- Đơn vị trong FDC thường là per 100 g (`foodNutrients`), cần quy đổi sang gram thực tế của nguyên liệu.
- Nguyên liệu VN nhiều khi không có bản ghi trực tiếp; cần ánh xạ thủ công (ví dụ "cá basa" có thể map tới cá da trơn/catfish gần nhất, phải ghi rõ là ánh xạ gần đúng).

## 2. Bảng thành phần thực phẩm Việt Nam (Viện Dinh dưỡng)

**Trạng thái:** chưa xác minh được file tải về.

**Nguồn đã mở:**
- https://viendinhduong.vn/vi/lookup/de-tai-nghien-cuu-khoa-hoc/68035d13359ef722321fce06 (Cổng thông tin Dinh dưỡng Quốc gia). Trang này chủ yếu là **Bảng nhu cầu dinh dưỡng khuyến nghị 2007**, không phải bảng thành phần thực phẩm. Không dùng nhầm.
- https://thuvienso.hiu.vn/tag/nhom-thuc-pham-dinh-duong.html: thư viện số có tài liệu về việc xây dựng bảng thành phần thực phẩm Việt Nam (2 phần, đăng năm 2020: Phần 1 gồm ngũ cốc, khoai củ, đậu hạt, rau, quả, thịt; Phần 2 gồm thủy sản, trứng, sữa, gia vị, đồ uống). Trang trả về 403 khi mở bằng công cụ, nên chưa đọc được chi tiết. Đây là tài liệu về phương pháp/bảng, cần kiểm tra điều kiện sử dụng trước khi dùng.
- Ghi chú từ kết quả tìm kiếm: một số app VN (Eat Clean Diet Track...) khai báo dữ liệu lấy từ bảng này, nên có thể xin tham khảo cách làm.

**Việc còn thiếu:**
- Xác nhận bản chính thức (năm, số trang, bản PDF hay sách) và xin phép hoặc xác nhận giấy phép sử dụng trong app thương mại.
- Ưu tiên lấy: thịt, cá, trứng, đậu phụ, rau, gia vị VN (nước mắm, mắm tôm, tương, sả...).

**Phương án dự phòng nếu không dùng được bảng VN:**
- ASEAN Food Composition Database (đề cập trong nghiên cứu về Việt Nam trên tạp chí AJAD, https://ajad.searca.org/article?p=5270). Chưa mở chi tiết.
- Dùng FDC cho nguyên liệu gốc (ức gà, đùi heo nạc...), và ghi "ước tính" cho món pha chế nhiều thành phần.

## Lô 1 `data/ingredients.json` (T-040, 06/11/2026)

- Đã lấy 17 nguyên liệu, mỗi cái có FDC ID và số liệu trên 100 g từ kết quả API (dataType Foundation/SR Legacy).
- Hạn mức DEMO_KEY là 10 request/giờ; đã dùng hết trong lượt này, nên chưa lấy được phần còn lại. Cần khóa API thật (đăng ký miễn phí tại api.data.gov, do người dùng thực hiện).
- Chưa có trong lô 1: cá lóc/rô phi/cá thu/mực, rau muống, cải ngọt, cải thảo, su su, bí xanh, mồng tơi, khoai lang, khoai tây, sữa chua, gia vị (nước mắm, xì dầu, đường, muối, tỏi, hành, gừng, tiêu, dầu ăn), gạo chưa nấu, bánh phở, bún.
- `ca_basa` đang dùng bản ghi cá da trơn (catfish) làm **proxy**, cần xác nhận lại với basa.
- Các mục rau `sup_lo_xanh`, `sup_lo_trang`, `bap_cai`, `ca_tim` lệch kcal so với 4/4/9 khoảng 17% do chất xơ và carb; có ghi chú trong `source.note`.
- Trường `fiber_g` của các bản ghi Foundation không có số liệu, ghi 0 (chưa xác nhận). `household_units` mới có quả trứng (1 quả ≈ 50 g, giá trị chuẩn chưa đối chiếu với FDC portion).

## Đề xuất cho spec/dev

1. Mỗi nguyên liệu có trường: `nguon` (`USDA` | `VN` | `UOC_TINH`), `fdcId` hoặc mã bảng VN, `dataType`, `ngay_truy_cap`.
2. Với nguồn `UOC_TINH`, hiển thị nhãn "ước tính" trong màn "Cách chúng mình tính".
3. Đưa vào backlog: quyết định chính thức về bản bảng VN (PM).
