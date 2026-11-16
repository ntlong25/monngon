# T-116 — Đi chợ 2 chế độ "Theo tuần" / "Theo ngày" (D-SHP-06/07/08)

## Thiết kế

**Nhóm mua suy từ `data/storage.json` + quầy, không có file thứ hai** (`backend/MonNgon.Engine/ShoppingTrips.cs`, `ShoppingGroups.Classify`):

1. Thịt/cá tươi (quầy `thit`, `ca_hai_san`) → **Theo ngày**, bất kể số ngày ngăn mát (heo đùi 7 ngày vẫn Theo ngày). Cấp đông được (`freezable = true`) → cờ `freezable_meat`; công tắc "Mua thịt cá cả tuần rồi cấp đông" chuyển các dòng này sang Theo tuần.
2. Không có số liệu (`chua_co_nguon` hoặc thiếu dòng) → quầy khô/gia vị hoặc `long_term` → Theo tuần, còn lại Theo ngày; luôn kèm `no_shelf_info` ("Chưa có thông tin hạn dùng"), không đoán số ngày.
3. `long_term` → Theo tuần.
4. Còn lại: số ngày = ngăn mát, không có thì để ngoài (cận dưới) — ≤ 5 → Theo ngày, ≥ 6 → Theo tuần. Trứng (21 ngày) tự rơi vào Theo tuần, đậu phụ rời (1 ngày) vào Theo ngày, tỏi (ngăn mát 3 ngày, ngoài 15 ngày) vào Theo ngày đúng bảng của Research.
5. Hai dòng cũ `com_trang`, `gao_lut_nau_chin` không có trong danh sách đi chợ (đã quy ra gạo, D-SHP-02).

Test bảng đối chiếu từng dòng với `docs/research/ingredient-storage-groups.json` (67 dòng sau khi bỏ hai dòng cũ: 33 Theo ngày + 34 Theo tuần, không có "chưa phân loại").

**Đợt mua** (`ShoppingGroups.BuildTrips`): với mỗi nguyên liệu Theo ngày, các ngày dùng gộp vào đợt sớm nhất còn tươi — mua ngày d dùng được đến ngày d + N − 1 (N = số ngày tươi cận dưới, tối thiểu 1). Rau 3 ngày dùng ngày 1 và 3 → 1 đợt ngày 1; thịt 1 ngày dùng ngày 1 và 4 (hoặc ngày 1 và 2) → 2 đợt. Gram mỗi nguyên liệu cộng qua các đợt = tổng cả tuần; số gói làm tròn riêng từng đợt; dòng 0 g không tạo đợt.

**API** (chỉ ở chế độ hiển thị, parity/golden không đổi): `ShoppingItem` thêm `buy_group` ("day"/"week"), `fresh_days`, `no_shelf_info`, `freezable_meat`; `ShoppingList` thêm `trips[]` (`day_index`, `items[]`, `till_cost`); `ShoppingMealDto.day_index` (mặc định 0) cho `POST /v1/shopping-list`. `week_food_cost`, `till_cost`, `items` giữ nguyên nghĩa.

**App** (`shopping_view.dart`, `shopping_page.dart`):
- Công tắc cấp đông và hiện/ẩn dòng tính ở app nên bật/tắt tức thì, không gọi server. Nhà có sẵn lọc ở app như trước (đợt không chứa dòng nhà có sẵn).
- Tổng "Ước tính trả tại quầy" đầu tab = Theo tuần + Theo ngày (mỗi đợt làm tròn 1.000 ₫ như engine); số chênh so với mua một lần hiện "+X ₫ do mua theo đợt". "Chi phí món ăn" (so ngân sách) không đổi.
- "Đã mua x/N" đếm riêng từng chế độ (khóa đã mua của dòng trong đợt là `trip:<ngày>:<mã>`, mỗi đợt là một lần mua), đầu tab hiện tổng hai chế độ.
- "Nhà có sẵn" chỉ ở Theo tuần (tỏi là Theo ngày nhưng mặc định có sẵn: nằm ở mục Nhà có sẵn, bỏ đánh dấu thì vào đợt mua). Nhãn "Dùng trong N ngày" ở cả hai chế độ (theo `storage.json`; kế hoạch cũ chưa có thì giữ nhãn cũ của phần dư).
- Đợt "Hôm nay · Thứ … · dd/MM" mở sẵn, các đợt sau gập; đợt của ngày đã qua xếp cuối, ghi "Đã qua".
- Mặc định Theo tuần lần đầu; nhớ chế độ và công tắc trên máy (khóa `shop_view`, không bị xóa khi sang tuần mới).
- Chia sẻ theo đúng chế độ đang xem. Kế hoạch lưu từ bản cũ (không có `buy_group`) vẫn hiện danh sách tuần như trước, không có chọn chế độ.

## Lỗi đã gặp khi làm
- Dòng có tổng gram ≤ 0 (cơm giảm về 0) có trong bảng dùng-theo-ngày nhưng không có trong `items` → `KeyNotFoundException` ở `POST /v1/plans` (test API `Plans_rice_habit…` bắt được, test engine 18 hồ sơ thì không). Đã sửa và thêm test riêng.

- `PlanWeek` dựng lại `Dataset` (gộp công thức tổng hợp) mà làm mất `storage` → trong kế hoạch mọi dòng bị coi "chưa có thông tin hạn dùng", công tắc cấp đông không hiện. Chỉ thấy khi xem ảnh trên emulator (curl `/v1/shopping-list` thì đúng). Đã sửa (`input.Data.Storage`) và test 18 hồ sơ nay đối chiếu từng dòng với `Classify`.

## Kết quả

- `check-tests.py` (cấu hình mặc định): Engine 263/263 (trước 248; +15 `ShoppingTripsTests`), Api 50/50 (+1); `test-baseline.json` cập nhật. vitest 179/179. `flutter analyze` sạch, `flutter test` 333 đạt (+13 `shopping_modes_test`; fixture hợp đồng chụp lại từ API). Integration `main_flow_test` xanh trên Pixel_7 (cổng 5556, API 5096), có thêm bước kiểm Theo tuần mặc định / Theo ngày / công tắc cấp đông.
- Ảnh: `docs/dev/screens/it-08-di-cho-theo-tuan.png`, `-theo-ngay.png`, `-cap-dong.png`.
- **Số đo tiền Theo ngày (18 hồ sơ golden, seed 1, cửa hàng của hồ sơ; "cũ" = `till_cost` mua một lần, "mới" = tuần + các đợt):** tăng từ +4% (p18) đến **+43% (p01: 925.000 → 1.323.000 ₫)**; trung vị ≈ +11%, 6/18 hồ sơ > +20%. Chi phí món ăn (so ngân sách) không đổi. Nguyên nhân: gói bán sẵn lớn so với lượng dùng mỗi đợt (ví dụ cần 25 g thịt heo đùi vẫn mua gói 300 g). PRD ghi "cao hơn một chút" nên đây là điểm PM cần xem: các hướng nếu muốn giảm (chưa làm): coi thịt/rau bán theo cân là không làm tròn gói, hoặc gộp đợt mạnh hơn.
- Đợt đầu của tuần ghi "Hôm nay" chỉ khi ngày bắt đầu tuần là hôm nay; tuần bắt đầu ngày mai thì đợt đầu ghi thứ/ngày thường.
