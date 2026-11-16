# Kiểm mẫu giá Bách hóa Xanh — đợt dữ liệu D2 (T-054c, L-14)

Ngày: 2026-11-09 · Owner: RESEARCH · Người kiểm: Research, bằng trình duyệt (mỗi trang mở một lần, đọc thẻ sản phẩm; không tải hàng loạt).

## 1. Kết quả tóm tắt

- **Số dòng BHX trong `data/prices.json`: 4**, không phải 15. Các dòng `cho_khac` (69 dòng) không có `source_url`, nên không kiểm được trên trang nào. Vì vậy **không kiểm được "ít nhất 15 dòng BHX khác"** như PM yêu cầu. Nếu PM muốn kiểm 15 dòng thì cần thêm dòng BHX vào dữ liệu trước (việc khác, không làm trong đợt này).
- **Kiểm được 4/4 dòng BHX.** Sai 1 dòng: `thit_heo_nac_dui` (đã sửa). Ngưỡng PM "sai hơn 3/15" không áp dụng được vì mẫu không đủ 15. Nếu tính theo tỉ lệ 1/4 thì con số cao, cần PM xem.
- **Lỗi L-14 (thịt heo xay) được rút lại.** Tôi đã đọc nhầm thẻ sản phẩm liền kề. Dòng `thit_heo_xay_nac` đúng và không sửa.

## 2. Bảng từng dòng

| ingredient_id | Dòng trong `prices.json` (trước) | Trang đối chiếu (ngày 09/11/2026) | Kết quả | Thay đổi |
|---|---|---|---|---|
| `thit_heo_xay_nac` | 22.478 ₫, "thịt heo xay C.P 200 g", `/thit-heo`, khảo sát 06/11 | Trang sản phẩm `/thit-heo/thit-heo-xay-cp-khay-200g`: khay 200 g, giá khuyến mãi 22.477,8 ₫, giá gốc 25.500 ₫ (dữ liệu có cấu trúc trên trang). Mô tả sản phẩm: "Làm từ nạc heo tươi, được xay mịn vừa phải" | **Đúng** giá và quy cách. Chưa xác minh tỉ lệ nạc (spec ~96%) vì trang không ghi | Không sửa |
| `thit_heo_nac_dui` | 33.300 ₫, "thịt đùi heo C.P 300 g (KM)", khảo sát 06/11 | Thẻ "Thịt đùi heo C.P", 300 g: **34.500 ₫**, giá gốc 35.700 ₫ (-3%). Liên kết thẻ: `/thit-heo/thit-dui-heo-1kg` | **Sai** (33.300 ≠ 34.500). Tên C.P khớp nhưng không ghi "nạc" nên chưa xác minh tỉ lệ nạc | **Sửa giá 33.300 → 34.500**, `surveyed_on` 06/11 → 09/11 |
| `thit_heo_ba_chi` | 42.300 ₫, "ba rọi heo C.P 300 g (KM)", khảo sát 06/11 | Thẻ "Ba rọi heo C.P", 300 g: **42.300 ₫**, giá gốc 46.200 ₫ (-8%). Liên kết `/thit-heo/ba-roi-heo-1kg` | **Đúng** | Không sửa (ngày khảo sát vẫn 06/11, chưa cập nhật) |
| `thit_bo_nac` | 58.929 ₫, "Đùi bò 200 g (giá flash sale, giá gốc 63.400 ₫)", `/thit-bo`, khảo sát 07/11 | Thẻ "Đùi bò" 200 g, giá flash sale **58.929 ₫**, giá gốc 63.400 ₫ (-7%). Liên kết `/thit-bo/dui-bo-viet-nam-tui-1kg` | **Đúng** với thẻ liên kết. Lưu ý: cùng trang còn một dòng "Đùi bò 54.459 ₫/200 g (-14%)" trong văn bản trang; chưa xác định được có phải cùng sản phẩm hay không | Không sửa; cần xác nhận dòng 54.459 ₫ |

## 3. Vấn đề đã rút lại

