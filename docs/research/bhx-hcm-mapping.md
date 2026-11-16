# T-110 lượt 3 — robots.txt, khu vực TP.HCM, bản nháp ingredient_sku_map (Bách hóa XANH)

Ngày: 2026-11-09 · Owner: RESEARCH · Kết quả đi kèm: [ingredient-sku-map-draft.json](ingredient-sku-map-draft.json).
Không viết và không chạy script thu thập (việc của T-113). Mọi trang được mở bằng trình duyệt có sẵn, mỗi trang một lần.

## 1. robots.txt — mở bằng trình duyệt ngày 09/11/2026

Nguồn: `https://www.bachhoaxanh.com/robots.txt`. Nguyên văn:

```
User-agent: *

Disallow: /lich-su-mua-hang
Disallow: /gio-hang
Disallow: /gio-hang/*
Disallow: /gio-hang/dat-hang-thanh-cong/*
Disallow: /dang-nhap
Disallow: /uu-dai-dac-biet
Disallow: /tien-du
Disallow: /thong-tin-ca-nhan
Disallow: /thong-tin-ca-nhan/phieu-mua-hang
Disallow: /thong-bao
Disallow: /thanh-toan
Disallow: /thanh-toan/thong-tin-thanh-toan
Disallow: /don-hang
Disallow: /don-hang/*
Disallow: /dia-chi
Disallow: /cap-nhat-thong-tin
Disallow: /sieu-thi-*
Disallow: /hoa-don-dien-tu/*
Disallow: /sp/*
Disallow: /tim-kiem?key=*
Disallow: /cong-thanh-toan*
Disallow: *st=
Disallow: /tra-cuu-ma-buu-dien-tp-ho-chi-minh-zip-code-postal-code-1415140
Disallow: /hoi-dap
Disallow: /comment/initbhx*

User-agent: AdsBot-Google
Sitemap: https://www.bachhoaxanh.com/sitemapnew
```

**Kết luận:**
- Đường dẫn trang sản phẩm (`/thit-heo/...`, `/trai-cay-tuoi-ngon/...`, `/sua-tuoi/...`) **không bị Disallow** trong nhóm `User-agent: *`. Không có dòng nào cấm các đường dẫn danh mục đã dùng.
- **Không được dùng đường dẫn tìm kiếm** `/tim-kiem?key=…` (bị cấm). Tôi không dùng đường dẫn này trong khảo sát.
- `/sp/*` và `/sieu-thi-*` bị cấm. Nếu trang sản phẩm có đường dẫn `/sp/…` hoặc trang cửa hàng `/sieu-thi-…`, không được dùng.
- Nhóm `AdsBot-Google` không có dòng cấm nào, chỉ khai báo sitemap. Dev không dùng nhóm này để lấy giá.
- Robots không đề cập đến việc thu thập giá. Điều khoản website bán hàng thật chưa tìm thấy (đã ghi ở `price-sources-feasibility.md`). Theo D-P2-06, PM chấp nhận thu thập tự động từ trang công khai; việc này vẫn cần đối chiếu với 11 quy tắc của ADR-002.

**Không có Disallow cho đường dẫn sản phẩm → không cần báo PM về việc cấm.**

## 2. Khu vực TP.HCM: giao diện chọn vị trí

Kết quả kiểm tra (không đăng nhập, không nhập địa chỉ hay số điện thoại):

- Trên trang chủ có nút **"Chọn vị trí giao gần bạn"** ở góc phải thanh tìm kiếm. Bấm nút này **không mở được bộ chọn khu vực**: trình duyệt chuyển sang trang `/dang-nhap` hoặc hiện popup "Đăng nhập để nhận ưu đãi" (ô nhập số điện thoại). Vì vậy **chưa xác định được cách chọn TP.HCM trên web khi chưa đăng nhập.**
- Các tên cookie thấy trên trang: `device`, `ck_bhx_us_deviceId`, `ck_bhx_us_is_new_flow`, `x-params`, `x-url`, `x-pathname`, cùng cookie phân tích. **Chưa xác định cookie nào chứa khu vực.** Không đoán.
- Trang "XEM 4.387 CỬA HÀNG" (`/he-thong-sieu-thi`) có danh sách cửa hàng. Chưa mở để đối chiếu cửa hàng TP.HCM.
- Chưa biết giá có khác theo khu vực hay không. Chưa so sánh được.

