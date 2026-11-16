# ADR-002 — Nguồn giá và khuyến mãi theo siêu thị (phase 2)

- **Trạng thái:** **Đã chấp nhận** (người dùng trả lời PRD §13.4, D-P2-06, 2026-11-09) · **Ngày:** 2026-11-09
- **Liên quan:** PRD §13 (Epic 7, Epic 8), ADR-001 (engine trên backend .NET), D-SHP-01…05, D-BUD-02.

## Bối cảnh

- Yêu cầu của người dùng cho phase sau: kết nối các siêu thị (Bách hóa Xanh, WinMart, Co.opmart, Emart, GO!…) để hiện nguyên liệu, giá và giảm giá sau khi đã có thực đơn tuần.
- Hiện tại giá nằm trong `data/prices.json`: mỗi dòng là một quy cách bao bì của một cửa hàng (`pack_g`, `price_vnd`, `shelf_life_days`, `source_url`, `surveyed_on`). Research khảo sát tay. Có dòng `cho_khac` làm giá dự phòng. Engine dùng bảng này để tính chi phí món ăn (so với ngân sách) và con số "trả tại quầy".
- **Chưa biết** siêu thị nào có API, chương trình đối tác hay nguồn dữ liệu công khai. **Không được giả định là thu thập tự động (scrape) được.** Điều khoản sử dụng website có thể cấm, và dữ liệu giá có thể thuộc quyền của siêu thị. T-110 trả lời câu này trước khi chốt ADR.
- Giá thay đổi theo ngày, theo khu vực và theo cửa hàng. Khuyến mãi có thời hạn. Tồn kho từng cửa hàng có thể không công khai.

## Yêu cầu với kiến trúc

1. Engine **không phụ thuộc** nguồn giá thời gian thực. Lập tuần vẫn tất định theo seed và một **ảnh chụp giá** cố định (`price_snapshot_id`). Cùng đầu vào và cùng snapshot thì ra cùng tuần.
2. Mỗi siêu thị là một **adapter** riêng. Thêm hay bỏ một siêu thị không phải sửa engine.
3. Không có nguồn, nguồn lỗi hoặc dữ liệu quá cũ thì **lùi về giá ước lượng hiện có** (`prices.json`, rồi `cho_khac`). Luôn ghi rõ trên UI giá đang hiện là "giá ước lượng" hay "giá siêu thị cập nhật lúc …".
4. Tôn trọng điều khoản và pháp lý: chỉ dùng nguồn được phép. Ghi nguồn và thời điểm của từng con số.
5. Máy khách (Flutter, sau này web) không gọi thẳng siêu thị. Mọi thứ đi qua API .NET (khóa đối tác không nằm trong app, giống lý do ở ADR-001).

## Phương án

| Tiêu chí | (a) Adapter + kho giá có phiên bản + fallback | (b) App gọi thẳng nguồn siêu thị | (c) Giữ khảo sát tay, chỉ tăng tần suất |
|---|---|---|---|
| Engine tất định | **Có** (snapshot) | Không | Có |
| Thêm siêu thị | Thêm adapter | Sửa app, phát hành lại | Thêm công khảo sát |
| Khóa/đối tác an toàn | **Có** (server) | Không | Không cần |
| Khuyến mãi có hạn | Có (trường `valid_from/valid_to`) | Có | Khó |
| Chi phí | Cần job cập nhật + DB | Thấp ở server | Công người |
| Khi nguồn chết | **Fallback tự động** | App lỗi | Không ảnh hưởng |

## Đề xuất

**Chọn (a).** Giữ (c) làm nguồn dự phòng và là nguồn duy nhất cho siêu thị chưa có kênh được phép.

- **`IPriceSource` (adapter theo siêu thị):** `FetchAsync(storeId, region, ingredientIds)` trả về danh sách `PriceQuote { ingredient_id, store_id, region, sku, pack_g, price_vnd, promo_price_vnd?, promo_valid_from?, promo_valid_to?, in_stock?, source, fetched_at }`. Mỗi adapter tự lo xác thực và giới hạn tần suất của nguồn. Một adapter `ManualSurveyPriceSource` đọc `prices.json` hiện có.
- **Ánh xạ sản phẩm:** bảng `ingredient_sku_map` (nguyên liệu → mã sản phẩm của siêu thị, quy cách), do Research duyệt. Không tự đoán ghép tên. Dòng không ánh xạ được thì dùng fallback.
- **Kho giá có phiên bản:** job nền (hosted service .NET) lấy giá theo lịch (tần suất theo T-110, dự kiến 1 lần/ngày), ghi vào DB thành **snapshot** bất biến. Cache đọc trong bộ nhớ theo `(store, region, snapshot)`.
- **Engine:** nhận `price_snapshot_id`, mặc định snapshot mới nhất hợp lệ. Chi phí so ngân sách tính bằng **giá thường**. Giảm giá chỉ hiện trên danh sách đi chợ ("tiết kiệm thêm …") để ngân sách không dao động theo khuyến mãi ngắn hạn. Việc engine chọn món theo khuyến mãi để sau, nếu người dùng muốn (PRD §13.4 câu 5).
- **Độ cũ dữ liệu:** quá 7 ngày (ngưỡng chốt sau T-110) thì coi là cũ: dùng fallback và ghi chú trên UI.
- **API:** `GET /v1/shopping/prices?plan_id&store_id&region` trả giá, khuyến mãi, nguồn và thời điểm cho danh sách đi chợ hiện tại. Tuần đã lập lưu kèm `price_snapshot_id` để giải thích được con số.
- **Pháp lý:** mỗi adapter có tệp ghi chú điều khoản và cơ sở được phép dùng (API công khai, hợp đồng đối tác hoặc nhập tay). Không có cơ sở thì không bật adapter.