Trong lượt 2 tôi ghi "giá 22.478 ₫ thuộc Ba rọi rút sườn heo 200 g" và đề xuất kiểm dòng `thit_heo_xay_nac` (L-14). Kiểm tra lại: nguyên nhân là **đọc văn bản trang theo thứ tự, làm lẫn thẻ liền kề**. Thẻ "Ba rọi rút sườn heo" thực tế có giá 47.600 ₫/400 g. Dòng khay 22.478 ₫ thuộc "Thịt heo xay CP khay 200 g". Đã sửa ghi chú trong `price-sources-feasibility.md` và `price-observations-log.md`.

## 4. Vấn đề chưa giải quyết (cần PM)

1. **Mẫu quá nhỏ:** chỉ 4 dòng BHX. Kiểm 15 dòng BHX cần thêm dòng vào dữ liệu, hoặc PM chấp nhận mẫu hiện có.
2. **69 dòng `cho_khac` không có `source_url`** và nhãn "(ước tính)" ở nhiều dòng. Không kiểm được. Đây là rủi ro lớn hơn lỗi trên 1 dòng.
3. **Quy ước giá:** dòng dùng giá khuyến mãi (flash sale hoặc KM). Nên ghi rõ trong `prices.json` là "giá bán hôm khảo sát", và có trường giá gốc nếu cần.
4. **Tỉ lệ nạc** của `thit_heo_nac_dui` và `thit_heo_xay_nac` chưa xác minh từ trang.

## 5. Việc đã làm trong `data/`

- `data/prices.json`: dòng `thit_heo_nac_dui` giá 33.300 → 34.500 ₫, `surveyed_on` 2026-11-09. Chỉ sửa dòng này.
- Thay đổi này làm đổi `data_version`. Theo PM, Dev regen golden một lần sau khi có tất cả thay đổi dữ liệu của đợt.

## 6. T-054d (giá thường, L-15, L-16) — 09/11/2026

**Quy tắc giá:** lưu giá thường (giá gạch ngang trên trang), không lưu giá khuyến mãi, để ngân sách không dao động theo KM (ADR-002). Dòng BHX đã đổi:

| ingredient_id | Trước | Sau (giá thường) | Ghi chú |
|---|---|---|---|
| thit_heo_xay_nac | 22.478 ₫ (KM) | 25.500 ₫ | Trang sản phẩm thit-heo-xay-cp-khay-200g, giá gốc 25.500 ₫ |
| thit_heo_nac_dui | 34.500 ₫ (KM, sửa ở T-054c từ 33.300) | 35.700 ₫ | Thẻ Thịt đùi heo C.P 300 g, giá gốc 35.700 ₫ |
| thit_heo_ba_chi | 42.300 ₫ (KM) | 46.200 ₫ | Thẻ Ba rọi heo C.P 300 g, giá gốc 46.200 ₫ |
| thit_bo_nac | 58.929 ₫ (flash sale) | 63.400 ₫ | Thẻ Đùi bò 200 g, giá gốc 63.400 ₫; ghi flash 58.929 ₫ trong nhãn. Dòng 54.459 ₫ vẫn chưa xác định |

**L-15:** 69 dòng `cho_khac` có trường `source_note`. 25 dòng trỏ tới khoảng tham khảo `docs/research/vn-grocery-prices.md` (theo số mục, 06/11/2026). 44 dòng ghi "chưa có nguồn". Hai dòng lệch khoảng tham khảo, ghi rõ trong ghi chú: `thit_bo_nac` (150.000 ₫/500 g so với 200.000–260.000 ₫) và `gao_te` (110.000 ₫/5 kg so với 140.000–180.000 ₫). Dòng `com_trang` lệch với giá gạo mục #41. Đề xuất để Dev đưa `source_note` (bắt buộc) vào validator.

**L-16:** `data/stores.json` đặt `price_survey_date` = null cho WinMart và Co.opmart (không có dòng giá nào). Chuỗi UI `price.estimate_not_surveyed` = "Giá ước lượng, chưa khảo sát tại cửa hàng này" thêm vào `content/i18n/vi.json` (ARB: `priceEstimateNotSurveyed`).

**Chưa làm:** số liệu tham khảo ở vn-grocery-prices.md có nhiều khoảng chưa khớp; cần đối chiếu lại khi có khảo sát thật.
