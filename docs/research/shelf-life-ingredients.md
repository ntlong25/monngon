# T-111 — Hạn dùng và bảo quản nguyên liệu (khảo sát, chưa có số liệu đã đối chiếu)

Ngày: 2026-11-09 · Owner: RESEARCH · Trạng thái: **khung và nguồn đã xác định; số ngày từng nguyên liệu chưa đối chiếu được**. PM duyệt trước khi Dev dùng (backlog T-111).

> **Cập nhật 09/11 (lượt 3):** đã đối chiếu FoodKeeper cho 69 nguyên liệu. Kết quả và các vấn đề cần PM quyết nằm ở [storage-draft-report.md](storage-draft-report.md). Các mục 1–2 và bảng ở mục 8 phản ánh trạng thái trước lượt 3 (tất cả "chưa có nguồn").

## 0. Cập nhật theo PM duyệt (D-P2-01, D-P2-02, lượt 1) — ghi đè mục 4 và 5 bên dưới

- **Nhãn** tính theo số ngày **dài nhất** ở nhiệt độ phòng hoặc ngăn mát, **không tính ngăn đông**:
  - ≤ 2 ngày → "Dùng trong 1–2 ngày"
  - 3–5 ngày → "Dùng trong 3–5 ngày"
  - 6–13 ngày → "Để được cả tuần"
  - ≥ 14 ngày → "Để lâu (đồ khô, đông lạnh)"
- **Bỏ** quy tắc "cấp đông được thì coi như ít nhất 3–5 ngày". "Cấp đông được" là huy hiệu riêng (boolean `freezable`), không đổi nhãn.
- **`status`** của mỗi dòng: `ok` | `uoc_tinh_vn` (số thận trọng cho khí hậu nóng ẩm) | `chua_co_nguon`.
- `data/storage.json` là nguồn chính cho phase 2. `prices.json.shelf_life_days` giữ nguyên cho golden.
- **FoodKeeper:** người dùng tải thủ công bằng trình duyệt, lưu vào `docs/research/sources/foodkeeper-<ngày>.json` (hoặc `.xls`). Chưa có file nên chưa điền số. Không dùng bản sao trên GitHub.
- **Điều kiện mở T-112:** mọi nguyên liệu tươi (thịt, cá, trứng, sữa, rau, trái cây) có `status` là `ok` hoặc `uoc_tinh_vn`.

> **Vấn đề cần PM quyết trước khi đưa `storage.json` vào `data/`:** `backend/MonNgon.Engine/Helpers.cs` tính `data_version` là SHA-256 của **mọi** file `data/*.json`. Thêm `data/storage.json` sẽ đổi `data_version`, khiến `golden/manifest.json` và fixture ở `mobile/test/fixtures/` lệch, và Dev phải chạy lại export-golden. Hai lựa chọn: (a) giữ ở `data/` và kèm việc regen golden/fixture cho Dev; (b) đặt ở thư mục khác không nằm trong hash. Bản nháp đã tạo tại `docs/research/storage-draft.json`, **chưa** đưa vào `data/`.

## 1. Kết luận ngắn

- **Chưa có dòng nào trong `data/ingredients.json` có số ngày đã đối chiếu với nguồn.** Lý do: file gốc USDA FoodKeeper (`fsis.usda.gov/shared/data/EN/foodkeeper.json`) trả HTTP 403 khi tải tự động. Không thể đọc từng dòng.
- Chưa tìm được tài liệu chính thức của Cục An toàn thực phẩm (attp.gov.vn) có thời gian bảo quản từng loại nguyên liệu. Kết quả tìm kiếm chỉ có báo chí và trang bán điện máy, và các con số mâu thuẫn nhau (ví dụ thịt đông lạnh: "không quá 7 ngày" ở một bài, "14–30 ngày" ở bài khác). Không dùng các con số này.
- Theo quy tắc của AC T-111, mọi dòng hiện ghi **"chưa có nguồn"**. Không điền số đoán.
- `data/prices.json` có trường `shelf_life_days` ở 73 dòng (ví dụ thịt heo xay: 3). **Các con số này không có nguồn** trong file. Đề xuất: giữ nguyên để không gãy engine, nhưng không hiển thị trên UI "Bảo quản" cho tới khi đối chiếu. Xem mục 5.

