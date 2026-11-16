# Phân loại nguyên liệu: mua theo ngày hay mua theo tuần

Ngày: 2026-11-16 · Owner: RESEARCH · Cập nhật theo PM (D-SHP-07, PRD §10). Nguồn số: `docs/research/storage-draft.json`.
Dữ liệu kết quả mong đợi cho test: `docs/research/ingredient-storage-groups.json` (tên trường giữ theo hợp đồng `storage.json`; engine suy ra nhóm mua từ `storage.json`, không tạo file thứ hai).

## 1. Tóm tắt

| Nhóm (`buy_group`) | Số nguyên liệu |
|---|---|
| Tươi, mua theo ngày (`buy_by_day`) | 35 |
| Bảo quản lâu, mua theo tuần (`stock_buy_by_week`) | 34 |
| Chưa phân loại (thiếu số liệu) (`unclassified`) | 0 |
| **Tổng** | **69** |

## 2. Quy tắc

1. Thịt, cá → `buy_by_day` (ngăn mát 1–7 ngày). Cấp đông được vẫn ghi ở `freezable`, không đổi nhóm.
2. Trứng → `stock_buy_by_week` (ngăn mát 21 ngày, ngoại lệ).
3. Đậu phụ → `buy_by_day`: đậu phụ bán rời ở chợ/siêu thị VN ngăn mát 1 ngày (cận dưới của 1–3 ngày, `uoc_tinh_vn`). Số 1 tuần của FoodKeeper áp dụng cho loại đóng kín nên không dùng.
4. Rau, củ, quả, sữa tươi/chua khác: theo số ngày ngăn mát cận dưới; ≤ 5 ngày → `buy_by_day`; ≥ 6 ngày → `stock_buy_by_week`.
5. Đồ để lâu (`long_term: true`): gia vị, đồ khô, gạo, đậu khô, tiêu, dầu, nước mắm, xì dầu, nước mắm chay, đậu lăng, đậu đỏ, nấm rơm đóng hộp, sữa UHT → `stock_buy_by_week`, không cần số ngày.
6. Thiếu số liệu và không phải đồ để lâu → `unclassified`; không đoán nhóm.

## 3. Bảng từng nguyên liệu