**Việc cần người làm:** một người dùng đã đăng nhập (hoặc người dùng của dự án) chọn TP.HCM trên trình duyệt và ghi lại: nút nào được bấm, có tham số URL hay cookie nào thay đổi (xem Application/Cookies trong DevTools).

## 3. Giá thường, giá khuyến mãi và thời hạn khuyến mãi hiển thị ở đâu

Quan sát trên thẻ sản phẩm ở trang danh mục (ví dụ `/thit-heo`, `/trai-cay-tuoi-ngon`, ngày 09/11/2026):

- **Giá bán hiện tại** (chữ đậm lớn, ví dụ `22.478đ/200g`). Đây là giá khuyến mãi hoặc giá thường đang áp dụng; đơn vị là gói.
- **Giá gốc** gạch ngang (ví dụ `25.500đ`), và **phần trăm giảm** (ví dụ `-12%`). Đây là giá thường mà hồ sơ `prices.json` phải dùng (quy tắc giá thường, T-054d).
- **Đơn giá theo kg** trong ngoặc (ví dụ `(119.000đ/kg)`) trên một số thẻ.
- **Nhãn "KHUYẾN MÃI SỐC" / "Flash Sale"** cho một số sản phẩm. Trên trang sản phẩm có dữ liệu có cấu trúc (JSON-LD `offers`) với `price` (giá gốc), `lowPrice` (giá bán) và `priceValidUntil` (ngày hết hạn giá, ví dụ `2026-11-09`). **Đây là nguồn đáng tin hơn thẻ danh mục để lấy giá thường và hạn giá.**
- **Thời hạn khuyến mãi:** trên thẻ hiện bộ đếm "Kết thúc sau …" (thời gian còn lại), không phải ngày cụ thể. Ngày hết hạn chỉ thấy trong `priceValidUntil` của trang sản phẩm.

Lưu ý: một số thẻ hiện hai giá cho cùng sản phẩm (ví dụ "Đùi bò 200 g" hiện cả 58.929 ₫ flash sale và 54.459 ₫). Chưa giải thích được; cần đối chiếu từng trang sản phẩm.

## 4. Bản nháp ingredient_sku_map

Hồ sơ đầy đủ ở [ingredient-sku-map-draft.json](ingredient-sku-map-draft.json). Tóm tắt:

| bhx_status | Số nguyên liệu | Ý nghĩa |
|---|---|---|
| `verified_page` | 2 | Đã mở trang sản phẩm (thịt heo xay CP khay 200 g; sữa tươi Vinamilk 48 hộp) |
| `verified_card` | 8 | Có thẻ sản phẩm trên trang danh mục (thịt heo, thịt bò, trái cây). Cần mở trang sản phẩm để xác nhận quy cách |
| `chua_kiem` | 59 | Chưa mở được trang danh mục tương ứng |

**Các điểm không khớp cần lưu ý:**
- Thịt đùi heo, ba rọi heo, đùi bò: thẻ danh mục ghi 300 g hoặc 200 g, nhưng đường dẫn sản phẩm ghi 1 kg. Chưa biết đường dẫn nào là đúng quy cách bán lẻ.
- Cam sành (5 kg), táo Nam Phi (1 kg): quy cách lớn hơn nhiều so với hồ sơ (500 g). Cần tìm gói nhỏ hơn hoặc quy đổi theo gram khi tính giá.
- Sữa tươi: BHX bán thùng 48 hộp 180 ml. Hồ sơ `prices.json` dùng hộp hoặc lốc UHT. Cần tìm lốc 4 hộp.

**Nguyên liệu BHX không có:** chưa xác định được. Với 59 nguyên liệu `chua_kiem`, tôi chưa mở được trang danh mục tương ứng, nên chưa thể nói BHX không bán. Không ghi "không có" khi chưa kiểm.

## 5. Vấn đề về phương pháp và việc còn lại