## 2. Nguồn đã kiểm

| Nguồn | Có gì | Trạng thái |
|---|---|---|
| USDA FSIS FoodKeeper (fsis.usda.gov, data.gov) | Bộ dữ liệu công khai có ba trường thời gian: tủ lạnh, tủ đông, nhiệt độ phòng (tủ/ngăn khô). Có định dạng JSON và XLS. Trang data.gov ghi cập nhật không định kỳ, lần cuối 22/01/2025 | **Nguồn chuẩn được đề xuất.** Không đọc được file: JSON trả 403, FoodKeeper web (foodkeeper.org) không phân giải được tên miền. Cần người mở bằng trình duyệt hoặc tải thủ công, rồi PM duyệt cách lấy |
| Bản sao không chính thức (jelera/food-shelflife-db, GitHub) | Dựa trên bản dump FoodKeeper, có trường `dop_refrigerate` và `dop_freeze`, không có trường ngăn khô | **Không dùng làm nguồn.** Tác giả ghi "use this at your own risk" |
| Cục ATTP (attp.gov.vn) | Chưa tìm được văn bản hướng dẫn bảo quản theo từng loại | **Chưa có.** Cần tìm tiếp hoặc hỏi PM có chấp nhận nguồn khác |
| Báo chí, trang điện máy, tài liệu tuyên truyền địa phương | Các nguyên tắc chung: ngăn mát 1–4 °C; tách thực phẩm sống và chín; bọc kín. Số ngày khác nhau và mâu thuẫn | **Chỉ dùng làm ghi chú, không dùng làm số liệu** |

## 3. Điều chỉnh khí hậu nóng ẩm VN

Chưa làm được: không có nguồn VN từng loại. FoodKeeper là số liệu Mỹ (nhiệt độ phòng thường hiểu là khoảng 20–25 °C, VN thường cao hơn). **Đề xuất:** với nhóm nhiệt độ phòng, đặt số ngày ở mức thận trọng và ghi ngoài bảng là "ước tính theo khí hậu nóng ẩm, chưa kiểm chứng" cho tới khi có nguồn VN.

## 4. Ngưỡng 4 nhãn độ tươi (US-8.1 AC1), đề xuất để PM duyệt

Nhãn theo PRD, áp dụng cho số ngày **sau khi mua, bảo quản đúng cách** (nơi cất tốt nhất có sẵn cho nguyên liệu):

| Nhãn | Ngưỡng đề xuất | Lý do |
|---|---|---|
| Dùng trong 1–2 ngày | Tối đa ≤ 2 ngày ở nơi cất tốt nhất (thường là ngăn mát) và không cấp đông được | Hạn ngắn, cần xếp bữa sớm (US-8.2) |
| Dùng trong 3–5 ngày | 3–5 ngày ở ngăn mát, hoặc cấp đông được | Cần xếp trong nửa đầu tuần |
| Để được cả tuần | 6–7 ngày ở ngăn mát, hoặc chỉ ngăn mát mới đạt |  |
| Để lâu (đồ khô, đông lạnh) | Nhiệt độ phòng hoặc ngăn khô ≥ 14 ngày, hoặc nguyên liệu chủ yếu bảo quản đông | |

Quy tắc chọn nhãn: lấy số ngày **dài nhất** trong các nơi cất hợp lý, và nếu cấp đông được thì coi như nhãn ít nhất là "3–5 ngày" (AC3 US-8.3 đề xuất cấp đông).

