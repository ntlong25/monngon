# Đánh giá: nhiều quy cách bao bì cho một cặp nguyên liệu – cửa hàng (gạo 1/2/5 kg…)

Câu hỏi của Research (`docs/research/data-batch-D1.md` mục 4): schema giá hiện có **một dòng** cho mỗi cặp (nguyên liệu, cửa hàng) (`ingredient_id@store_id` phải duy nhất, validator báo trùng). Chưa làm, chỉ đánh giá công và đề xuất cho PM.

## Hiện trạng trong code
- `Price { ingredient_id, store_id, pack_g, pack_label, price_vnd, shelf_life_days }`; `Dataset.PricesByIngredient[ingredient][store]` là **một** `Price`.
- `Shopping.BuildShoppingList`: `packs = ceil(need / pack_g)` trên một quy cách; `ShoppingItem` có `pack_g`, `packs`, `pack_label`, `price_vnd_per_pack`, `display_qty`.
- Chi phí món ăn (`used_cost_vnd`, điểm chi phí của món, ngân sách) tính theo **giá mỗi gram** của dòng giá đó, nên không phụ thuộc số bao mua.
- Ảnh hưởng khác: `PlanWeek` (xếp hạng chi phí), `BudgetEstimator`, `WeekChanges`, DTO API + OpenAPI + client Flutter sinh tự động, schema TS (`src/types/schema.ts`) và golden (do TS xuất).

## Phương án A — nhiều dòng giá cho cùng cặp (khóa thêm `pack_g`)
- Khóa mới `ingredient@store@pack_g`; `Dataset` đổi thành danh sách quy cách mỗi cặp; validator, TS schema, `validate-data` cả hai phía phải sửa.
- Công: engine ≈ 1–1,5 ngày (chọn tổ hợp bao rẻ nhất phủ đủ nhu cầu, tie-break tất định, dư/hạn dùng theo từng bao), API/OpenAPI/Flutter ≈ 0,5–1 ngày, test ≈ 0,5 ngày. **Tổng ≈ 2,5–3 ngày**.
- Rủi ro: golden parity (TS xuất theo một dòng/cặp) phải chọn "dòng tham chiếu" cho chế độ parity; đổi key làm vỡ mọi chỗ dùng `PricesByIngredient`.

## Phương án B (đề xuất) — một dòng giá chính + danh sách quy cách phụ
Giữ nguyên dòng giá hiện tại (là **quy cách tham chiếu**, dùng cho chi phí món ăn, điểm chi phí, parity) và thêm trường tùy chọn:

```json
{ "ingredient_id": "gao_te", "store_id": "cho_khac", "pack_g": 1000, "pack_label": "Gạo tẻ 1 kg", "price_vnd": 22000,
  "shelf_life_days": 180,
  "other_packs": [ { "pack_g": 2000, "pack_label": "Gạo tẻ 2 kg", "price_vnd": 42000 },
                   { "pack_g": 5000, "pack_label": "Gạo tẻ 5 kg", "price_vnd": 100000 } ] }
```

- Khóa `ingredient@store` giữ nguyên, TS và golden không đổi (TS bỏ qua trường lạ như với `purchase_as`; thêm vào zod schema là tùy chọn).
- Engine: chỉ `Shopping.BuildShoppingList` đổi: chọn tổ hợp bao (tối đa 3 loại) có tổng giá nhỏ nhất mà phủ đủ nhu cầu (quy hoạch động nhỏ, tie-break: ít bao hơn, rồi dư ít hơn). Chi phí món ăn vẫn theo giá/gram của dòng chính → ngân sách không đổi. Chế độ parity bỏ qua `other_packs`.
- API: thêm `pack_breakdown: [{pack_g, pack_label, count, price_vnd}]` vào `ShoppingItem` (cộng thêm, không bỏ trường cũ; `packs/pack_g` mô tả bao chính); `display_qty` ghép dạng "1 bao 5 kg". App hiện dùng `display_qty` nên chỉ cần thêm dòng chi tiết (tùy chọn).
- Công: validator + model ≈ 0,25 ngày; engine ≈ 0,5–1 ngày; API/OpenAPI/client ≈ 0,25 ngày; test ≈ 0,5 ngày. **Tổng ≈ 1,5–2 ngày**, không đụng parity.
- Điều kiện dữ liệu: Research phải điền `other_packs` cho các mặt hàng có nhiều bao (gạo, dầu ăn, nước mắm…) và quy ước giá/gram không giảm bất thường theo bao lớn.

## Đề xuất
1. PM duyệt phương án B; xếp sau T-078 phần 2 và T-050b, mức P1 (lợi ích: con số tại quầy sát thực tế cho gạo/dầu/nước mắm; vì các món này mặc định là "nhà có sẵn" nên tác động lên con số mặc định nhỏ).
2. Trong lúc chờ, Research có thể ghi quy cách phụ vào ghi chú (`docs/research/`) thay vì sửa dữ liệu đóng băng.