- **Không tìm được đường dẫn danh mục** cho gà, cá, hải sản, trứng, rau, củ, đậu, sữa đậu nành, gạo và gia vị. Thử một số đường dẫn đoán (`/thit-ga-vit`, `/ca-hai-san`, `/rau-cu-tuoi`, `/rau-la`, `/hai-san`…) đều không có sản phẩm. Menu "DANH MỤC SẢN PHẨM" không lộ đường dẫn qua công cụ đọc trang. **Cần người mở menu trên trình duyệt và ghi các đường dẫn danh mục**; sau đó tôi mới đọc được.
- Công cụ đọc DOM (JavaScript) được dùng để đọc đường dẫn và giá trên từng trang đã mở (manual inspection). Không lặp qua nhiều trang và không lưu dữ liệu tự động. Ghi lại để PM biết.
- Quy cách trên thẻ không luôn khớp trang sản phẩm. Cần mở từng trang sản phẩm trước khi lập SKU chính thức.

## 6. Bước tiếp theo đề xuất

1. Người dùng (đã đăng nhập) chọn TP.HCM trên web BHX và ghi cách làm (mục 2).
2. Người mở menu danh mục và ghi các đường dẫn của nhóm gà, cá, hải sản, trứng, đậu, rau, củ, sữa đậu nành, gạo, gia vị.
3. Mở từng trang sản phẩm để xác nhận quy cách và giá thường; ghi `priceValidUntil` nếu có.
4. Sau khi có đủ, RESEARCH cập nhật `ingredient-sku-map-draft.json` và báo PM để duyệt trước khi T-113 dùng.

## 7. Lượt 4 (PM D-P2-07): giá từ JSON-LD, SKU nhỏ nhất, kết quả và AC

Ngày: 2026-11-09. Theo D-P2-07: lấy giá từ JSON-LD của trang sản phẩm (`price` = giá thường, `lowPrice` = giá bán, `priceValidUntil`). Không dùng thẻ danh mục làm giá chính. Giá là giá mặc định, không đăng nhập, không chọn khu vực. Nhãn hiển thị: "Giá website Bách hóa Xanh".

**Cách tìm trang sản phẩm:**
- `site:` trên công cụ tìm kiếm hầu như không lọc được; kết quả chủ yếu là bài viết, không phải trang sản phẩm.
- Dùng đường dẫn danh mục đã thấy trên kết quả tìm kiếm hoặc trên trang khác: `/thit-ga`, `/trung`, `/rau-sach`, `/nam-tuoi`, `/trai-cay-tuoi-ngon`, `/sua-tuoi`, `/sua-chua`, `/ca-hai-san-dong-lanh-mrt` (chỉ cá đông lạnh, không thấy cá tươi), `/ca-hop-ligo`.
- Không dùng `/tim-kiem` (robots.txt cấm).
- Đường dẫn đoán `/rau-cu`, `/rau-cu-qua`, `/rau-cu-tuoi-ngon`, `/cu-qua`, `/dau-hu`, `/gao-bot-do-kho`, `/dau-nam-do-kho`, `/ca-tuoi-song`, `/hai-san`, `/ca-tuoi`, `/thit-ga-vit-tuoi`… đều không có sản phẩm.
- Đọc JSON-LD bằng công cụ đọc trang trên từng trang đã mở, không lặp qua nhiều trang.

**Kết quả: 15/69 nguyên liệu có `verified_page` (≈22%). Không đạt AC 80%.**

| Nguyên liệu | Trang sản phẩm | Quy cách | Giá thường | Giá bán | Ghi chú |
|---|---|---|---|---|---|
| thịt heo xay | /thit-heo/thit-heo-xay-cp-khay-200g | 200 g | 25.500 | 22.478 | Khớp |
| thịt đùi heo | /thit-heo/thit-dui-heo-1kg | CẦN XÁC MINH | 35.700 | 34.500 | Thẻ 300 g, URL 1 kg |
| ba rọi heo | /thit-heo/ba-roi-heo-1kg | CẦN XÁC MINH | 46.200 | 44.700 | Thẻ ghi 42.300, JSON-LD 44.700 |
| đùi bò | /thit-bo/dui-bo-viet-nam-tui-1kg | CẦN XÁC MINH | 63.400 | 58.929 | Thẻ 200 g |
| sữa tươi | /sua-tuoi/stt-vinamilk-it-duong-hop-180ml-48 | thùng 48 × 180 ml | 395.000 | 388.000 | `bulk_only`: không thấy lốc |
| đùi gà (má đùi) | /thit-ga/ma-dui-ga-vi-500g | 500 g | 44.400 | 44.400 | Cần xác nhận không xương, không da |
| trứng gà | /trung/trung-ga | 1 quả | 2.000 | 2.000 | Bán lẻ, không có khối lượng |
| rau muống | /rau-sach/rau-muong-nuoc-400gr | 400 g | 11.000 | 5.000 | |
| cải ngọt | /rau-sach/cai-ngot-baby-goi-300g | ~300 g | 17.900 | 5.000 | Cải ngọt baby (hồ sơ là cải bẹ) |
| rau dền | /rau-sach/rau-den-goi-300g | CẦN XÁC MINH | 18.600 | 5.000 | URL 300 g, tiêu đề 400 g |
| ổi | /trai-cay-tuoi-ngon/oi-dai-loan-hop-1-kg | 1 kg | 27.900 | 11.263 | Giá bán lạ, cần xác minh |
| xoài | /trai-cay-tuoi-ngon/xoai-tu-quy1kg | 1 kg | 46.800 | 46.800 | |
| chuối | /trai-cay-tuoi-ngon/chuoi-gia-giong-nam-my | CẦN XÁC MINH | 33.200 | 21.000 | |
| táo | /trai-cay-tuoi-ngon/tao-nam-phi-gion-ngot-tui-1kg | 1 kg | 62.800 | 49.000 | |
| cam sành | /trai-cay-tuoi-ngon/cam-sanh | CẦN XÁC MINH | 9.100 | 9.100 | |

