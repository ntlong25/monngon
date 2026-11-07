# Ghi chú API (T-070, T-069, T-071)

## T-070 — bổ sung cho Flutter
1. **Schema số**: `JsonNumberHandling.Strict` → OpenAPI chỉ còn `number`/`integer` (test duyệt cả `components` để chắc không còn union với `string`).
2. **`POST /v1/plans`** trả thêm `recipes` (id → Recipe đầy đủ: steps, cook_minutes, dish_role, image, `image_group`, kể cả món của mâm, tráng miệng và công thức mâm `mam:...`) và `ingredients` (id → `{name, aisle, household_units, default_pantry}`, gồm cả extras, tráng miệng, nguyên liệu thay thế). Test duyệt mọi `recipe_id`/`dessert_id`/`ingredient_id`/`from`/`to` trong plan đều có trong map.
3. **Đơn vị bếp — chọn cách A**: `household_units` (`[{unit, grams}]`) nằm trong `IngredientDto`, `GET /v1/reference.dislike_suggestions` và map `ingredients`; app tự quy đổi ("≈ 1 thìa canh"), không có `hint` trên từng dòng bữa.
4. **`GET /v1/reference`** thêm `health_leanings` (chỉ gồm xu hướng có công thức mang thẻ tương ứng trong data; hiện không có thẻ "tiểu đường" nên không liệt kê), `dislike_suggestions` (≥ 6 nguyên liệu có trong kho), `aisles` (id → tên quầy), và `description` + `group` (`diet | exclusion | health | equipment`) cho mọi `OptionDto`. `description` sinh từ dữ liệu thật ("Loại 4 nguyên liệu: Lạc, …").
5. **`POST /v1/shopping-list`** (stateless): `{meals:[{eaten_out, ingredients:[{ingredient_id, grams, standard_grams}]}], store_id, adults, children, pantry_ids}` → `ShoppingList` (có `display_qty`, `is_default_pantry`); bỏ bữa `eaten_out`, bỏ nguyên liệu trong `pantry_ids`; lỗi → 400 theo đường dẫn (`meals[0].ingredients[1].grams`).
6. **`image_group`** (kho | xao | canh | luoc_hap | com | sang | phu) tính từ `dish_role`/`meal_types`/`cuisine_tags`, chỉ-đọc trên Recipe.
- `display_qty` ("3 quả", "1 lốc", "2 kg", "2 × 500 g") suy từ `pack_label`; chỉ có ở `meal_style ≠ full_meal_only` để golden giữ nguyên khóa.

## T-071 — tráng miệng (D-DES-01)
- Đọc `dish_role: dessert`, `portable`, `low_carb_ok` (model + validate-data). Mỗi bữa trưa/tối được lên thực đơn (auto/mam_only) có 1 tráng miệng: engine chọn trước (hợp lệ cứng, `portable` nếu trưa mang đi, `low_carb_ok` nếu Ít tinh bột, không trùng trong ngày, ít dùng/rẻ), trừ kcal/protein của nó khỏi chỉ tiêu bữa rồi scale món chính/cơm; gram tráng miệng là núm tinh chỉnh ±5 g trong [min_g, max_g] ở `polishDay`; khi vượt ngân sách thì đổi sang món rẻ hơn (không bỏ).
- `PlanMeal.dessert_id`, `dessert[]` (gram), `dishes[]` có `role: "dessert"`; `warnings: ["dessert_missing"]` khi không có ứng viên (bữa vẫn lên, không tính ngày không đạt).
- `include_dessert` (mặc định true) trong `POST /v1/plans`; `full_meal_only` không có tráng miệng.
- **data/ chưa có món tráng miệng** → engine-report thật báo 0% và `dessert_missing` ở mọi bữa; test dùng 3 món tự dựng (chuối, ổi, sữa đậu nành). Chưa dùng `shelf_life_days` để xếp trái cây đầu/cuối tuần (chưa có dữ liệu để đo).

