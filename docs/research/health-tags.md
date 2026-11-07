# Tiêu chí và gắn thẻ xu hướng sức khỏe (T-059)

Ngày: 07/11/2026 · Owner: RESEARCH · Căn cứ: `docs/pm/prd.md` D-HLT-01 và D-ONB-03, `docs/pm/backlog.md` T-059 và T-073.
Chỉ sửa `data/` và `docs/research/`. Không dùng tên bệnh làm thẻ; không viết tuyên bố y tế.

## 1. Danh sách thẻ

Bốn thẻ hiện trên UI (danh sách trắng, D-ONB-03):

| id | Nhãn UI | Trạng thái |
|---|---|---|
| `nhieu_xo` | Nhiều chất xơ | Định nghĩa lại ở T-059 (trước đây không có tiêu chí) |
| `it_duong` | Ít đường | Mới |
| `tot_cho_tim` | Tốt cho tim mạch | Mới |
| `it_beo` | Ít béo | Định nghĩa lại ở T-059 |

Thẻ nội bộ (không hiện trên UI, giữ nguyên, không đổi trong lượt này): `giau_dam`, `omega3`, `chay`, `low_carb`.
`omega3` là một tiêu chí cấu thành `tot_cho_tim` (xem mục 3). Danh sách `health_tags` đầy đủ sau lượt này chỉ gồm 8 id ở trên; không có id nào khác.

## 2. Tiêu chí (tính trên khẩu phần chuẩn)

Mỗi giá trị được tính từ `grams` (gram ăn được của khẩu phần chuẩn) × `per_100g` của từng nguyên liệu. kcal tính theo 4/4/9 khi cần tỷ lệ năng lượng.

| Thẻ | Điều kiện (đều phải đúng) | Nguồn / lý do |
|---|---|---|
| `nhieu_xo` | Xơ ≥ **5 g** mỗi khẩu phần | FDA quy định "nguồn xơ cao" (high fiber) dựa trên 20% Daily Value (DV, 28 g) ≈ 5,6 g mỗi khẩu phần, 21 CFR 101.54. Làm tròn xuống 5 g để dễ kiểm. Lệch 0,6 g so với ngưỡng FDA; PM có thể chọn 5,6 g nếu muốn khớp đúng |
| `it_beo` | Chất béo cung cấp ≤ **30%** tổng kcal (fat g × 9 / kcal) | WHO: tổng chất béo ≤ 30% năng lượng (guideline về chất béo và carbohydrate, 2023) |
| `it_duong` | (a) không có đường trắng thêm vào (`duong` > 0 g); (b) carb ≤ **45 g**; (c) xơ ≥ **4 g** | (a) WHO: đường tự do < 10% năng lượng; món không thêm đường là điều kiện đơn giản nhất. (b), (c) là ngưỡng **Research đặt** cho một bữa, chưa có chuẩn y khoa đã kiểm: cần PM và chuyên gia dinh dưỡng xác nhận |
| `tot_cho_tim` | (a) có cá béo (`ca_thu`) **hoặc** xơ ≥ 5 g; (b) không chiên ngập dầu: dầu ăn ≤ 20 g hoặc không có bước chiên/rán; (c) không có thịt chế biến sẵn; (d) không có nguồn chất béo bão hòa đáng kể (thịt ba chỉ) | AHA khuyến nghị ăn cá giàu chất béo không bão hòa ít nhất 2 lần/tuần (nguồn thứ cấp, xem mục 6). (d) là **đại diện** cho "chất béo chủ yếu từ dầu thực vật" vì kho nguyên liệu không có số liệu chất béo bão hòa |

Ghi chú về (b) và (c) của `tot_cho_tim`: trong kho hiện tại không có xúc xích, chả, lạp xưởng nên (c) luôn đúng; nếu sau này thêm thịt chế biến sẵn, cần thêm vào danh sách.

Ghi chú về `it_duong` (a): chỉ `duong` (đường trắng) được tính là đường thêm. `sua_chua_co_duong` (chất tạo ngọt ít calo, không có đường trong kho) không bị tính là đường thêm; WHO cũng không xếp chất tạo ngọt vào đường tự do. Nếu PM muốn loại cả món có chất tạo ngọt, cần thêm điều kiện riêng.

## 3. Kết quả

Đếm số món mang từng thẻ (311 công thức, gồm 21 `dessert`, cùng với trọn suất, `main`, `soup`, `side_veg`, `carb_base` và snack):