**Không khớp:** nấm rơm. BHX chỉ bán nấm rơm tươi (túi 200 g, 26.000 ₫). Hồ sơ là nấm rơm đóng hộp, không thay thế được.

**Chưa kiểm (53 nguyên liệu):** chưa tìm được trang danh mục cho gà (ức không xương, đùi không xương: danh mục /thit-ga chỉ có ức có da, ức có xương, đùi góc tư, má đùi khay), cá tươi, tôm, mực, thịt heo thăn, rau củ (cà rốt, bắp cải, súp lơ, cà tím, cà chua, hành, tỏi, gừng, khoai, dưa chuột, đậu bắp, đậu cô ve, bí xanh, su su, cải thảo), trái cây còn lại (dưa hấu, đu đủ, dứa, bưởi), đậu hũ, sữa đậu nành, sữa chua, gạo, đồ khô, gia vị.

**Lưu ý:** Ức gà không xương không da và đùi gà không xương không da chưa được coi là "BHX không bán", vì danh mục đã đọc không đủ để kết luận. Chưa ghi "BHX không bán" cho nguyên liệu nào.

**Việc cần người làm để đạt AC:** mở menu DANH MỤC SẢN PHẨM trên trình duyệt (đã đăng nhập hoặc không) và ghi đường dẫn các nhóm: rau củ quả, cá tươi, gia vị, gạo và đồ khô, đậu, sữa chua, thịt thăn. Sau đó tôi đọc JSON-LD từng trang.

## 8. Lượt 5 (PM): dùng sitemap của BHX để tìm trang sản phẩm

Ngày: 2026-11-09. Nguồn: `https://www.bachhoaxanh.com/sitemapnew` (sitemap index; gồm `sitemap-cate` 218 đường dẫn danh mục và `sitemap-product` 188 sitemap con). Chỉ đọc sitemap và các trang cần dùng. Không crawl. Không dùng `/tim-kiem`.

**Danh mục dùng được (từ sitemap-cate, đã mở):** `/cu` (củ, rau: cà chua, cà rốt, bắp cải, cải thảo, khoai tây, su su, bí xanh, dưa leo, tỏi), `/rau-sach` (rau lá), `/gao-gao-nep`, `/dau-cac-loai`, `/duong`, `/muoi-an`, `/nuoc-mam`, `/dau-an`, `/nuoc-tuong`, `/tieu`, `/sua-tu-hat`, `/sua-chua`, `/ca-tom-muc-ech` (cá tươi, có cá basa cắt khúc), `/ca-hai-san-dong-lanh`, `/gia-vi-nem-san`.

**Chưa mở được:** `/rau-cu-trai-cay`, `/thit-ca-trung-rau-cu` (không có sản phẩm trong DOM). Chưa đọc: `sitemap-product` (188 file), `/dau-hu` (không có danh mục), `/sua-chua` (chỉ thấy sữa chua uống, không có sữa chua Hy Lạp không đường).

