# T-111 lượt 5 — kết quả cuối, mở T-112

Ngày: 2026-11-09 · Owner: RESEARCH · Nguồn: `docs/research/sources/foodkeeper-20261109.xls` (USDA FSIS, sheet `Product`), trang sản phẩm BHX (sữa tươi, 09/11/2026).
Bản nháp: [storage-draft.json](storage-draft.json). **Vẫn ở `docs/research/`, chưa đưa vào `data/`.**

## 1. Số dòng theo status (69 nguyên liệu)

| status | Tất cả (69) | Đồ tươi (50) |
|---|---|---|
| `ok` | **9** | 4 |
| `gan_dung` | **32** | 29 |
| `uoc_tinh_vn` | **17** | 17 |
| `chua_co_nguon` | **11** | 0 |

Đồ tươi: 50 dòng, gồm thịt, cá, trứng, đậu, rau, củ (kể cả khoai tây, khoai lang, tỏi, gừng), quả, sữa; không tính `nam_rom` (đồ đóng hộp). **Không còn đồ tươi nào ở `chua_co_nguon`.** Mọi đồ tươi đều có mẹo và dấu hiệu hỏng.

Điều kiện mở T-112 (status `ok`, `gan_dung` hoặc `uoc_tinh_vn`, và có mẹo cùng dấu hiệu hỏng): **đã đạt**.

## 2. Các quyết định trong lượt 5

- **Sữa tươi (`sua_tuoi`): `ok`, `long_term: true`.** Nguồn: hướng dẫn trên bao bì, xem qua trang Bách hóa XANH (Vinamilk 180 ml, đọc 09/11/2026). Nhãn: "Để lâu (theo hạn in trên hộp)". Mẹo: "Sau khi mở: cất ngăn mát, dùng hết trong ngày." Trang chỉ ghi nơi khô ráo, thoáng mát và không có số ngày.
- **Sữa đậu nành (`sua_dau_nanh`): `uoc_tinh_vn`, `long_term: true`.** Không tìm được trang chính thức của nhãn UHT không đường (tìm kiếm 09/11/2026, không thấy Vinasoy). Nội dung như sữa tươi.
- **DOP:** 22 dòng chỉ có số lấy từ cột DOP (không có cột thường cho ngăn mát hoặc nhiệt độ phòng) được hạ xuống `gan_dung`, lý do ghi ở `source.downgrade_reason`. Dòng có cột thường giữ `ok`.
- **Nhãn độ tươi** tính từ giá trị đã lưu (cận dưới), theo xác nhận của PM.
- **Khí hậu VN:** 16 dòng rau, củ, quả có số nhiệt độ phòng đã điều chỉnh, lấy 50% cận dưới, tối thiểu 1 ngày, status `uoc_tinh_vn`. Ngăn mát và ngăn đông giữ nguyên.
- **Hợp đồng:** chấp nhận `mapping`, `tips_source`, `vn_rule`, `long_term` ở mọi dòng (mặc định `false`).

## 3. Lưu ý cho PM và Dev

- Mẹo và dấu hiệu hỏng của đồ tươi là văn bản viết tay theo kiến thức chung; FoodKeeper không có dấu hiệu hỏng. Chưa đối chiếu nguồn an toàn thực phẩm VN.
- `gan_dung` gồm 10 dòng lấy theo nhóm gần và 22 dòng chỉ có số DOP; chi tiết ở cột "Ghi chú" và `source.downgrade_reason`.
- Số ngày ngăn đông không được điều chỉnh khí hậu.

## 4. Bảng chi tiết 69 nguyên liệu

Cột "ngăn mát" và "nhiệt độ phòng" là cận dưới (ngày). "—" = không có số.