Các ngưỡng 2, 5, 7, 14 ngày là đề xuất, chưa có căn cứ khoa học riêng. PM chọn lại được.

## 5. Hợp đồng dữ liệu đề xuất (chưa dùng)

Đề xuất file mới `data/storage.json` (không sửa `ingredients.json`), một dòng cho mỗi nguyên liệu:

```json
{
  "ingredient_id": "thit_heo_xay_nac",
  "status": "chua_co_nguon",
  "fridge_days": null,
  "pantry_days": null,
  "freezer_days": null,
  "freezable": null,
  "tips_vi": null,
  "spoilage_signs_vi": null,
  "source": null
}
```

Khi có nguồn: `status` = `"ok"`, và `source` = `{ "org": "USDA FSIS", "title": "FoodKeeper", "url": "...", "accessed": "YYYY-MM-DD", "adjusted_for_vn": false }`.

Quy tắc validator (Dev, sau khi PM duyệt):
- Mọi `ingredient_id` trong `ingredients.json` phải có một dòng trong `storage.json`.
- `status` = `"ok"` thì `source` không được null và phải có `accessed`.
- `freezable` = `true` thì `freezer_days` không được null.
- Đối chiếu với `prices.json` `shelf_life_days`: lệch quá một nhãn (mục 4) thì báo lỗi, không tự sửa.

Lưu ý: `storage.json` cần thêm vào `data/` và cập nhật `validate.ts` và `MonNgon.Tools` (Dev). Research không sửa các file này.

## 6. Câu miễn trừ (AC2, đề xuất)

> Thông tin bảo quản chỉ tham khảo, cần kiểm tra tình trạng thực tế (mùi, màu, độ mềm) trước khi dùng.

## 7. Dấu hiệu hỏng và mẹo chung (chưa có nguồn từng loại)

Các mẹo chung được nhiều nguồn đồng ý, nhưng chưa dùng làm dữ liệu cho từng nguyên liệu: để thịt và cá trong ngăn lạnh sâu nhất, bọc kín, để riêng khỏi rau; không rửa rau trước khi cất nếu không dùng ngay (các nguồn không thống nhất về điểm này). Dấu hiệu hỏng theo từng loại cần nguồn riêng.

## 8. Bảng từng nguyên liệu

Bảng dưới đây được sinh từ `data/ingredients.json` và `data/prices.json`. Cột "prices.json" là số hiện có, **chưa có nguồn**.

