# Ghi chú: gói nhỏ và quy cách giá (07/11/2026)

Owner: RESEARCH · Yêu cầu: session chính (Dev T-089 phát hiện "trả tại quầy" cao gấp ~2,5 lần chi phí món ăn).
Chỉ sửa `data/prices.json` và `docs/research/`. Bản trước: `scratchpad/prices_before_small_packs.json` và `prices_before_small_packs2.json`.

## 1. Kết luận ngắn

- Nguyên nhân chính là quy cách: hầu hết dòng `cho_khac` là gói 500–1.000 g (kể cả rau, dầu, đường, nước mắm) trong khi một tuần chỉ dùng vài chục đến vài trăm gram. Engine làm tròn lên theo gói nên phần dư lớn.
- Đã đổi quy cách của 38 dòng (11 dòng đạm, 27 dòng rau/gia vị/trái cây), và sửa giá cơm 5 kg (sai nhiều nhất, xem mục 4).
- Tỷ lệ "trả tại quầy / chi phí món ăn" trên 16 hồ sơ sau khi đổi: 1,25–1,97 (hồ sơ p01: 2,5 → 1,73). Phần còn lại là gia vị và dầu bán theo chai, cần quyết định của PM (mục 6).
- **Bò:** đã đọc trực tiếp Bách hóa Xanh. Hiện không có gói "ức bò" trong dữ liệu, chỉ có `thit_bo_nac` (Thịt bò đùi nạc).

## 2. Thịt bò: nguồn đọc trực tiếp

Nguồn: <https://www.bachhoaxanh.com/thit-bo>, đọc ngày 07/11/2026 (không đăng nhập).

| Sản phẩm | Quy cách | Giá hiển thị | Ghi chú |
|---|---|---|---|
| Đùi bò | 200 g | 58.929 ₫ | Flash sale, giá gốc 63.400 ₫ |
| Nạm bò | 200 g | 42.849 ₫ | Flash sale, giá gốc 49.000 ₫ (không dùng: khác cắt) |
| Bắp bò | 200 g | 49.800 ₫ | Flash sale, giá gốc 55.800 ₫ (không dùng: khác cắt) |

Đã thêm dòng `thit_bo_nac` · `bach_hoa_xanh` · 200 g · 58.929 ₫ (giá flash sale, có thể đổi sau khi hết khuyến mãi).

Dòng `cho_khac` của `thit_bo_nac` đổi từ 500 g / 220.000 ₫ thành 300 g / 90.000 ₫ (ước tính theo giá BHX: 58.929 ₫/200 g ≈ 294.600 ₫/kg, × 0,3 kg ≈ 88.400 ₫, làm tròn). Giá cũ 440.000 ₫/kg cao hơn BHX khoảng 50%.

## 3. Đổi quy cách dòng `cho_khac` (ước tính, chưa khảo sát)

Quy tắc đợt 1 (nguyên liệu đắt ≥ 400 g và ≥ 10.000 ₫/100 g): gói 200–300 g, giá = giá cũ × (gói mới / gói cũ) × 1,1, làm tròn 1.000 ₫.

| Nguyên liệu | Cũ | Mới |
|---|---|---|
| Thịt bò đùi | 500 g · 220.000 | 300 g · 90.000 |
| Ức gà không xương | 500 g · 95.000 | 300 g · 63.000 |
| Đùi gà không xương | 500 g · 80.000 | 300 g · 53.000 |
| Thịt heo thăn | 500 g · 80.000 | 300 g · 53.000 |
| Cá thu khúc | 500 g · 130.000 | 300 g · 86.000 |
| Mực ống | 500 g · 175.000 | 250 g · 96.000 |
| Tôm | 500 g · 185.000 | 250 g · 102.000 |
| Cá basa phi lê | 500 g · 65.000 | 300 g · 43.000 |
| Cá rô phi phi lê | 600 g · 100.000 | 300 g · 55.000 |
| Lạc sống | 500 g · 50.000 | 200 g · 22.000 |
| Sữa chua Hy Lạp không đường | 500 g · 70.000 | 200 g · 31.000 |