## T-069 — khoảng ngân sách (D-BUD-01)
- Request: `targets{kcal_target, protein_g}` bắt buộc (thiếu → 400), `preferences` tùy chọn (có thì lọc kiêng/ghét/dụng cụ, và store/adults/children/slots lấy từ đó), response có `tiers[].key` (`economy|moderate|comfortable`, không còn nhãn) và `basis: "week_food_cost"`.
- Min = phân vị 20% chi phí đã scale theo từng slot × 7 × 1,10 (làm tròn lên 50k); max = max(ước tính × 2,5; min + 500k) làm tròn lên.
- **Ước tính khác PM**: trung vị chi phí ứng viên lệch 30–90% so với tuần engine lập ở 11/14 hồ sơ (AC ±15% chỉ đạt 3/14) vì engine không chọn món "trung vị" (ưu tiên món vừa chỉ tiêu, hay là đậu/chay rẻ). Nên ước tính = chi phí món ăn của tuần engine lập thật với ngân sách 10.000.000 ₫ (hằng `SimBudgetVnd`), seed 1; trung vị chỉ là dự phòng khi engine không lập được. Chi phí: một lần chạy engine (~30–150 ms) mỗi lần gọi.
- Test (BudgetTests): ngân sách = min → ≥ 90% hồ sơ không vượt; ước tính ±15% so với chi phí thật ≥ 80% (vì cùng mô phỏng nên rất sát; lệch thật còn tùy ngân sách người dùng đặt); tăng người/bữa → min, ước tính, max không giảm; thiếu `targets` → 400.

## T-075 — `budget-range`: trường cấp ngoài là tùy chọn

`store_id`, `adults`, `children`, `slots` ở cấp ngoài giờ nullable trong OpenAPI và chỉ được dùng khi **không** có `preferences` (có thì bị bỏ qua, kể cả giá trị sai). Không có `preferences` và không có trường cấp ngoài nào → 400 `errors.preferences`. Client Flutter: dạng đầy đủ chỉ gửi `targets` + `preferences`; dạng rút gọn (bước 7 khi chưa có đủ lựa chọn) gửi `targets` + 4 trường cấp ngoài.

## T-078 (D-SHP-01, D-SHP-02) — đồ nhà có sẵn và quy cơm ra gạo
- `POST /v1/shopping-list`: `pantry_ids` không gửi → dùng `default_pantry`; `[]` → không coi gì là có sẵn. Dòng nhà có sẵn **vẫn nằm trong `items`** (cờ `is_pantry`, cùng `is_default_pantry`), để app bỏ đánh dấu được. `till_cost` bỏ các dòng đó; `week_food_cost` vẫn tính gram đã dùng của mọi dòng; `pantry_cost_if_buy_vnd` = tiền theo gói của các dòng đó. `skipped_pantry` còn lại để tương thích (id các dòng có sẵn).
- `POST /v1/plans` (chế độ auto) và các endpoint đổi tuần: `plan.shopping` theo `default_pantry`. Chế độ parity (`full_meal_only`) không có `is_pantry`/`pantry_cost_if_buy_vnd` và không quy gạo → khớp golden TS.
- `purchase_as {ingredient_id, factor}` trên nguyên liệu (cơm chín → gạo sống: `com_trang` → `gao_te` 0,36; `gao_lut_nau_chin` → `gao_lut` 0,34): danh sách đi chợ và chi phí tính theo nguyên liệu đích; dinh dưỡng không đổi. `ingredients` trong response của `/v1/plans` có `purchase_as` và luôn kèm nguyên liệu đích để app ghi "≈ X g gạo tẻ". Validator C# báo lỗi khi factor ∉ (0,1], đích không tồn tại/không có giá ở `cho_khac`, tự trỏ hoặc nối chuỗi.

## T-094 — `rice_habit`, `rice`, `notes` (D-COM-01)
- `preferences.rice_habit` (`it|vua|nhieu|rat_nhieu`, mặc định `vua`) có trong mọi endpoint nhận `preferences` (plans, regenerate-rest, swap, swap-ingredient, eat-out…).
- Bữa mâm có cơm: `meal.rice = {habit, target_g, actual_g}`; cơm giảm quá 10 g so với mức: `meal.notes = [{code:"rice_reduced", target_g, actual_g, reason:"kcal"|"protein"}]`. Bữa trọn suất / ít tinh bột / parity: không có hai trường này.
- Đổi mức ở tab Bạn: gọi lại `regenerate-rest` với `preferences.rice_habit` mới — ngày đã qua giữ nguyên (kể cả `rice.habit` cũ).
