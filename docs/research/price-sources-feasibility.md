# T-110 — Khảo sát khả thi nguồn giá siêu thị và pháp lý

Ngày: 2026-11-09 · Owner: RESEARCH · Trạng thái: **khảo sát bàn giấy, chưa xong**. Chưa có siêu thị nào được xác nhận có kênh dữ liệu được phép. Chưa quan sát giá tay (cần 1–2 tuần).

## 0. Lượt 2 (PM duyệt lượt 1, D-P2-02) — đọc bằng trình duyệt, không tự động

> **Đính chính (09/11/2026, theo T-054c):** đoạn "Phát hiện … 22.478 ₫ … Ba rọi rút sườn" bên dưới là **sai**. Tôi đã đọc nhầm thẻ sản phẩm liền kề. Trang sản phẩm "Thịt heo xay CP khay 200g" (`/thit-heo/thit-heo-xay-cp-khay-200g`) ghi giá khuyến mãi 22.478 ₫ và giá gốc 25.500 ₫. Dòng `prices.json` đúng, không cần sửa. Ba rọi rút sườn heo 400 g giá 47.600 ₫. Lỗi L-14 được rút lại. Chi tiết: `docs/research/price-audit-D2.md`.

Đọc từng trang bằng trình duyệt có sẵn (mỗi trang mở một lần). Không tải hàng loạt, không lấy giá tự động.

| Siêu thị | Trang đã đọc (ngày 09/11/2026) | Kết quả |
|---|---|---|
| Bách hóa Xanh | `bachhoaxanh.com` (chân trang) | Liên kết duy nhất là "Xem chính sách sử dụng web" → `/thoa-thuan-su-dung-trang-mxh`. Trang này là thỏa thuận mạng xã hội (đã đọc ở lượt 1). **Vẫn chưa có điều khoản website bán hàng** |
| WinMart | `winmart.vn` (trang chủ) | Trang tải bằng JavaScript; nội dung có hiện sau khi tải. Tìm "Điều khoản sử dụng", "Hỗ trợ khách hàng" không thấy. **Chưa tìm được điều khoản** |
| Co.opmart | `co-opmart.com.vn/chinh-sach-bao-mat` | "Chính sách bảo mật và xử lý dữ liệu cá nhân", cập nhật 01/01/2026. Áp dụng cho `co-opmart.com.vn` và `cooponline.vn`. Chỉ về dữ liệu cá nhân, không có điều khoản về sao chép giá hay thu thập tự động |
| Co.op Online | `cooponline.vn` (mục "CHÍNH SÁCH & ĐIỀU KHOẢN") | Có các mục: bảo mật, giải quyết tranh chấp, giao hàng, kiểm hàng, bảo hành, đổi-trả. **Chưa có mục "điều khoản sử dụng"** trong danh sách. Mục tranh chấp và trang "điều khoản" chưa đọc |
| Emart | `emart.vn` | **Không truy cập được ngày 09/11/2026**: trình duyệt báo lỗi chứng chỉ TLS (tên miền không khớp). Không đọc được; cần chủ sở hữu sửa chứng chỉ |
| GO! / Big C | `bigc.vn` | **Không truy cập được ngày 09/11/2026**: trình duyệt từ chối tải trang. Chưa đọc |
| Lotte Mart (tham khảo) | `lottemart.vn/vi-nsg/privacy` | Đã đọc ở lượt 1 |

Điểm rút ra mới: không có siêu thị nào trong 5 chuỗi có điều khoản website bán hàng đọc được rõ ràng về sao chép giá hay thu thập tự động. Kết luận này vẫn là "chưa đủ dữ liệu", không phải "được phép".

Quan sát giá tay (lượt 2): đã ghi một lần ở `docs/research/price-observations-log.md`, gồm 3 dòng ngày 09/11/2026. **Chưa đủ 10 mặt hàng × 2 chuỗi × 1–2 tuần.** Phần này cần người đi xem hoặc theo dõi thủ công theo kế hoạch.

Phát hiện khi đối chiếu `data/prices.json` với trang BHX: dòng `thit_heo_xay_nac`, "thịt heo xay C.P 200 g", giá 22.478 ₫, nguồn `/thit-heo`. Trên trang `/thit-heo` ngày 09/11/2026, giá 22.478 ₫ thuộc **"Ba rọi rút sườn heo" 200 g** (giảm 12%, giá gốc 25.500 ₫). "Thịt heo xay C.P" có giá 34.500 ₫ cho 500 g (giảm 8%, giá gốc 37.500 ₫). Có thể là lệch do ảnh chụp cũ (ngày khảo sát 06/11/2026), hoặc dòng dữ liệu bị gán sai. **PM và Dev cần kiểm tra dòng này.**