| # | ingredient_id | Tên | status | ngăn mát (cận dưới, ngày) | nhiệt độ phòng (ngày) | cấp đông (ngày) | cấp đông được | long_term | fk_id | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | uc_ga_khong_da | Ức gà, không xương, không da | gan_dung | 1 | — | 270 | có | false | 117 | Chicken parts, breast boneless |
| 2 | dui_ga_khong_da | Đùi gà, không xương, không da | gan_dung | 1 | — | 270 | có | false | 118 | Chicken parts, legs or thighs |
| 3 | thit_heo_nac_dui | Thịt heo nạc đùi | gan_dung | 7 | — | 30 | có | false | 95 | Ham fresh, uncooked, whole leg, boneless (thịt đùi heo tươi) |
| 4 | thit_heo_nac_than | Thịt heo thăn (nạc) | gan_dung | 3 | — | 120 | có | false | 67 | Pork tenderloin |
| 5 | thit_heo_ba_chi | Thịt heo ba chỉ | gan_dung | 3 | — | 120 | có | false | 74 | Nhóm gần: Pork shoulder (FoodKeeper không có ba chỉ tươi) |
| 6 | thit_heo_xay_nac | Thịt heo xay (nạc ~96%) | gan_dung | 1 | — | 90 | có | false | 73 | Pork ground |
| 7 | thit_bo_nac | Thịt bò đùi (nạc) | gan_dung | 3 | — | 120 | có | false | 36 | Beef round or rump roast (đùi bò) |
| 8 | ca_basa | Cá basa phi lê | gan_dung | 1 | — | 60 | có | false | 146 | Fatty fish; FoodKeeper ghi catfish trong nhóm này (bản ghi 120) |
| 9 | tom | Tôm sú / tôm thẻ (làm sạch) | gan_dung | 1 | — | 180 | có | false | 151 | Shrimp, crayfish |
| 10 | trung_ga | Trứng gà | gan_dung | 21 | — | — | không | false | 21 | Eggs in shell |
| 11 | dau_phu | Đậu hũ (đậu phụ) cứng | gan_dung | 7 | — | 150 | có | false | 168 | Tofu |
| 12 | com_trang | Cơm trắng (đã nấu chín) | ok | 4 | — | 180 | có | false | 178 | Cooked rice |
| 13 | sup_lo_xanh | Súp lơ xanh (bông cải xanh) | gan_dung | 3 | — | 300 | có | false | 276 | Broccoli and broccoli raab (rapini) |
| 14 | sup_lo_trang | Súp lơ trắng (bông cải trắng) | gan_dung | 3 | — | 300 | có | false | 280 | Cauliflower |
| 15 | bap_cai | Bắp cải | gan_dung | 7 | — | 300 | có | false | 278 | Cabbage |
| 16 | ca_rot | Cà rốt | gan_dung | 14 | — | 300 | có | false | 279 | Carrots, parsnips |
| 17 | ca_tim | Cà tím | uoc_tinh_vn | 4 | 1 | 180 | có | false | 284 | Eggplant |
| 18 | ca_thu | Cá thu (khúc) | gan_dung | 1 | — | 60 | có | false | 146 | Fatty fish (mackerel = cá thu) |
| 19 | muc_ong | Mực ống (làm sạch) | gan_dung | 1 | — | 180 | có | false | 152 | Squid |
| 20 | ca_ro_phi | Cá rô phi (phi lê) | gan_dung | 1 | — | 180 | có | false | 144 | Nhóm gần: Lean fish (cá trắng); rô phi không được liệt kê |
| 21 | sua_chua_khong_duong | Sữa chua Hy Lạp không đường | gan_dung | 7 | — | 30 | có | false | 33 | Yogurt |
| 22 | tieu_den | Tiêu đen (hạt) | chua_co_nguon | — | — | — | — | false | — | Black pepper: không có số bảo quản |
| 23 | lac | Lạc (đậu phộng) sống | gan_dung | 360 | 28 | 720 | có | false | 442 | Peanuts, no shell |
| 24 | vung | Vừng (mè) trắng | ok | — | 1825 | — | — | false | 613 | Sesame seeds |
| 25 | bun_pho_nau_chin | Bún/phở tươi đã luộc | gan_dung | 3 | — | 30 | có | false | 177 | Nhóm gần: Cooked pasta (mì nấu chín) |
| 26 | khoai_lang | Khoai lang (củ) | uoc_tinh_vn | — | 15 | 300 | có | false | 297 | Nhóm gần: Potatoes (FoodKeeper không có khoai lang: dòng 422 trống) |
| 27 | khoai_tay | Khoai tây (củ) | uoc_tinh_vn | — | 15 | — | — | false | 297 | Potatoes; số cấp đông của FoodKeeper áp dụng cho khoai đã nấu nên bỏ |
| 28 | duong | Đường trắng (tinh luyện) | ok | — | không giới hạn | — | — | true | 240 | Sugar granulated |
| 29 | dau_an | Dầu ăn (đậu nành) | chua_co_nguon | — | — | — | — | false | — | Canola oil: dòng trống |
| 30 | nuoc_mam | Nước mắm | chua_co_nguon | — | — | — | — | false | — | Không có dòng nước mắm |
| 31 | xi_dau | Xì dầu (nước tương, có lúa mì) | chua_co_nguon | — | — | — | — | false | — | Soy sauce: dòng trống |
| 32 | muoi | Muối ăn | ok | — | không giới hạn | — | — | true | 468 | Salt, table |
| 33 | toi | Tỏi (củ) | uoc_tinh_vn | 3 | 15 | 30 | có | false | 285 | Garlic |
| 34 | gung | Gừng tươi | uoc_tinh_vn | 14 | 1 | 180 | có | false | 286 | Ginger root |
| 35 | hanh_tay | Hành tây | uoc_tinh_vn | 60 | 15 | 300 | có | false | 294 | Onions, yellow/white |
| 36 | hanh_la | Hành lá | uoc_tinh_vn | 7 | 15 | 300 | có | false | 295 | Onions, spring or green |
| 37 | ca_chua | Cà chua | gan_dung | 4 | — | 180 | có | false | 296 | Nhóm gần: Peppers (FoodKeeper Tomatoes chỉ ghi 'khi chín', không có số ngày) |
| 38 | cai_ngot | Cải ngọt (cải bẹ xanh, PROXY) | gan_dung | 2 | — | 300 | có | false | 275 | Nhóm gần: Bok choy |
| 39 | su_su | Su su (quả) | uoc_tinh_vn | 4 | 1 | 300 | có | false | 302 | Nhóm gần: Squash, summer and zucchini |
| 40 | bi_xanh | Bí xanh (PROXY bí ngòi) | uoc_tinh_vn | 4 | 1 | 300 | có | false | 302 | Nhóm gần: Squash, summer and zucchini |
| 41 | dau_lang | Đậu lăng khô | chua_co_nguon | — | — | — | — | false | — | Lentils dried: dòng trống |
| 42 | dau_xanh | Đậu xanh khô (hạt) | ok | 365 | 365 | 365 | có | false | 680 | Mung bean, dry, food-grade bags |
| 43 | sua_dau_nanh | Sữa đậu nành không đường | uoc_tinh_vn | — | — | — | — | true | — | Soy milk: FoodKeeper chỉ ghi ngày in trên bao bì, không có số; chưa kiểm được trang sản phẩm BHX |
| 44 | gao_lut_nau_chin | Gạo lứt nấu chín | gan_dung | 4 | — | 180 | có | false | 178 | Nhóm gần: Cooked rice (gạo lứt nấu chín) |
| 45 | tempeh | Tempeh (đậu nành lên men) | gan_dung | 3 | — | 180 | có | false | 328 | FoodKeeper ghi thời gian này áp dụng cho tempeh đã nấu |
| 46 | nuoc_mam_chay | Nước mắm chay (thay bằng nước tương) | chua_co_nguon | — | — | — | — | false | — | Không có dòng tương ứng |
| 47 | rau_den | Rau dền (lá) | gan_dung | 1 | — | 300 | có | false | 287 | Nhóm gần: Greens |
| 48 | gia_do | Giá đỗ (mầm đậu xanh) | gan_dung | 5 | — | — | — | false | 549 | Bean sprouts |
| 49 | nam_rom | Nấm rơm đóng hộp (đã ráo nước) | chua_co_nguon | — | — | — | — | false | — | Nấm đóng hộp: không tính là đồ tươi (PM) |
| 50 | dau_co_ve | Đậu cô ve (đậu que xanh) | gan_dung | 3 | — | 240 | có | false | 273 | Beans and peas (green, wax) |
| 51 | dua_chuot | Dưa chuột (có vỏ) | gan_dung | 4 | — | — | không | false | 283 | Cucumbers |
| 52 | dau_bap | Đậu bắp | uoc_tinh_vn | 2 | 1 | 300 | có | false | 293 | Okra |
| 53 | cai_thao | Cải thảo | gan_dung | 7 | — | 300 | có | false | 278 | Nhóm gần: Cabbage |
| 54 | chuoi | Chuối chín | ok | 3 | — | 60 | có | false | 251 | Bananas (số áp dụng cho chuối chín) |
| 55 | cam | Cam sành/cam ngọt | uoc_tinh_vn | 10 | 5 | — | không | false | 256 | Citrus fruit (orange) |
| 56 | oi | Ổi | ok | 2 | — | — | không | false | 262 | Guava (số áp dụng cho ổi chín) |
| 57 | dua_hau | Dưa hấu | uoc_tinh_vn | 3 | 1 | 360 | có | false | 495 | Watermelon |
| 58 | du_du | Đu đủ chín | uoc_tinh_vn | 7 | 1 | 180 | có | false | 265 | Papaya, mango, feijoa, passionfruit, casaha melon |
| 59 | tao | Táo | uoc_tinh_vn | 28 | 10 | — | — | false | 248 | Apples; số cấp đông của FoodKeeper áp dụng cho táo đã nấu nên bỏ |
| 60 | xoai | Xoài chín | uoc_tinh_vn | 7 | 1 | 180 | có | false | 265 | Papaya, mango, feijoa, passionfruit, casaha melon |
| 61 | dua_thom | Dứa (thơm) | ok | 5 | — | 300 | có | false | 267 | Pineapple (số áp dụng cho dứa chín) |
| 62 | buoi | Bưởi (proxy: bưởi trắng) | uoc_tinh_vn | 10 | 5 | — | không | false | 256 | Nhóm gần: Citrus (bưởi không phải grapefruit) |
| 63 | sua_tuoi | Sữa tươi nguyên kem không đường | ok | — | — | — | — | true | BHX/bao bì | Sữa UHT trên bao bì BHX: chỉ ghi nơi khô ráo, thoáng mát, dùng hết sau khi mở; không có số ngày. FoodKeeper Milk (27) chỉ ghi ngày in trên bao bì |
| 64 | sua_chua_co_duong | Sữa chua trái cây ít béo (chất tạo ngọt ít calo) | gan_dung | 7 | — | 30 | có | false | 33 | Yogurt |
| 65 | dau_do | Đậu đỏ khô | chua_co_nguon | — | — | — | — | false | — | Không có dòng đậu đỏ khô có số liệu |
| 66 | gao_nep | Gạo nếp (khô) | chua_co_nguon | — | — | — | — | false | — | Rice white: dòng trống |
| 67 | gao_te | Gạo tẻ (sống) | chua_co_nguon | — | — | — | — | false | — | Rice white: dòng trống |
| 68 | gao_lut | Gạo lứt (sống) | chua_co_nguon | — | — | — | — | false | — | Rice brown: dòng trống |
| 69 | rau_muong | Rau muống (PROXY: rau bina) | gan_dung | 1 | — | 300 | có | false | 287 | Nhóm gần: Greens |