| Thẻ | Trước T-059 | Sau T-059 | Đạt ≥ 10 món |
|---|---|---|---|
| `nhieu_xo` | 116 | **67** | có |
| `it_duong` | 15 | **48** | có |
| `tot_cho_tim` | 0 | **73** | có |
| `it_beo` | 57 | **143** | có |

`GET /v1/reference` sẽ hiện đủ 4 lựa chọn (AC: mỗi thẻ ≥ 10 món). Số cũ không so sánh được vì tiêu chí cũ không có văn bản; số mới đã tính theo đúng mục 2.

**Tác động lên engine C# (đã chạy `engine-report`, không sửa engine):** kết quả 14/16 hồ sơ đạt 7/7 (trước đó 15/16). `p01_nu_giam_mo_vua` (có sở thích `nhieu_xo`) rơi từ 7/7 xuống 4/7 ngày đạt protein. Nguyên nhân: ngưỡng xơ 5 g làm số món `nhieu_xo` giảm từ 116 xuống 67, nên điểm mềm của sở thích này ít món để chọn hơn. Ngưỡng khác nếu PM muốn đổi: xơ ≥ 4 g → 97 món; ≥ 3 g → 136 món; ≥ 2,8 g (FDA "nguồn xơ", 10% DV) → 145 món. Chưa đổi; cần PM quyết định ngưỡng, rồi chạy lại engine-report.

Thẻ `omega3` vẫn gắn 10 món có `ca_thu`. Thẻ `giau_dam`, `chay`, `low_carb` không đổi.

Tráng miệng (T-058) được gắn thẻ theo cùng tiêu chí; ví dụ `dessert_chuoi_qua` (xơ 3,1 g) không đạt `nhieu_xo` và không đạt `it_duong` (xơ < 4 g).

## 4. Bảng kiểm 10 món mẫu

Mỗi dòng: nguyên liệu và gram; tổng tính theo mục 2. Các phép cộng được tính bằng script theo đúng công thức; tôi đã đối chiếu tay món `sang_khoai_lang_thit_bam_trung` (kcal 399,6; carb 37,98; xơ 5,66; chất béo 29%) và `dessert_chuoi_qua` (kcal 106,8; carb 27,36; xơ 3,12).

| # | id | Loại | Nguyên liệu (g) | kcal | Carb g | Xơ g | Béo % kcal | Thẻ đạt |
|---|---|---|---|---|---|---|---|---|
| 1 | `sang_khoai_lang_thit_bam_trung` | trọn suất | khoai lang 180, thịt heo xay 80, trứng 100, hành lá 10, nước mắm 5 | 400 | 38,0 | 5,7 | 29 | nhieu_xo, it_duong, tot_cho_tim, it_beo |
| 2 | `main_dau_hu_nuong_nam_chay` | món chính | đậu hũ 150, nấm rơm 80, cà tím 100, xì dầu 5, dầu ăn 15 | 402 | 14,0 | 8,5 | 65 | nhieu_xo, it_duong, tot_cho_tim |
| 3 | `ca_thu_nuong_muoi_tieu` | trọn suất | cá thu 150, su su 100, muối 2, tiêu 1, tỏi 3 | 333 | 6,1 | 2,0 | 57 | omega3, low_carb, tot_cho_tim |
| 4 | `canh_bap_cai_nam_rom_chay` | canh | bắp cải 150, nấm rơm 60, tỏi 3, muối 1, tiêu 1 | 64 | 13,1 | 5,6 | 9 | nhieu_xo, it_duong, tot_cho_tim, it_beo |
| 5 | `dau_co_ve_xao_toi` | rau | đậu cô ve 150, tỏi 3, dầu ăn 5, muối 1 | 95 | 11,4 | 4,1 | 51 | it_duong |
| 6 | `dessert_chuoi_qua` | tráng miệng | chuối 120 | 107 | 27,4 | 3,1 | 3 | it_beo |
| 7 | `sua_chua_vung` | tráng miệng | sữa chua Hy Lạp không đường 150, vừng 5, đường 3 | 129 | 9,6 | 0,6 | 21 | giau_dam (nội bộ), it_beo; **không** it_duong do có đường thêm |
| 8 | `ld_lc_dau_phu_ga_xao_dau` | trọn suất | ức gà 150, đậu hũ 150, su su 100, dầu ăn 20, tỏi 5, xì dầu 10 | 585 | 10,8 | 5,3 | 56 | nhieu_xo, it_duong, tot_cho_tim |
| 9 | `khoai_lang_hap` | cơm/khoai | khoai lang 150 | 129 | 30,2 | 4,5 | 1 | it_duong, it_beo |
| 10 | `sn_che_dau_xanh` | bữa phụ | đậu xanh 30, đường 10 | 143 | 28,8 | 4,9 | 2 | it_beo; **không** it_duong do có đường thêm |

