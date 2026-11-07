# T-067 — Thay đổi tuần (engine C# + API)

Mã: `backend/MonNgon.Engine/WeekChanges.cs` (partial của `WeekPlanner`), API trong `V1Endpoints.cs`, test `WeekChangesTests.cs` (19) + 5 test tích hợp trong `V1Tests.cs`.

## Nguyên tắc

- **Stateless.** Mọi endpoint nhận `state = { profile, preferences, plan, include_dessert }` — đúng `plan` máy khách đã nhận — và trả tuần mới (`PlanResponse` đầy đủ: plan, trace, recipes, ingredients) hoặc danh sách gợi ý. Server không giữ gì; **hoàn tác = máy khách giữ lại tuần trước đó** (hoặc gọi `eat-out` với `mode: "undo"`).
- **Chỉ bữa bị đổi thay đổi.** Mọi bữa/ngày khác giữ nguyên từng chữ số (test so JSON). Chỉ nhóm lại "nấu 1 lần ăn 2 bữa" cho công thức cũ/mới của bữa bị đổi.
- Sau mỗi thay đổi: tổng ngày, validator (kèm `exempt`), danh sách đi chợ, `distinct_recipes`, `mam_recipes` đều tính lại.
- **Không bao giờ gợi ý món vi phạm ràng buộc cứng**: ứng viên của bữa lấy từ `Filter` (diet, loại trừ, ghét, dụng cụ, món bị chặn, đúng loại bữa/kiểu trưa). Test chạy với cả 14 hồ sơ.
- Mâm cũ vẫn tra được dù bộ lọc hiện tại không còn tạo ra nó (vd vừa chặn món canh trong đó): `MamBuilder.Rebuild(id, data)` dựng lại mâm từ id `mam:{main}+{canh}+{rau}+{cơm}[~L]`.
- Lỗi nghiệp vụ → `EditException(field, message)` → HTTP 400 `{ errors: { <field>: [...] } }`. Tuần gửi lên bị sửa tay sai cấu trúc (ngày không liên tiếp, số dòng gram lệch công thức, nguyên liệu lạ…) cũng trả 400 `plan.days[i].meals[j]…`.

## Endpoint (`/v1/plans/…`)

| Endpoint | Việc | Ghi chú |
|---|---|---|
| `POST swap-suggestions` `{state,date,slot,limit?}` | US-5.1 | 2–3 món (limit 1–5). Mỗi gợi ý: `recipe_id`, `name`, `dishes[]`, `macros` (cả bữa), `delta_protein_g/kcal/cost_vnd` so với bữa hiện tại, `keeps_day_ok`, `day_protein_g/kcal`. Nếu **không món nào** giữ ngày đạt thì `any_keeps_day=false` và `items` là các món gần đạt nhất (thiếu ít nhất trước) → UI phải cảnh báo. `recipes` chứa công thức của các gợi ý (kể cả các món trong mâm) để hiện ngay. |
| `POST apply-swap` `{state,date,slot,recipe_id}` | US-5.1 | `recipe_id` phải là ứng viên hợp lệ của bữa (trọn suất hoặc mâm), khác món hiện tại. Gram được tính lại để lấp đúng khoảng thiếu của ngày; giữ tráng miệng và món đạm phụ; bỏ cơm phụ nếu mâm mới đã có cơm / ít tinh bột. |
| `POST ingredient-options` `{state,date,slot,ingredient_id}` | US-5.2 | (endpoint thứ 6, ngoài danh sách 5 trong backlog) nguyên liệu cùng `swap_group` + cùng vai trò, không bị cấm, **đã lọc những lựa chọn lệch protein bữa quá ±5%**; tối đa 8, sắp theo \|Δprotein\|. Có `grams` mới của dòng đó và `keeps_day_ok`. |
| `POST swap-ingredient` `{state,date,slot,from_ingredient_id,to_ingredient_id}` | US-5.2 | Gram dòng đổi co/giãn theo mật độ protein (vai trò protein) hoặc kcal (carb) rồi scale lại cả bữa; lưu `substitutions[{from,to}]` so với nguyên liệu gốc của công thức (đổi lại nguyên liệu gốc thì xóa substitution). |
| `POST eat-out` `{state,date,slot,mode}` | US-5.3 | `mode`: `eat_out` → `status:"eaten_out"`, `skip` → `status:"skipped"`, `undo` → về `planned`. Bữa giữ nguyên công thức/gram/macro (để hoàn tác đúng từng chữ số), nhưng **không tính** vào tổng ngày, trace, đi chợ; ngày có bữa ngoài có `validation.days[].exempt=true` và `ok=true`, không sinh `shortfalls`. |
| `POST regenerate-rest` `{state,today,seed?}` | US-5.5 | Giữ nguyên mọi ngày có `date ≤ today`, lập lại các ngày sau bằng `WeekPlanner.Plan` (kể cả nới ưu tiên mềm). Ngân sách phần mới = ngân sách tuần − chi phí các ngày giữ (sàn 50% phần chia đều). Seed mặc định = seed tuần + 1. Bữa ăn ngoài/bỏ bữa đã đánh dấu ở các ngày sau được giữ lại. Chặn món (US-5.4) = máy khách thêm id vào `preferences.blocked_recipe_ids` rồi gọi endpoint này. Hết ngày để lên lại → 400 `today`. |

## Quy ước dữ liệu mới

- `PlanMeal.status` có thêm `eaten_out` và `skipped` (bên cạnh `planned | self | unfilled`). Mọi nơi chỉ xử lý `planned` (trace, đi chợ, offline maps) tự bỏ qua hai trạng thái này.
- Danh sách đi chợ chỉ phản ánh phần còn cần mua. **"Rút khỏi danh sách nếu chưa đánh dấu đã mua"** là việc của máy khách: giữ lại các món `bought` đã có trong danh sách cũ dù server không còn trả chúng.
- `batch_group_id` của phần lên lại có hậu tố `@<ngày đầu phần mới>` để không trùng nhóm với các ngày giữ lại.

## Chấm điểm gợi ý đổi món

Điểm = `Score.Total` (khẩu vị, xu hướng, chi phí so với chi phí tham chiếu, lặp trong tuần, món chính liền kề) + 1 nếu cùng kiểu (mâm↔mâm, trọn suất↔trọn suất). Lấy 36 ứng viên điểm cao nhất, scale và chỉnh tinh từng món trên chính bữa đó (±5 g, không đụng bữa khác), giữ món làm ngày đạt, chọn mỗi gợi ý một đạm chính khác nhau nếu được. Mâm cùng món chính với mâm hiện tại bị loại (để "đổi món" thật sự khác); canh dùng quá `MaxSoupUses` bị loại.

## Số liệu

Engine 170/170 test (golden giữ nguyên), Api 36/36, engine-report 16/16 · 112/112 ngày · mâm 81% (không đổi). Thêm vào `PlanWeek.cs`: `IsOut`, `EditSpec`, `FillDishesFor`, tham số `mutable` của `PolishDay`, `legacyMamIds` của `Planner` — hành vi lập tuần cũ không đổi.