## 1. Phương pháp và ranh giới

- Tìm kiếm web và đọc công khai: chân trang (footer) các trang chủ, trang chính sách, trang ứng dụng trên App Store. Mỗi trang chỉ mở vài lần để đọc điều khoản.
- **Không thu thập giá tự động** (không scrape, không gọi API không công khai, không crawl danh mục). Không có kết luận nào dựa trên giả định "có thể scrape".
- Ngày đọc: 09/11/2026. Nội dung có thể đã đổi sau ngày này.
- Các điều khoản trích dưới đây là nguyên văn tiếng Việt từ trang đọc được. Nếu đoạn trích lấy từ chính sách khác (không phải chính sách website bán hàng), có ghi rõ.

## 2. Bảng khảo sát (mỗi siêu thị)

| Siêu thị | Kênh dữ liệu (API / đối tác / affiliate / feed) | Điều khoản đã đọc (trích, link, ngày đọc) | Rủi ro pháp lý khi hiển thị giá, khuyến mãi | Giá theo khu vực, tần suất đổi | Đặt liên kết trang sản phẩm | Khuyến nghị |
|---|---|---|---|---|---|---|
| **Bách hóa Xanh** (BHX) | Không tìm thấy API công khai, chương trình đối tác hay affiliate. Chân trang chỉ có email bảo vệ dữ liệu cá nhân (dpo@bachhoaxanh.com) | Liên kết "chính sách sử dụng web" ở chân trang trỏ tới `bachhoaxanh.com/thoa-thuan-su-dung-trang-mxh`, nhưng **trang đó là thỏa thuận mạng xã hội**, không phải điều khoản website bán hàng. Trích Điều 3.2(f): "không tái bản, sao chụp, bán, bán lại hoặc lợi dụng vì các mục đích thương mại bất kỳ dịch vụ nào, nội dung nào". Trang này không có điều khoản về thu thập tự động hay giá sản phẩm. Đọc ngày 09/11/2026 | Điều khoản áp cho mạng xã hội của BHX, chưa chắc áp cho trang giá. **Cần đọc điều khoản website bán hàng thật** (chưa tìm thấy) | Chưa xác minh | Chưa xác minh | **Cần đối tác.** Liên hệ bộ phận đối tác/kinh doanh, không dùng dữ liệu từ website |
| **WinMart** (WinCommerce) | Không tìm thấy | Trang chủ `winmart.vn` tải về chỉ có tiêu đề, không lấy được chân trang. Không tìm được điều khoản website. Đọc ngày 09/11/2026 | Chưa xác minh | Chưa xác minh | Chưa xác minh | **Chưa đủ dữ liệu.** Kiểm lại bằng trình duyệt (trang có thể tải bằng JavaScript) |
| **Co.opmart** (Saigon Co.op) | Không tìm thấy API hay đối tác. Ứng dụng Co.op Online trên App Store do Co.opmart phát hành, có liên kết chính sách bảo mật của nhà phát triển | Chân trang `co-opmart.com.vn` có "Chính sách bảo mật" tại `/chinh-sach-bao-mat` (chưa đọc nội dung). Không có điều khoản sử dụng website hay API. Đọc ngày 09/11/2026 | Chưa xác minh | Chưa xác minh | Chưa xác minh | **Ứng viên ưu tiên để hỏi đối tác**, vì có ứng dụng chính thức và chính sách công khai. Chưa có căn cứ là họ mở kênh dữ liệu |
| **Emart** (Emart Việt Nam) | Không tìm thấy. Ứng dụng Emartmall VN trên App Store (bản quyền: EMART VIETNAM CO., LTD, © 2017) | Không tìm được điều khoản website `emart.vn`. Đọc ngày 09/11/2026 | Chưa xác minh | Chưa xác minh | Chưa xác minh | **Chưa đủ dữ liệu.** Cần tìm thêm qua ứng dụng |
| **GO! / Big C** | Không tìm thấy. Tìm kiếm không ra trang chính thức của Big C/GO! Việt Nam | Không tìm được. Đọc ngày 09/11/2026 | Chưa xác minh | Chưa xác minh | Chưa xác minh | **Chưa đủ dữ liệu.** Cần tìm tên miền chính thức trước |
| **Lotte Mart** (tham khảo, không nằm trong danh sách ban đầu) | Không tìm thấy API hay affiliate | Chính sách bảo mật `lottemart.vn/vi-nsg/privacy`, Mục 2.1: "Các thông tin thu thập tự động khi bạn sử dụng dịch vụ của chúng tôi trên App và Website của Lotte Mart". Chính sách không có điều khoản về sao chép nội dung hay dữ liệu sản phẩm/giá. Có điều khoản chia sẻ dữ liệu cá nhân cho bên thứ ba (Mục 3). Đọc ngày 09/11/2026. Chính sách thành viên `/vi-nsg/membership-policy` chưa đọc | Chính sách bảo mật không cấm dùng giá sản phẩm, nhưng cũng không cho phép rõ | Chưa xác minh | Chưa xác minh | Chưa xác minh |