| # | ingredient_id | name | buy_group | fridge_days | pantry_days | freezer_days | freezable | long_term | status | tips_vi |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | uc_ga_khong_da | Ức gà, không xương, không da | buy_by_day | 1 | — | 270 | true | false | gan_dung | Cất ngăn mát trong túi kín, để dưới cùng để không nhỏ nước lên rau. Muốn giữ lâu hơn thì chia phần và cấp đông. |
| 2 | dui_ga_khong_da | Đùi gà, không xương, không da | buy_by_day | 1 | — | 270 | true | false | gan_dung | Cất ngăn mát trong túi kín, để dưới cùng. Chia phần trước khi cấp đông. |
| 3 | thit_heo_nac_dui | Thịt heo nạc đùi | buy_by_day | 7 | — | 30 | true | false | gan_dung | Cất ngăn mát trong túi kín, đặt ở ngăn dưới cùng. Chia phần trước khi cấp đông. |
| 4 | thit_heo_nac_than | Thịt heo thăn (nạc) | buy_by_day | 3 | — | 120 | true | false | gan_dung | Cất ngăn mát trong túi kín, đặt ở ngăn dưới cùng. Chia phần trước khi cấp đông. |
| 5 | thit_heo_ba_chi | Thịt heo ba chỉ | buy_by_day | 3 | — | 120 | true | false | gan_dung | Bọc kín, cất ngăn mát; không dùng trong vài ngày thì cấp đông. |
| 6 | thit_heo_xay_nac | Thịt heo xay (nạc ~96%) | buy_by_day | 1 | — | 90 | true | false | gan_dung | Xay xong nên dùng trong 1–2 ngày, hoặc cấp đông ngay trong túi phẳng để rã đông nhanh. |
| 7 | thit_bo_nac | Thịt bò đùi (nạc) | buy_by_day | 3 | — | 120 | true | false | gan_dung | Bọc kín, cất ngăn mát dưới cùng; để lâu hơn thì cấp đông. |
| 8 | ca_basa | Cá basa phi lê | buy_by_day | 1 | — | 60 | true | false | gan_dung | Làm sạch, cất ngăn mát ngay trong túi kín; dùng trong 1–2 ngày hoặc cấp đông. |
| 9 | tom | Tôm sú / tôm thẻ (làm sạch) | buy_by_day | 1 | — | 180 | true | false | gan_dung | Cất ngăn mát trong hộp kín, dùng trong 1–3 ngày; để lâu hơn thì bỏ đầu rồi cấp đông. |
| 10 | trung_ga | Trứng gà | stock_buy_by_week | 21 | — | — | false | false | gan_dung | Cất ngăn mát trong hộp, đầu nhọn hướng xuống; tránh để ngoài nhiệt độ phòng lâu. |
| 11 | dau_phu | Đậu hũ (đậu phụ) cứng | buy_by_day | 1 | — | — | — | false | uoc_tinh_vn | Ngâm nước sạch, thay nước hằng ngày, cất ngăn mát; dùng trong khoảng 1 tuần. |
| 12 | com_trang | Cơm trắng (đã nấu chín) | buy_by_day | 4 | — | 180 | true | false | ok | Để nguội trước khi cất, đậy kín, cất ngăn mát; để lâu hơn thì cấp đông. |
| 13 | sup_lo_xanh | Súp lơ xanh (bông cải xanh) | buy_by_day | 3 | — | 300 | true | false | gan_dung | Cất ngăn mát trong túi, để khô; dùng trong 3–5 ngày. |
| 14 | sup_lo_trang | Súp lơ trắng (bông cải trắng) | buy_by_day | 3 | — | 300 | true | false | gan_dung | Cất ngăn mát trong túi, để khô; dùng trong 3–5 ngày. |
| 15 | bap_cai | Bắp cải | stock_buy_by_week | 7 | — | 300 | true | false | gan_dung | Cất ngăn mát, để nguyên bắp; dùng trong 1–2 tuần. |
| 16 | ca_rot | Cà rốt | stock_buy_by_week | 14 | — | 300 | true | false | gan_dung | Bỏ lá trước khi cất; cất ngăn mát trong túi kín; dùng trong 2–3 tuần. |
| 17 | ca_tim | Cà tím | buy_by_day | 4 | 1 | 180 | true | false | uoc_tinh_vn | Cất ngăn mát trong túi, tránh va đập; dùng trong 4–7 ngày. |
| 18 | ca_thu | Cá thu (khúc) | buy_by_day | 1 | — | 60 | true | false | gan_dung | Cất ngăn mát trong túi kín; dùng trong 1–2 ngày hoặc cấp đông. |
| 19 | muc_ong | Mực ống (làm sạch) | buy_by_day | 1 | — | 180 | true | false | gan_dung | Bọc kín, cất ngăn mát; dùng trong 1–3 ngày, để lâu hơn thì cấp đông. |
| 20 | ca_ro_phi | Cá rô phi (phi lê) | buy_by_day | 1 | — | 180 | true | false | gan_dung | Cất ngăn mát trong túi kín; dùng trong 1–2 ngày hoặc cấp đông. |
| 21 | sua_chua_khong_duong | Sữa chua Hy Lạp không đường | stock_buy_by_week | 7 | — | 30 | true | false | gan_dung | Cất ngăn mát đến khi dùng; dùng trước hạn in trên hộp. |
| 22 | tieu_den | Tiêu đen (hạt) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng lọ kín, nơi khô, tránh ẩm và nắng; để lâu thì mùi nhạt dần. |
| 23 | lac | Lạc (đậu phộng) sống | stock_buy_by_week | 360 | 28 | 720 | true | false | gan_dung | Đậy kín, cất ngăn mát hoặc ngăn đông để tránh dầu bị ôi. |
| 24 | vung | Vừng (mè) trắng | stock_buy_by_week | — | 1825 | — | — | false | ok | Đựng hộp kín, nơi khô mát; để ẩm lâu hạt dễ ôi. |
| 25 | bun_pho_nau_chin | Bún/phở tươi đã luộc | buy_by_day | 3 | — | 30 | true | false | gan_dung | Ngăn mát trong túi kín, ăn trong 2–3 ngày; để lâu hơn thì cấp đông. |
| 26 | khoai_lang | Khoai lang (củ) | stock_buy_by_week | — | 15 | 300 | true | false | uoc_tinh_vn | Để nơi khô thoáng, tối; không cất ngăn mát vì dễ đổi vị. |
| 27 | khoai_tay | Khoai tây (củ) | stock_buy_by_week | — | 15 | — | — | false | uoc_tinh_vn | Để nơi khô thoáng, tối, tránh ánh sáng; không cất ngăn mát vì dễ đổi vị. |
| 28 | duong | Đường trắng (tinh luyện) | stock_buy_by_week | — | — | — | — | true | ok | Đựng hộp kín, nơi khô; tránh ẩm để không vón cục. |
| 29 | dau_an | Dầu ăn (đậu nành) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đậy nắp kín, để nơi thoáng mát, tránh nắng; không để gần bếp nóng. |
| 30 | nuoc_mam | Nước mắm | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đậy kín, để nơi khô mát; tránh ánh nắng trực tiếp. |
| 31 | xi_dau | Xì dầu (nước tương, có lúa mì) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đậy kín, để nơi khô mát; sau khi mở nên dùng trong vài tháng. |
| 32 | muoi | Muối ăn | stock_buy_by_week | — | — | — | — | true | ok | Đựng kín, nơi khô, tránh ẩm để không vón cục. |
| 33 | toi | Tỏi (củ) | buy_by_day | 3 | 15 | 30 | true | false | uoc_tinh_vn | Để củ nguyên nơi khô thoáng; tép đã bóc thì cất ngăn mát. |
| 34 | gung | Gừng tươi | stock_buy_by_week | 14 | 1 | 180 | true | false | uoc_tinh_vn | Để nơi khô thoáng hoặc cất ngăn mát trong túi kín; dùng trong 2–3 tuần. |
| 35 | hanh_tay | Hành tây | stock_buy_by_week | 60 | 15 | 300 | true | false | uoc_tinh_vn | Để nơi khô thoáng, tách khỏi khoai tây; đã cắt thì cất ngăn mát. |
| 36 | hanh_la | Hành lá | stock_buy_by_week | 7 | 15 | 300 | true | false | uoc_tinh_vn | Cất ngăn mát trong túi; dùng trong khoảng 1 tuần. |
| 37 | ca_chua | Cà chua | buy_by_day | 4 | — | 180 | true | false | gan_dung | Quả chín thì cất ngăn mát; quả chưa chín để nhiệt độ phòng cho chín dần. |
| 38 | cai_ngot | Cải ngọt (cải bẹ xanh, PROXY) | buy_by_day | 2 | — | 300 | true | false | gan_dung | Cất ngăn mát trong túi có lỗ thoát khí; dùng trong 2–3 ngày. |
| 39 | su_su | Su su (quả) | buy_by_day | 4 | 1 | 300 | true | false | uoc_tinh_vn | Cất ngăn mát, tránh ẩm; dùng trong vài ngày. |
| 40 | bi_xanh | Bí xanh (PROXY bí ngòi) | buy_by_day | 4 | 1 | 300 | true | false | uoc_tinh_vn | Cất ngăn mát trong túi; dùng trong 4–5 ngày. |
| 41 | dau_lang | Đậu lăng khô | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng hộp kín, nơi khô mát, tránh ẩm và mọt. |
| 42 | dau_xanh | Đậu xanh khô (hạt) | stock_buy_by_week | 365 | 365 | 365 | true | false | ok | Đựng hộp kín, nơi khô, tránh ẩm. |
| 43 | sua_dau_nanh | Sữa đậu nành không đường | stock_buy_by_week | — | — | — | — | true | uoc_tinh_vn | Sau khi mở: cất ngăn mát, dùng hết trong ngày. |
| 44 | gao_lut_nau_chin | Gạo lứt nấu chín | buy_by_day | 4 | — | 180 | true | false | gan_dung | Để nguội, đậy kín, cất ngăn mát; để lâu hơn thì cấp đông. |
| 45 | tempeh | Tempeh (đậu nành lên men) | buy_by_day | 3 | — | 180 | true | false | gan_dung | Cất ngăn mát và nấu chín trước khi dùng; để lâu hơn thì cấp đông. |
| 46 | nuoc_mam_chay | Nước mắm chay (thay bằng nước tương) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đậy kín, để nơi mát; sau khi mở nên dùng trong vài tuần. |
| 47 | rau_den | Rau dền (lá) | buy_by_day | 1 | — | 300 | true | false | gan_dung | Cất ngăn mát trong túi; dùng trong 1–4 ngày. |
| 48 | gia_do | Giá đỗ (mầm đậu xanh) | buy_by_day | 5 | — | — | — | false | gan_dung | Cất ngăn mát trong hộp có khăn ẩm; dùng trong 5–10 ngày. |
| 49 | nam_rom | Nấm rơm đóng hộp (đã ráo nước) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đồ đóng hộp: để nơi khô mát; sau khi mở cất ngăn mát và dùng hết trong ngày. |
| 50 | dau_co_ve | Đậu cô ve (đậu que xanh) | buy_by_day | 3 | — | 240 | true | false | gan_dung | Cất ngăn mát trong túi; dùng trong 3–5 ngày. |
| 51 | dua_chuot | Dưa chuột (có vỏ) | buy_by_day | 4 | — | — | false | false | gan_dung | Cất ngăn mát trong túi; dùng trong 4–6 ngày. |
| 52 | dau_bap | Đậu bắp | buy_by_day | 2 | 1 | 300 | true | false | uoc_tinh_vn | Cất ngăn mát; dùng trong 2–3 ngày. |
| 53 | cai_thao | Cải thảo | stock_buy_by_week | 7 | — | 300 | true | false | gan_dung | Cất ngăn mát; dùng trong 1–2 tuần. |
| 54 | chuoi | Chuối chín | buy_by_day | 3 | — | 60 | true | false | ok | Quả chín thì cất ngăn mát, vỏ sẽ đen nhưng ruột vẫn dùng được; quả chưa chín để nhiệt độ phòng. |
| 55 | cam | Cam sành/cam ngọt | stock_buy_by_week | 10 | 5 | — | false | false | uoc_tinh_vn | Để nơi thoáng hoặc cất ngăn mát; dùng trong 10–21 ngày. |
| 56 | oi | Ổi | buy_by_day | 2 | — | — | false | false | ok | Quả chín thì cất ngăn mát; dùng trong 2–4 ngày. |
| 57 | dua_hau | Dưa hấu | buy_by_day | 3 | 1 | 360 | true | false | uoc_tinh_vn | Chưa cắt để nơi thoáng; đã cắt thì cất ngăn mát bọc kín, dùng trong 3–4 ngày. |
| 58 | du_du | Đu đủ chín | stock_buy_by_week | 7 | 1 | 180 | true | false | uoc_tinh_vn | Quả chín thì cất ngăn mát; dùng trong khoảng 1 tuần. |
| 59 | tao | Táo | stock_buy_by_week | 28 | 10 | — | — | false | uoc_tinh_vn | Cất ngăn mát trong túi; dùng trong 4–6 tuần. |
| 60 | xoai | Xoài chín | stock_buy_by_week | 7 | 1 | 180 | true | false | uoc_tinh_vn | Quả chín thì cất ngăn mát; dùng trong khoảng 1 tuần. |
| 61 | dua_thom | Dứa (thơm) | buy_by_day | 5 | — | 300 | true | false | ok | Quả chín thì cất ngăn mát; dùng trong 5–7 ngày. |
| 62 | buoi | Bưởi (proxy: bưởi trắng) | stock_buy_by_week | 10 | 5 | — | false | false | uoc_tinh_vn | Để nơi thoáng hoặc cất ngăn mát; dùng trong 10–21 ngày. |
| 63 | sua_tuoi | Sữa tươi nguyên kem không đường | stock_buy_by_week | — | — | — | — | true | ok | Sau khi mở: cất ngăn mát, dùng hết trong ngày. |
| 64 | sua_chua_co_duong | Sữa chua trái cây ít béo (chất tạo ngọt ít calo) | stock_buy_by_week | 7 | — | 30 | true | false | gan_dung | Cất ngăn mát đến khi dùng; dùng trước hạn in trên hộp. |
| 65 | dau_do | Đậu đỏ khô | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng hộp kín, nơi khô mát, tránh ẩm mốc. |
| 66 | gao_nep | Gạo nếp (khô) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng hộp kín, nơi khô mát, tránh ẩm và côn trùng. |
| 67 | gao_te | Gạo tẻ (sống) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng hộp kín, nơi khô mát, tránh ẩm và côn trùng. |
| 68 | gao_lut | Gạo lứt (sống) | stock_buy_by_week | — | — | — | — | true | chua_co_nguon | Đựng hộp kín, nơi khô mát; gạo lứt dễ ôi hơn gạo trắng nên dùng trong vài tháng. |
| 69 | rau_muong | Rau muống (PROXY: rau bina) | buy_by_day | 1 | — | 300 | true | false | gan_dung | Cất ngăn mát trong túi; dùng trong 1–4 ngày. |

## 4. Lưu ý

- Số ngày là cận dưới FoodKeeper, trừ đậu phụ (số VN). Nhiều số lấy từ cột DOP, xem `storage-draft-report.md`.
- Mẹo bảo quản viết tay theo kiến thức chung; cần đối chiếu nguồn an toàn thực phẩm VN trước khi hiển thị (T-111).