| # | ingredient_id | Tên | Nhóm (aisle) | prices.json shelf_life_days (chưa có nguồn) | Tủ lạnh / Nhiệt độ phòng / Đông | Nguồn | Trạng thái |
|---|---|---|---|---|---|---|---|
| 1 | uc_ga_khong_da | Ức gà, không xương, không da | thit | 3 | — / — / — | — | chưa có nguồn |
| 2 | dui_ga_khong_da | Đùi gà, không xương, không da | thit | 3 | — / — / — | — | chưa có nguồn |
| 3 | thit_heo_nac_dui | Thịt heo nạc đùi | thit | 3 | — / — / — | — | chưa có nguồn |
| 4 | thit_heo_nac_than | Thịt heo thăn (nạc) | thit | 3 | — / — / — | — | chưa có nguồn |
| 5 | thit_heo_ba_chi | Thịt heo ba chỉ | thit | 3 | — / — / — | — | chưa có nguồn |
| 6 | thit_heo_xay_nac | Thịt heo xay (nạc ~96%) | thit | 2–3 | — / — / — | — | chưa có nguồn |
| 7 | thit_bo_nac | Thịt bò đùi (nạc) | thit | 3 | — / — / — | — | chưa có nguồn |
| 8 | ca_basa | Cá basa phi lê | ca_hai_san | 2 | — / — / — | — | chưa có nguồn |
| 9 | tom | Tôm sú / tôm thẻ (làm sạch) | ca_hai_san | 2 | — / — / — | — | chưa có nguồn |
| 10 | trung_ga | Trứng gà | trung_dau_phu | 21 | — / — / — | — | chưa có nguồn |
| 11 | dau_phu | Đậu hũ (đậu phụ) cứng | trung_dau_phu | 5 | — / — / — | — | chưa có nguồn |
| 12 | com_trang | Cơm trắng (đã nấu chín) | gao_do_kho | 180 | — / — / — | — | chưa có nguồn |
| 13 | sup_lo_xanh | Súp lơ xanh (bông cải xanh) | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 14 | sup_lo_trang | Súp lơ trắng (bông cải trắng) | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 15 | bap_cai | Bắp cải | rau_cu | 7 | — / — / — | — | chưa có nguồn |
| 16 | ca_rot | Cà rốt | rau_cu | 14 | — / — / — | — | chưa có nguồn |
| 17 | ca_tim | Cà tím | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 18 | ca_thu | Cá thu (khúc) | ca_hai_san | 2 | — / — / — | — | chưa có nguồn |
| 19 | muc_ong | Mực ống (làm sạch) | ca_hai_san | 2 | — / — / — | — | chưa có nguồn |
| 20 | ca_ro_phi | Cá rô phi (phi lê) | ca_hai_san | 2 | — / — / — | — | chưa có nguồn |
| 21 | sua_chua_khong_duong | Sữa chua Hy Lạp không đường | sua | 14 | — / — / — | — | chưa có nguồn |
| 22 | tieu_den | Tiêu đen (hạt) | gia_vi_dau | 365 | — / — / — | — | chưa có nguồn |
| 23 | lac | Lạc (đậu phộng) sống | gao_do_kho | 90 | — / — / — | — | chưa có nguồn |
| 24 | vung | Vừng (mè) trắng | gao_do_kho | 180 | — / — / — | — | chưa có nguồn |
| 25 | bun_pho_nau_chin | Bún/phở tươi đã luộc | gao_do_kho | 3 | — / — / — | — | chưa có nguồn |
| 26 | khoai_lang | Khoai lang (củ) | rau_cu | 14 | — / — / — | — | chưa có nguồn |
| 27 | khoai_tay | Khoai tây (củ) | rau_cu | 14 | — / — / — | — | chưa có nguồn |
| 28 | duong | Đường trắng (tinh luyện) | gia_vi_dau | 730 | — / — / — | — | chưa có nguồn |
| 29 | dau_an | Dầu ăn (đậu nành) | gia_vi_dau | 365 | — / — / — | — | chưa có nguồn |
| 30 | nuoc_mam | Nước mắm | gia_vi_dau | 365 | — / — / — | — | chưa có nguồn |
| 31 | xi_dau | Xì dầu (nước tương, có lúa mì) | gia_vi_dau | 365 | — / — / — | — | chưa có nguồn |
| 32 | muoi | Muối ăn | gia_vi_dau | 1000 | — / — / — | — | chưa có nguồn |
| 33 | toi | Tỏi (củ) | gia_vi_dau | 30 | — / — / — | — | chưa có nguồn |
| 34 | gung | Gừng tươi | gia_vi_dau | 14 | — / — / — | — | chưa có nguồn |
| 35 | hanh_tay | Hành tây | rau_cu | 30 | — / — / — | — | chưa có nguồn |
| 36 | hanh_la | Hành lá | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 37 | ca_chua | Cà chua | rau_cu | 7 | — / — / — | — | chưa có nguồn |
| 38 | cai_ngot | Cải ngọt (cải bẹ xanh, PROXY) | rau_cu | 3 | — / — / — | — | chưa có nguồn |
| 39 | su_su | Su su (quả) | rau_cu | 14 | — / — / — | — | chưa có nguồn |
| 40 | bi_xanh | Bí xanh (PROXY bí ngòi) | rau_cu | 7 | — / — / — | — | chưa có nguồn |
| 41 | dau_lang | Đậu lăng khô | gao_do_kho | 365 | — / — / — | — | chưa có nguồn |
| 42 | dau_xanh | Đậu xanh khô (hạt) | gao_do_kho | 365 | — / — / — | — | chưa có nguồn |
| 43 | sua_dau_nanh | Sữa đậu nành không đường | sua | 180 | — / — / — | — | chưa có nguồn |
| 44 | gao_lut_nau_chin | Gạo lứt nấu chín | gao_do_kho | 180 | — / — / — | — | chưa có nguồn |
| 45 | tempeh | Tempeh (đậu nành lên men) | trung_dau_phu | 14 | — / — / — | — | chưa có nguồn |
| 46 | nuoc_mam_chay | Nước mắm chay (thay bằng nước tương) | gia_vi_dau | 365 | — / — / — | — | chưa có nguồn |
| 47 | rau_den | Rau dền (lá) | rau_cu | 3 | — / — / — | — | chưa có nguồn |
| 48 | gia_do | Giá đỗ (mầm đậu xanh) | rau_cu | 2 | — / — / — | — | chưa có nguồn |
| 49 | nam_rom | Nấm rơm đóng hộp (đã ráo nước) | rau_cu | 365 | — / — / — | — | chưa có nguồn |
| 50 | dau_co_ve | Đậu cô ve (đậu que xanh) | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 51 | dua_chuot | Dưa chuột (có vỏ) | rau_cu | 7 | — / — / — | — | chưa có nguồn |
| 52 | dau_bap | Đậu bắp | rau_cu | 5 | — / — / — | — | chưa có nguồn |
| 53 | cai_thao | Cải thảo | rau_cu | 14 | — / — / — | — | chưa có nguồn |
| 54 | chuoi | Chuối chín | trai_cay | 4 | — / — / — | — | chưa có nguồn |
| 55 | cam | Cam sành/cam ngọt | trai_cay | 14 | — / — / — | — | chưa có nguồn |
| 56 | oi | Ổi | trai_cay | 5 | — / — / — | — | chưa có nguồn |
| 57 | dua_hau | Dưa hấu | trai_cay | 2 | — / — / — | — | chưa có nguồn |
| 58 | du_du | Đu đủ chín | trai_cay | 5 | — / — / — | — | chưa có nguồn |
| 59 | tao | Táo | trai_cay | 21 | — / — / — | — | chưa có nguồn |
| 60 | xoai | Xoài chín | trai_cay | 5 | — / — / — | — | chưa có nguồn |
| 61 | dua_thom | Dứa (thơm) | trai_cay | 4 | — / — / — | — | chưa có nguồn |
| 62 | buoi | Bưởi (proxy: bưởi trắng) | trai_cay | 14 | — / — / — | — | chưa có nguồn |
| 63 | sua_tuoi | Sữa tươi nguyên kem không đường | sua | 30 | — / — / — | — | chưa có nguồn |
| 64 | sua_chua_co_duong | Sữa chua trái cây ít béo (chất tạo ngọt ít calo) | sua | 21 | — / — / — | — | chưa có nguồn |
| 65 | dau_do | Đậu đỏ khô | gao_do_kho | 365 | — / — / — | — | chưa có nguồn |
| 66 | gao_nep | Gạo nếp (khô) | gao_do_kho | 365 | — / — / — | — | chưa có nguồn |
| 67 | gao_te | Gạo tẻ (sống) | gao_do_kho | 180 | — / — / — | — | chưa có nguồn |
| 68 | gao_lut | Gạo lứt (sống) | gao_do_kho | 180 | — / — / — | — | chưa có nguồn |
| 69 | rau_muong | Rau muống (PROXY: rau bina) | rau_cu | 3 | — / — / — | — | chưa có nguồn |

Tổng: 69 nguyên liệu, 69 dòng "chưa có nguồn". Số dòng có shelf_life_days trong prices.json: 69 nguyên liệu.