## 3. Kết luận đọc được

1. **Không tìm thấy siêu thị nào công bố API công khai, chương trình đối tác, affiliate hay feed sản phẩm/giá** trong các nguồn đã đọc. Trang nhà cung cấp dữ liệu giá (ví dụ Actowiz) là dịch vụ thu thập tự động, **không** phải kênh được phép, nên không dùng.
2. **Chưa có điều khoản nào cho phép hiển thị giá, khuyến mãi của siêu thị trong ứng dụng bên thứ ba.** Cũng chưa có điều khoản nào cấm rõ. Điều khoản website bán hàng thật của BHX, WinMart, Co.opmart, Emart, GO! chưa đọc được.
3. Điều khoản duy nhất đọc được rõ ràng là của BHX (thỏa thuận mạng xã hội) và điều khoản bảo mật của Lotte. Cả hai không trực tiếp nói về giá.
4. Theo quy định của ADR-002 và AC T-110, **không có siêu thị nào hiện đạt "dùng được" theo nghĩa pháp lý.** Khuyến nghị cuối cùng là "cần đối tác" hoặc "chưa đủ dữ liệu".

## 4. Rủi ro pháp lý cần luật sư xem (không phải kết luận pháp lý)

- Sở hữu dữ liệu giá và khuyến mãi: giá do siêu thị đặt, chưa rõ có được coi là dữ liệu có bản quyền hay không.
- Hiển thị giá của bên thứ ba và so sánh giữa các siêu thị (US-7.3): cần xem quy định về quảng cáo so sánh và cạnh tranh trong pháp luật Việt Nam. Research chưa tra cứu văn bản luật cụ thể.
- Liên kết sâu (deep link) tới trang sản phẩm (US-7.4): cần xác nhận điều khoản cho phép hay không.
- Dữ liệu cá nhân: nếu app gửi danh sách mua sắm của người dùng sang siêu thị (đặt hàng, giỏ hàng) thì cần thêm chính sách của app. Phase 2 hiện chỉ hiển thị nên chưa phát sinh.

## 5. Các phần chưa làm (cần người)

- **Quan sát giá tay 1–2 tuần** trên vài mặt hàng (T-110 mục 4): chưa làm. Cần người đi chợ hoặc xem thủ công, ghi vào bảng riêng. Không dùng tự động.
- **Độ cũ và tần suất đổi giá**: chưa đo. Hiện chưa có căn cứ để chọn ngưỡng 7 ngày trong ADR-002.
- **Khác biệt theo khu vực**: chưa đo.
- **Điều khoản website bán hàng thật** của BHX, WinMart, Emart, GO!: cần mở trực tiếp bằng trình duyệt và đọc chân trang, ghi lại link và ngày.

## 6. Đề xuất

1. **Siêu thị làm đầu tiên: Co.opmart.** Lý do: có ứng dụng chính thức và chính sách bảo mật công khai, đơn giản để bắt đầu đàm phán đối tác. Đây là giả thuyết cần xác minh, không phải kết luận đã có căn cứ.
2. **Song song:** gửi yêu cầu hợp tác dữ liệu tới bộ phận đối tác của Co.opmart và BHX. Không dùng dữ liệu từ website trong khi chờ.
3. **Phương án dự phòng (nếu không siêu thị nào mở kênh):** khảo sát tay có nhịp đều (1 lần mỗi tuần, vài mặt hàng), và cho người dùng tự nhập giá đã mua (ADR-002 mục "không siêu thị nào có kênh được phép").
4. **Trước khi chốt ADR-002:** PM và người dùng trả lời 5 câu ở PRD §13.4. Mục 4 của PRD là câu về gói miễn phí/premium.

## 7. Việc tiếp theo

- Mở điều khoản website bán hàng của BHX, WinMart, Co.opmart, Emart, GO! bằng trình duyệt (không tự động), ghi trích dẫn và ngày.
- Tìm tên miền chính thức của GO!/Big C.
- Ghi kết quả vào mục 2 của file này, cập nhật ngày.
