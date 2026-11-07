# Port TS → C# (T-061…T-064)

Trạng thái: **parity 100%** với `golden/` (42 ca `WeekPlan` + vector rng/targets/slots/nutrition/scale), **khớp từng bit** (kể cả khi đặt dung sai macro = 0). Không có sai lệch cần PM chấp nhận.

Kiểm: `dotnet test backend/MonNgon.sln` (Engine.Tests: `GoldenTests.cs`, `PlanWeekTests.cs`, `DataValidatorTests.cs`). `dotnet run --project backend/MonNgon.Tools -- engine-report` ra cùng số liệu với `npm run engine-report` (khác nhau chỉ ở thời gian, phần chẩn đoán chi tiết và ma trận phủ món chưa port).

## Các bẫy đã xử lý
| Bẫy | Cách xử lý |
|---|---|
| `Math.round` (làm tròn .5 lên +∞, cả số âm) | `Js.Round` (`Numeric.cs`), không dùng `Math.Round`. Có test với .5, số âm và 0,49999999999999994 |
| mulberry32 / `deriveSeed` 32-bit | `uint` + `unchecked` (`Rng.cs`); 1.000 giá trị đầu seed 1 và 42 khớp golden |
| Sort ổn định | LINQ `OrderBy/ThenBy` (ổn định), không dùng `List.Sort` |
| `localeCompare` | Id ASCII: so sánh ordinal khi hòa điểm trong `rankRecipes` đã không còn dùng. Tên nguyên liệu (sắp danh sách đi chợ) dùng `ViCollator` mô phỏng ICU `vi`: dấu câu < số < chữ cái; a<ă<â, d<đ, e<ê, o<ô<ơ, u<ư; thanh điệu (mức 2) không<huyền<hỏi<ngã<sắc<nặng; thường trước hoa. Lý do tự viết: `InvariantGlobalization` bật nên culture-compare của .NET là ordinal, và `string.Normalize` không phân rã tiếng Việt. Golden xác nhận thứ tự đúng với 204 công thức/53 nguyên liệu hiện có; nếu thêm nguyên liệu tên lạ (ký tự đặc biệt) cần kiểm lại |
| Thứ tự duyệt `Map`/`Set` của JS (thứ tự chèn) | Dùng `List` (+ tập tra cứu) cho mọi chỗ ảnh hưởng kết quả: `Dataset.Ingredients/Recipes` là List; danh sách đi chợ giữ thứ tự chèn đầu tiên |
| `Set` dedupe vector scale | Vector tăng đơn điệu theo hệ số f nên trùng nhau luôn liền kề: so với vector trước (nhanh hơn ~3x so với khóa chuỗi, kết quả y hệt) |
| `structuredClone` khi sửa ngân sách | `PlanMeal.Clone()` sao sâu |
| `Object.assign(m, backup)` | `PlanMeal.CopyFrom` |
| Khóa tabu của bước sửa ngân sách có tiền tố lặp (`day|slot|day|slot|…`) trong bản TS nên thực tế không chặn được | **Giữ nguyên hành vi** để parity; nếu muốn sửa thì sửa ở C# sau khi parity (làm thay đổi kết quả → xuất lại golden và báo PM) |
| `(a.dayTotals as Macros)` thiếu `fiber_g` (NaN) | C# chỉ tính kcal/protein (phép toán và thứ tự giống hệt) |

## Khác biệt có chủ đích (không ảnh hưởng parity)
- JSON của C# dùng `snake_case` cho mọi khóa: `shopping.byAisle` (TS) → `shopping.by_aisle`. Bộ so golden ánh xạ tên này.
- `Dataset.Recipes` hiện có `dish_role` / `pairs_with` (v0.2) nhưng **engine bản parity bỏ qua** chúng, giống TS: 59 công thức `main/soup/side_veg/carb_base` vẫn là ứng viên bữa thường. Ghép mâm làm ở T-066.
- Validator dữ liệu: cùng (file, id, trường) với bản TS; thông điệp lỗi không giống từng chữ (zod vs C#).
- `engine-report` C#: chưa có phần chẩn đoán chi tiết, ma trận phủ món, mật độ protein, độ phủ giá (vẫn dùng bản TS cho phần đó).

## Hiệu năng (Release, máy dev)
Trung bình 25–30 ms/tuần, tối đa ~105 ms trên 14 hồ sơ (bản TS: 27/80 ms). Lần gọi đầu sau khi khởi động chậm hơn do JIT.