Ghi chú: món 3 không đạt `it_beo` (57%) dù có cá béo; đây là kết quả đúng theo tiêu chí, không phải lỗi. Món 5 không đạt `nhieu_xo` và `tot_cho_tim` vì xơ 4,1 g < 5 g.

## 5. Đề xuất câu chữ UI (cho `content/i18n/vi.json`, key `health.*`)

Mỗi thẻ có hai key: `health.<id>` là nhãn, `health.<id>.desc` là mô tả ngắn.

| Nhãn key | Nhãn | Mô tả key (`.desc`) · nội dung |
|---|---|---|
| `health.nhieu_xo` | Nhiều chất xơ | Ưu tiên món có nhiều rau, đậu và ngũ cốc nguyên cám |
| `health.it_duong` | Ít đường | Ưu tiên món không thêm đường và ít tinh bột |
| `health.tot_cho_tim` | Tốt cho tim mạch | Ưu tiên món có cá béo, nhiều xơ, ít chiên ngập dầu |
| `health.it_beo` | Ít béo | Ưu tiên món có ít chất béo trong tổng năng lượng |

Miễn trừ (dùng chung cho cả 4 lựa chọn, key `health.disclaimer`): "Các lựa chọn này chỉ là ưu tiên mềm khi chọn món, không phải lời khuyên y tế. Hỏi bác sĩ hoặc chuyên gia dinh dưỡng nếu bạn cần chế độ ăn riêng."

Những key này đã đưa vào `content/i18n/vi.json` (T-055).

## 6. Nguồn

- FDA, 21 CFR 101.54 (nutrient content claims, "high"): <https://www.law.cornell.edu/cfr/text/21/101.54>. Truy cập 07/11/2026. Kết quả tìm kiếm không mở được toàn văn mục (b) để xác nhận ngưỡng 20% DV; ngưỡng 5,6 g là tính từ DV 28 g.
- WHO, Healthy diet (fact sheet) và cập nhật hướng dẫn chất béo, carbohydrate và đường tự do (2023): <https://www.who.int/publications/m/item/healthy-diet-factsheet394> và <https://www.who.int/news/item/17-07-2023-who-updates-guidelines-on-fats-and-carbohydrates>. Truy cập 07/11/2026. Số 30% (chất béo) và 10% (đường tự do) được xác nhận qua trang WHO khu vực và các bản tóm tắt; cần đối chiếu bản chính trước khi trích dẫn cho bên ngoài.
- AHA, khuyến nghị ăn cá giàu chất béo không bão hòa ít nhất 2 lần/tuần: kết quả tìm kiếm lấy từ Mayo Clinic (<https://www.mayoclinic.org/diseases-conditions/heart-disease/in-depth/omega-3/art-20045614>), không phải trang AHA. Truy cập 07/11/2026. Cần xác nhận trên trang AHA.
- Dữ liệu thành phần: USDA FoodData Central (xem `data/ingredients.json`).

## 7. Giới hạn

- Không có số liệu chất béo bão hòa, đường riêng (ngoài `duong`) hay natri trong kho. Vì vậy `tot_cho_tim` (d) và `it_duong` (a) dùng đại diện: thịt ba chỉ và đường thêm vào.
- Xơ của một số nguyên liệu không có trong bản ghi USDA (ví dụ rau dền, bưởi): ghi 0, nên các món đó có thể bị đánh giá thấp về `nhieu_xo`.
- Ngưỡng carb 45 g và xơ 4 g của `it_duong` và ngưỡng 5 g của `nhieu_xo` chưa được kiểm bằng nghiên cứu lâm sàng; đây là quyết định của Research để PM duyệt.
- Không có thẻ nào liên quan tiểu đường hay bệnh lý; theo D-HLT-01.

## 8. Cách tái tạo

Script tính: `scratchpad/health_calc.mjs` (không nằm trong repo; logic đã mô tả ở mục 2). Chạy lại sau khi đổi dữ liệu để cập nhật 4 thẻ.