**Kết quả:** 33/69 nguyên liệu `verified_page` (≈48%). 2 nguyên liệu `chua_co_gia` (JSON-LD trả giá 0). 1 `khong_khop` (nấm rơm). 33 `chua_kiem`. Chưa có nguyên liệu nào ghi "BHX không bán" vì sitemap-product chưa đọc hết.

| Nguyên liệu | Trang | Quy cách | Giá thường | Giá bán | Ghi chú |
|---|---|---|---|---|---|
| cà chua | /cu/ca-chua-1kg | 1 kg | 8.400 | 8.400 | |
| cà rốt | /cu/ca-rot-1kg | 1 kg | 10.050 | 10.050 | |
| bắp cải | /cu/bap-cai-trang-tui-1kg | 1 kg | 9.450 | 9.450 | |
| cải thảo | /cu/bap-cai-thao-1kg | 1 kg | 15.200 | 15.200 | |
| khoai tây | /cu/khoai-tay-500g | 500 g | 10.620 | 10.620 | |
| su su | /cu/su-su-500g | 500 g | 8.280 | 8.280 | |
| bí xanh | /cu/bi-xanh-tui-1kg | 1 kg | 13.800 | 6.900 | Cần xác minh giá bán |
| dưa leo (dưa chuột) | /cu/dua-leo-vi-500g | 500 g | 7.360 | 7.360 | |
| tỏi | /cu/toi-tim-trung-quoc-200g | 200 g | 17.300 | 17.300 | Tỏi tím TQ, cần xác nhận loại |
| đường | /duong/duong-kinh-trang-an-khe-goi-500g | 500 g | 16.800 | 16.800 | |
| đậu xanh | /dau-cac-loai/dau-xanh-ca-tach-vo-cao-cap-vietfresh-150g | 150 g | 13.800 | 13.800 | Đậu tách vỏ, hồ sơ là nguyên vỏ |
| gạo lứt | /gao-gao-nep/gao-lut-tim-vinh-hien-tui-1kg | 1 kg | 48.000 | 39.000 | Gạo lứt tím |
| nước mắm | /nuoc-mam/nuoc-mam-ca-com-thuan-phat-chai-610ml | 610 ml | 81.000 | 81.000 | |
| dầu ăn (đậu nành) | /dau-an/dau-dau-nanh-orchid-chai-1-lit | 1 lít | 69.000 | 69.000 | |
| sữa đậu nành | /sua-tu-hat/sua-dau-nanh-fami-canxi-hop-1-lit | 1 lít | 22.000 | 22.000 | Cần xác minh không đường |
| tiêu đen | /tieu/tieu-den-xay-50g | 50 g | 22.000 | 22.000 | Tiêu xay, hồ sơ là hạt |
| xì dầu | /nuoc-tuong/nuoc-tuong-707-ong-cha-va-vi-thanh-diu-chai-500ml | 500 ml | 15.500 | 15.500 | Nước tương, cần kiểm lúa mì |
| cá basa | /ca-tom-muc-ech/ca-basa-cat-khuc | không ghi | 52.500 | 52.500 | Cắt khúc, hồ sơ là phi lê |

**Chưa có giá (JSON-LD = 0):** lạc (`/dau-cac-loai/lac-cuc-do-ly-tuong-goi-400g`), muối (`/muoi-an/muoi-sach-visaco-hat-nho-goi-500g`).

**Ghi chú:** sitemap đã cho đường dẫn danh mục, nhưng các nguyên liệu tươi còn lại (cá thu, mực, tôm, thịt thăn, đậu hũ, sữa chua Hy Lạp, cà tím, hành tây, hành lá, gừng, khoai lang, đậu cô ve, đậu bắp, đậu lăng, đậu đỏ, tempeh, bún/phở, gạo tẻ, gạo nếp) cần đọc thêm `sitemap-product` hoặc danh mục khác. AC 80% chưa đạt (33/69).

## 9. Lượt 6 (hub, 2026-11-10): đọc sitemap-product để xử lý 33 nguyên liệu còn lại

Nguồn: `sitemap-product` (188 file con, 4.780 URL sản phẩm). Chỉ đọc sitemap để lọc theo tên; sau đó đọc JSON-LD của từng trang cần dùng. Không crawl trang. Không dùng `/tim-kiem`.

**Kết quả (69 nguyên liệu):** `verified_page` 49 · `khong_ban` 11 · `khong_khop` 6 · `chua_co_gia` 2 · `chua_kiem` 1. Tổng `verified_page` + `khong_ban` = 60/69 (≈87%), **đạt AC 80%**.

