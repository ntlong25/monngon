# T-116b — Đi chợ Theo ngày: mua theo cân ở chợ, chênh có dấu, gợi ý cấp đông (D-SHP-09)

## Đã làm

- **Mua theo cân** (`ShoppingGroups.BuildTrips`, `SoldByWeight`): trong các **đợt Theo ngày**, dòng giá `cho_khac` (chợ) ở quầy `thit`, `ca_hai_san`, `rau_cu`, `trai_cay` làm tròn lên bước 100 g (tối thiểu 100 g), giá theo `price_vnd / pack_g`. Biểu diễn trong API: `pack_g = 100`, `pack_label = "100 g"`, `price_vnd_per_pack` = giá 100 g, `packs` = số bước 100 g, `display_qty` "300 g", `sold_by_weight: true`. Dòng siêu thị (có dòng giá BHX…) và các quầy khác vẫn làm tròn theo gói. Không thêm trường dữ liệu: suy từ dòng giá đã chọn + quầy.
- **Không đổi:** Theo tuần, `items`, `till_cost`, `week_food_cost`, golden/parity (chỉ chế độ hiển thị có `trips`).
- **Chênh có dấu:** `ModeTotals.delta` (+ đắt hơn do mua theo đợt, − rẻ hơn nhờ mua theo cân) so với `till_cost` cũ; hiện "+X ₫ do mua theo đợt" hoặc "−X ₫ nhờ mua theo cân" (bỏ khi |chênh| < 500 ₫). Đã bỏ điều kiện "tổng ≥ cũ" ở test.
- **Gợi ý cấp đông** (`freezeSavingHint`): công tắc tắt, chênh > 15% so với mua một lần, còn thịt cá `freezable` ở đợt Theo ngày và bật công tắc thật sự rẻ hơn → thẻ "Mua thịt cá cả tuần rồi cấp đông để bớt khoảng Y ₫" + nút "Bật cấp đông" (bật công tắc). Y = tổng hiện tại − tổng khi bật công tắc.
- Chuỗi: `shop.freeze_saving_hint`, `shop.freeze_switch_label`, `shop.batch_saving_negative` (Research), `gen_arb.py` + `flutter gen-l10n`; truyền `formatVnd(abs)`.

## Đo (18 hồ sơ, seed 1, công tắc cấp đông tắt; "cũ" = `till_cost` mua một lần, bỏ nhà có sẵn; "mới" = Theo tuần + các đợt, mỗi đợt làm tròn 1.000 ₫)

Cả 18 hồ sơ test đặt `store_id = bach_hoa_xanh`, nhưng gần như mọi dòng giá là `cho_khac` (BHX chỉ có 4 dòng thịt), nên đo hai cách:

| Cách đo | Trung vị | Cao nhất | Thấp nhất | AC3 |
|---|---|---|---|---|
| Hồ sơ như đã khai (`bach_hoa_xanh`) | **+2,4%** | **+8,7%** (p09) | −5,2% (p12) | đạt (≤ +10% / ≤ +20%) |
| Cùng 18 hồ sơ đặt `cho_khac` (chợ) | **−2,6%** | **+6,0%** (p03) | −11,0% (p13) | đạt |

(Trước T-116b, `bach_hoa_xanh`: trung vị khoảng +11%, p01 +43%.)

Chi tiết từng hồ sơ (cột "bớt nếu bật cấp đông" = số Y của gợi ý, "—" khi bật không rẻ hơn):

`bach_hoa_xanh`: p01 +7,5% (bớt 41.000) · p02 −2,2% · p03 +6,2% (27.000) · p04 +7,7% (52.000) · p05 −1,7% · p06 −2,9% · p07 −0,1% · p08 +3,5% · p09 +8,7% (64.000) · p10 +0,6% · p11 +1,6% · p12 −5,2% · p13 −2,3% · p14 +3,9% · p15 +3,2% · p16 +2,6% · p17 +2,2% · p18 +2,8%.
→ không hồ sơ nào vượt 15%, nên gợi ý cấp đông không hiện ở bộ test này (hiện khi người dùng có nhiều thịt cá hơn/giá gói lớn).

`cho_khac`: p01 −0,6% · p02 −5,2% · p03 +6,0% · p04 −4,3% · p05 −1,7% · p06 −2,9% · p07 −3,6% · p08 −8,6% · p09 −6,9% · p10 −9,1% · p11 +0,3% · p12 −9,9% · p13 −11,0% · p14 +2,1% · p15 +4,0% · p16 −0,9% · p17 +0,2% · p18 −2,2%.

Số ngày tươi của thịt cá không đổi (không nới).

## Test

- Engine: `ShoppingTripsTests` — chợ cần 25 g thịt → 100 g và giá = 100 × đơn giá/g; rau 230 g → 300 g, đúng 300 g giữ 300 g; siêu thị cùng lượng → 1 gói; quầy khác (đậu phụ) vẫn theo gói; `items`/Theo tuần theo gói; 18 hồ sơ: lượng mua ≥ lượng dùng ở mọi dòng, chi phí món ăn và `till_cost` không đổi, bước cân hợp lệ.
- Api: dòng trong đợt có `sold_by_weight`, `pack_g = 100`.
- App: `shopping_modes_test` — gợi ý cấp đông khi chênh 16,7% (nút bật công tắc), không gợi ý khi chênh ≤ 15%, chênh âm hiện "−12.000 ₫ nhờ mua theo cân".