## Hệ quả

- Cần DB khi bật phase 2. Chọn cùng DB với freemium (T-029: PostgreSQL hoặc SQL Server, người dùng chọn).
- Golden test của engine dùng snapshot cố định, không đổi theo giá thật.
- Màn Đi chợ phải xử lý 3 trạng thái giá: siêu thị cập nhật, ước lượng, không có giá.
- Nếu T-110 kết luận không siêu thị nào có kênh được phép, phase 2 chỉ còn: tăng tần suất khảo sát tay, cho người dùng tự sửa giá đã mua (dữ liệu trên máy), và Epic 8 (độ tươi, bảo quản).

## Cập nhật 2026-11-09: quyết định của người dùng (PRD D-P2-06)

- Siêu thị đầu tiên và duy nhất ở phase 2: **Bách hóa Xanh, TP.HCM**. Không có đối tác.
- Người dùng chấp nhận **thu thập tự động từ trang công khai** của BHX và chịu rủi ro về điều khoản ("Mình chỉ đang tham khảo giá thôi"). Theo T-110, chưa tìm thấy điều khoản website bán hàng của BHX. Mục "Pháp lý" ở trên được thay bằng quy tắc dưới đây cho adapter này.
- Chỉ hiển thị giá, khuyến mãi và liên kết sản phẩm. Engine không chọn món theo khuyến mãi.

### Adapter thu thập trang công khai (`BhxPublicPageSource`): quy tắc bắt buộc

1. **robots.txt là điểm dừng cứng:** đọc trước mỗi đợt. Đường dẫn bị `Disallow` cho user-agent của mình hoặc `*` thì không lấy. Không đọc được robots.txt thì không chạy đợt đó. Tôn trọng `Crawl-delay` nếu có.
2. **Chỉ trang công khai:** không đăng nhập, không dùng tài khoản, không vượt captcha hay chống bot, không đổi IP/proxy để né chặn, không gọi API nội bộ cần token. Gặp captcha, HTTP 403 hoặc 429 thì **dừng cả đợt**, ghi log, chuyển fallback.
3. **Phạm vi hẹp:** chỉ các sản phẩm trong `ingredient_sku_map` (khoảng 70 nguyên liệu), khu vực TP.HCM. Không crawl danh mục hay toàn site.
4. **Tần suất thấp:** tối đa **1 đợt/ngày**, ngoài giờ cao điểm. Tuần tự, cách nhau ≥ 5 giây mỗi request (hoặc `Crawl-delay` nếu lớn hơn). User-agent ghi rõ tên app và địa chỉ liên hệ do người dùng cung cấp.
5. **Cache phía server:** máy khách không bao giờ gọi BHX. Mọi người dùng đọc cùng một snapshot giá.
6. **Ghi nguồn:** mỗi giá lưu `source_url` và `fetched_at`. UI ghi "Giá Bách hóa Xanh (TP.HCM), cập nhật lúc …" và liên kết tới trang sản phẩm.
7. **Công tắc tắt nhanh:** cờ cấu hình `PriceSources:Bhx:Enabled` đọc lúc chạy. Tắt không cần deploy lại. Khi tắt, API trả giá ước lượng và UI ghi "giá ước lượng".
8. **Phát hiện hỏng:** nếu trang đổi cấu trúc thì dừng đợt và dùng fallback. Dấu hiệu là > 20% sản phẩm không đọc được giá, hoặc giá lệch > 50% so với snapshot trước mà không có dấu khuyến mãi. Phải ghi cảnh báo để người vận hành xem. Không tự "đoán" giá.
9. **Fallback:** snapshot hợp lệ gần nhất, tối đa 7 ngày. Quá 7 ngày thì dùng `prices.json` (khảo sát tay) hoặc `cho_khac`, ghi rõ trên UI.
10. **Không lưu gì ngoài giá:** không lưu nội dung trang, ảnh hay đánh giá. Chỉ lưu tên sản phẩm, quy cách, giá thường, giá khuyến mãi và thời hạn khuyến mãi (nếu trang ghi), URL, thời điểm.
11. **Khi BHX phản đối** (yêu cầu dừng, chặn): tắt adapter ngay bằng công tắc, báo người dùng.

### Cập nhật sau T-110 lượt 3 (PRD D-P2-07)

- Nguồn đọc: **JSON-LD trên trang sản phẩm** (`price`, `lowPrice`, `priceValidUntil`), không parse thẻ danh mục. Mất JSON-LD thì tính là "đổi cấu trúc" (quy tắc 8).
- Khu vực: dùng mặc định khi chưa đăng nhập, không đặt cookie khu vực, không nhập số điện thoại. Nhãn UI "Giá website Bách hóa Xanh" cho tới khi người dùng kiểm chứng giá TP.HCM.
- robots.txt hiện cấm `/tim-kiem?key=*`, `/sp/*`, `/sieu-thi-*`. Adapter không bao giờ gọi các đường dẫn này. Kiểm từng URL theo robots.txt đọc trong đợt.

### Cập nhật theo PRD D-P2-08 (người dùng trả lời 2026-11-09)

- Nhãn nguồn cố định "Giá website Bách hóa Xanh"; không kiểm chứng TP.HCM, không có cờ đổi nhãn.
- **User-agent** (quy tắc 4): `FitProMamDu-PriceBot/<phiên bản> (+mailto:<email liên hệ>)`. Email liên hệ là `romnon4807@gmail.com` (người dùng cung cấp). Đọc từ cấu hình `PriceSources:Bhx:ContactEmail` (appsettings hoặc biến môi trường `PriceSources__Bhx__ContactEmail`). **Không viết cứng** trong mã hay test; test dùng giá trị giả. Thiếu cấu hình này thì adapter không chạy.

