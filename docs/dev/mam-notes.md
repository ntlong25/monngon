# T-066 — Ghép mâm (engine C#)

## Cách làm
- **Mâm = công thức tổng hợp.** `MamBuilder` (Engine/Mam.cs) nối nguyên liệu của `main` + (canh) + (rau) + (carb_base) thành một `Recipe` ảo `mam:<main>+<soup>+<veg>+<carb>`. Canh/rau bị ghim gram (min=max); `main` (đạm) và `carb_base` (cơm) giữ biên → bộ scale hiện có tự chỉnh protein/cơm cho khớp chỉ tiêu tổng mâm. Validator, đi chợ, sửa ngân sách, batch dùng nguyên không đổi.
- Mỗi món chính có `MamVariants` (3) biến thể (canh/rau/cơm khác nhau, chọn theo `pairs_with` rồi chi phí, xoay theo chỉ số món); biến thể cuối **không canh** (van xả khi canh đã đủ 2 lần/tuần).
- Ràng buộc: canh/rau chỉ đạm nhẹ (≤ 12 g/suất chuẩn) → không có hai món đạm chính; mọi món đã qua bộ lọc cứng riêng (dị ứng, kiêng, dụng cụ, chặn); Ít tinh bột → chỉ `main/canh/rau` low-carb, không `carb_base`, carb ép 0.
- Chọn món: nhóm món trưa/tối dành `MamPoolRatio` (0,8) cho mâm, tối đa 3 biến thể/món chính và mỗi canh 1 lần trong nhóm; điểm cộng `MamBonus` 2,5; canh ≤ `MaxSoupUses` (2)/tuần (cả khi sửa ngân sách); trưa/tối không cùng món chính; phạt lặp rau/canh/món chính.
- `extras` cơm **không** bù cho mâm đã có `carb_base`; extras đạm vẫn là phương án cuối.
- `PlanMeal.dishes[]` = `{role, recipe_id, name, grams[], macros}`; vai trò `full_meal | main | soup | side_veg | carb_base | extra` (extra = món thêm do engine bù, `recipe_id` null). `macros` của bữa = tổng dishes. `WeekPlan.meal_style` báo kiểu đã dùng.
- `recipe_id` của bữa mâm có dạng `mam:...` (không tra được ở `/v1/recipes/{id}`); UI dùng `dishes[].recipe_id`.

## meal_style
| giá trị | hành vi |
|---|---|
| `auto` (mặc định) | trọn suất (`full_meal`) hoặc mâm |
| `mam_only` | trưa/tối chỉ mâm; bữa nào không ghép được thì dùng trọn suất |
| `full_meal_only` | **hành vi cũ T-064** (mọi công thức, kể cả `main/soup/...`, là ứng viên đơn lẻ; không `dishes`) — khớp golden/ từng chữ số |

> `full_meal_only` không lọc theo `dish_role` (khác nghĩa đen của tên) vì golden do engine TS (không đọc `dish_role`) xuất. Ở `auto/mam_only`, công thức không phải `full_meal` không bao giờ là món đơn lẻ.

## Kết quả (14 hồ sơ, data 204 món, `engine-report`)
| | full_meal_only (baseline) | auto |
|---|---|---|
| hồ sơ đạt 7/7 | 14/14 | 14/14 |
| ngày đạt | 98/98 | 98/98 |
| vi phạm ràng buộc cứng | 0 | 0 |
| % bữa trưa/tối là mâm ≥ 2 món | – | seed1 62% · seed2 62% · seed3 61% |

Hồ sơ thấp: p05 (thuần chay + ít tinh bột) 0%, p09 (chỉ lò vi sóng) 0%, p14 (trưa mang đi, ít dụng cụ) 0–29%, p13 (nhiều món ghét) ~7–43%, p11 29–43% — do dữ liệu/dụng cụ (canh, cơm cần bếp/nồi cơm), không phải lỗi engine. Báo cáo đầy đủ: `docs/dev/engine-report-mam.txt`.
Biên 60% mỏng (61–62%); thêm món `main` low-carb chay và `main`/canh dùng lò vi sóng ở Research sẽ nâng tỉ lệ.
Thời gian: TB 37–91 ms, tối đa 618 ms (seed 3).

## Sửa lỗi trưa mang đi (Research báo)
Trước đây `packed` bỏ `lunch` khỏi mọi mâm → p14 chỉ 29% mâm. Nay bữa trưa mang đi có mâm riêng `mam:...~L` (món chính + rau + cơm đều `packed`, không canh); bữa tối vẫn có canh. p14: 29% → 57%. Thêm điểm mềm đa dạng dụng cụ (phạt 0,4 khi một bộ dụng cụ đã dùng > 3 lần/tuần; chỉ khi không phải full_meal_only).

## Dụng cụ (engine-report)
Engine-report thêm dòng "dụng cụ (% bữa)" cho từng hồ sơ và trung bình. Số liệu hiện tại (16 hồ sơ): bếp 85% · nồi cơm điện 32% · lò vi sóng 6% · nồi chiên không dầu 4% · lò nướng 1%. Engine không có thiên vị riêng: tỉ lệ phản ánh kho món (đa số món cần bếp). Người chỉ có lò vi sóng (p09) thì 100% bữa dùng lò vi sóng vì không còn lựa chọn; người có bếp thì lò vi sóng < 50%. Điểm mềm đa dạng dụng cụ (phạt 0,4 khi một bộ dụng cụ dùng > 3 lần/tuần) đã thêm; muốn nồi chiên/lò nướng/máy xay xuất hiện nhiều hơn cần Research thêm món cho các dụng cụ đó.