**"BHX không bán" (chỉ ghi khi sitemap không có sản phẩm phù hợp):** ức gà không xương không da; thịt heo thăn; cà tím; cá rô phi; cá thu tươi (chỉ có cá thu sốt cà hộp); đậu lăng; tempeh; giá đỗ; bưởi; dứa; gạo nếp khô.

**Khớp mới (JSON-LD, ngày 10/11/2026 hoặc ngày ghi trong bảng):**

| Nguyên liệu | Trang | Quy cách | Giá thường | Giá bán | Ghi chú |
|---|---|---|---|---|---|
| súp lơ xanh | /cu/bong-cai-xanh-nhap-khau | CẦN XÁC MINH | 32.600 | 32.600 | Bông cải xanh nhập khẩu |
| súp lơ trắng | /cu/bong-cai-trang-nhap-khau | CẦN XÁC MINH | 32.600 | 32.600 | |
| tôm | /ca-tom-muc-ech/tom-the-300g | 300 g | 44.000 | 44.000 | Tôm thẻ, không phải tôm sú |
| mực ống | /ca-hai-san-dong-lanh/muc-ong-nguyen-con-dong-lanh-ao-ao-goi-300g | 300 g | 109.000 | 109.000 | Đông lạnh, nguyên con |
| cá basa | /ca-tom-muc-ech/ca-basa-phi-le-1kg | 1 kg | 32.500 | 32.500 | Thay cho dòng cắt khúc trước đây |
| khoai lang | /cu/khoai-lang-nhat-tui-500g-2-5-cu | 500 g | 16.600 | 16.600 | Khoai lang Nhật |
| gừng | /cu/gung-vn-tui-200g | 200 g | 6.600 | 6.600 | |
| hành tây | /cu/hanh-tay-300gr | 300 g | 11.300 | 11.300 | |
| hành lá | /rau-sach/hanh-la-goi-100g | 100 g | 7.800 | 7.800 | |
| đậu bắp | /cu/dau-bap-khay-250g-10-12-trai | 250 g | 11.600 | 11.600 | |
| đậu cô ve | /cu/dau-cove-250g | 250 g | 16.600 | 16.600 | |
| dưa hấu | /trai-cay-tuoi-ngon/dua-hau-do-1kg | 1 kg | 46.500 | 37.500 | |
| đu đủ | /trai-cay-tuoi-ngon/du-du-ruot-do-1kg | 1 kg | 20.000 | 20.000 | |
| đậu đỏ | /dau-cac-loai/dau-do-hat-cao-cap-vietfresh-150g | 150 g | 16.700 | 16.700 | |
| vừng trắng | /dau-cac-loai/me-trang-khong-vo-vietfresh-100g | 100 g | 18.900 | 18.900 | Mè trắng không vỏ |
| nước mắm chay | /nuoc-mam/nuoc-mam-chay-lien-thanh-chai-300ml | 300 ml | 34.000 | 34.000 | |
| bún/phở tươi | /bun-kho/bun-tuoi-bach-hoa-xanh-goi-500g | 500 g | 11.600 | 9.500 | Bún tươi sống; hồ sơ là bún đã luộc, cần xác nhận |

**Không khớp (`khong_khop`):** đậu hũ (BHX chỉ có đậu hũ nêm hoặc chiên, không có đậu hũ trắng cứng); gạo tẻ (chỉ có gạo dẻo thơm 5 kg, `bulk_only`); gạo lứt nấu chín (chỉ có gạo lứt tím sống); sữa chua Hy Lạp không đường và sữa chua trái cây ít béo (gần nhất là sữa chua ăn lốc 4 hộp, chưa đọc giá); nấm rơm đóng hộp.

**Còn lại:** cơm trắng nấu chín (`chua_kiem`). Sitemap có "Cơm nhà tiện nghi" và "Cơm nhà an tâm", cần mở để xác định có phải cơm nấu chín không. Lạc và muối (`chua_co_gia`): JSON-LD ghi giá 0.

**Lưu ý:** `sua_chua_khong_duong` và `sua_chua_co_duong` chưa có giá; cần đọc trang để điền. Một số `priceValidUntil` trong JSON-LD vẫn ghi ngày 09/11/2026 dù trang đọc ngày 10/11; bảng ghi giá trị đọc được.