Quy tắc đợt 2 (rau, trái cây, gia vị): gói ≥ 1.000 g → 500 g; nước mắm, xì dầu, muối, nước mắm chay 500 g → 250 g. Áp dụng cho 27 dòng: bắp cải, cà rốt, cà chua, hành tây, khoai lang, khoai tây, su su, bí xanh, cải thảo, dầu ăn (1 L → 500 g), đường (1 kg → 500 g), nước mắm, xì dầu, muối, nước mắm chay, sữa đậu nành, gạo lứt nấu chín, chuối, cam, ổi, dưa hấu, đu đủ, táo, xoài, dứa, bưởi.

Chưa đổi: `tempeh` (200 g), `vung` (200 g), `thit_heo_*` (đã có gói BHX), `sua_tuoi` (720 g), `dau_phu` (300 g), `trung_ga` (500 g, 10 quả), `tieu_den` (50 g), `toi` (100 g), `hanh_la` (100 g), `gung` (100 g).

**Đây đều là ước tính.** Quy cách 200–500 g chưa được kiểm trên kệ của cửa hàng nào, ngoại trừ thịt bò (mục 2) và thịt heo ở BHX (đã có từ trước). Cần T-042b để xác minh.

## 4. Cơm (`com_trang`): sửa giá sai

Dòng cũ: 5.000 g cơm nấu chín / 160.000 ₫ (32 ₫/g). Vừa không ai bán gói cơm nấu chín 5 kg, vừa giá cao gấp ~4 lần giá gạo quy đổi: gạo tẻ ~20.000 ₫/kg, nở ~2,5 lần, nên cơm nấu chín ≈ 8.000 ₫/kg.

Dòng mới: 1.000 g cơm nấu chín quy đổi từ gạo / 12.000 ₫ (12 ₫/g, có lề). Đây là ước tính có căn cứ, không phải giá khảo sát.

**Cần quyết định:** nên có nguyên liệu gạo tẻ sống (gói 1–5 kg) và quy đổi cơm nấu chín ra gạo sống trong engine. Hiện chưa có gạo tẻ trong `ingredients.json`; thêm được cần đổi công thức, nên để PM/Dev.

## 5. Kiểm tra

- `npm run validate-data`: 0 lỗi, 1 cảnh báo (kcal `rau_den`, đã ghi).
- `npm run export-golden`: 55 tệp.
- `npm test`: 173/173.
- `engine-report` (C#): **16/16** hồ sơ đạt 7/7, 112/112 ngày, sàn protein 100%, dải calo 100%.

Tỷ lệ "trả tại quầy / chi phí món ăn" (C#, sau đợt 2):

| Hồ sơ | Món ăn | Tại quầy | Tỷ lệ |
|---|---|---|---|
| p01 | 603.000 | 1.046.000 | 1,73 |
| p05 (chay) | 346.000 | 507.000 | 1,47 |
| p09 (lò vi sóng) | 546.000 | 830.000 | 1,52 |
| p11 (4 người) | 1.172.000 | 1.519.000 | 1,30 |
| p14 (3 người) | 1.055.000 | 1.323.000 | 1,25 |
| p02 (1.350 kcal) | 409.000 | 807.000 | 1,97 |

Trước đợt này p01: 582.000 → 1.455.000 (2,5).

## 6. Việc còn lại và câu hỏi cho PM

1. **Gia vị và dầu bán theo chai.** Dù quy cách đã nhỏ hơn, dầu ăn, nước mắm, đường vẫn được tính trọn gói. AC4 (US-4.1) đã có "nhà có sẵn" để loại các món này khỏi chi phí. Dev cần xác nhận mục "nhà có sẵn" mặc định tắt các gia vị này trong ước tính tại quầy. PM quyết định.
2. **Cơm nấu chín** (mục 4): cần gạo sống trong dữ liệu.
3. **Ức bò:** không có trong dữ liệu. Nếu PM muốn có, cần thêm nguyên liệu (kèm nguồn USDA) và giá.
4. **Giá BHX cho đùi bò** là giá flash sale 07/11/2026; giá gốc 63.400 ₫. Nên khảo sát lại sau khi khuyến mãi kết thúc.
5. Quy cách 200–500 g của các dòng `cho_khac` là giả định. T-042b cần kiểm trên BHX, WinMart, Co.opmart.
