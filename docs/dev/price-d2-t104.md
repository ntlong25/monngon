# T-104 — Đợt giá D2 (T-054c/T-054d): validator, golden, chi phí trước/sau

Ngày: 2026-11-09. Engine C# Release (sau T-101), 18 hồ sơ, seed 1, mức cơm mặc định của hồ sơ.
"Trước" = `data/prices.json` + `data/stores.json` ở HEAD (cùng mọi file dữ liệu khác, thêm `source_note: "chưa có nguồn"` giả để qua validator mới, giá không đổi). "Sau" = dữ liệu hiện tại trong cây làm việc.

## Việc đã làm

1. **Validator** (TS `src/data/validate.ts` + schema, C# `DataValidator.cs` + `Price.SourceNote`): dòng giá `cho_khac` bắt buộc có `source_note` không rỗng (lỗi, chỉ rõ `ingredient@cho_khac`); giá trị `"chưa có nguồn"` hợp lệ nhưng được đếm và in **một cảnh báo tổng**. Cửa hàng khác không bắt buộc. Schema nhận `price_survey_date: null` (WinMart, Co.opmart; trước đó TS báo 2 lỗi). Dữ liệu hiện tại: 0 lỗi, **44 dòng "chưa có nguồn"** (đúng số PM nêu), 24 dòng ghi khoảng tham khảo, 1 dòng ghi "LỆCH" so với khoảng tham khảo.
   Test: 3 test mới ở mỗi phía (`validate.test.ts`, `DataValidatorTests.cs`); fixture `src/engine/__fixtures__/prices.json` thêm `source_note` cho 12 dòng `cho_khac`.
2. **Golden**: `npm run export-golden` (manifest + 61 file). **Fixture mobile**: `python mobile/tool/capture_fixtures.py` từ API đang chạy với `DataDir`/`ContentDir` đúng (thiếu `ContentDir` thì `swipe_cards` rỗng). Đổi `limit=5` → `limit=10` ở truy vấn `ingredients?q=ga` vì dữ liệu mới đẩy `trung_ga` ra khỏi top 5 (test T-085 cần nó). `test/fixtures/ui/` (bản chụp cố định cho test giao diện) không đổi.

## Chi phí món ăn tuần (₫) trước/sau — không hồ sơ nào vượt ngân sách ở cả hai bản

| Hồ sơ | Ngân sách | Trước | Sau | Đổi | Tại quầy trước → sau |
|---|---|---|---|---|---|
| p01 | 650.000 | 617.000 | 602.000 | −2,4% | 966.000 → 925.000 |
| p02 | 600.000 | 589.000 | 565.000 | −4,1% | 939.000 → 878.000 |
| p03 | 1.000.000 | 767.000 | 805.000 | +5,0% | 1.060.000 → 1.139.000 |
| p04 | 800.000 | 551.000 | 554.000 | +0,5% | 810.000 → 803.000 |
| p05 | 550.000 | 424.000 | 424.000 | 0 | 545.000 → 545.000 |
| p06 | 600.000 | 497.000 | 497.000 | 0 | 786.000 → 786.000 |
| p07 | 700.000 | 571.000 | 574.000 | +0,5% | 861.000 → 865.000 |
| p08 | 700.000 | 467.000 | 464.000 | −0,6% | 684.000 → 713.000 |
| p09 | 600.000 | 600.000 | 599.000 | −0,2% | 820.000 → 782.000 |
| p10 | 600.000 | 564.000 | 558.000 | −1,1% | 779.000 → 827.000 |
| p11 | 1.500.000 | 1.490.000 | 1.497.000 | +0,5% | 1.482.000 → 1.525.000 |
| p12 | 700.000 | 514.000 | 516.000 | +0,4% | 827.000 → 899.000 |
| p13 | 650.000 | 571.000 | 578.000 | +1,2% | 898.000 → 911.000 |
| p14 | 1.200.000 | 1.189.000 | 1.192.000 | +0,3% | 1.243.000 → 1.180.000 |
| p15 | 1.200.000 | 1.178.000 | 1.106.000 | −6,1% | 1.175.000 → 1.108.000 |
| p16 | 900.000 | 729.000 | 729.000 | 0 | 918.000 → 932.000 |
| p17 | 2.100.000 | 1.774.000 | 1.777.000 | +0,2% | 1.826.000 → 1.855.000 |
| p18 | 1.950.000 | 1.852.000 | 1.884.000 | +1,7% | 2.025.000 → 2.045.000 |

Chi phí thay đổi trong ±6% (cộng thêm do engine chọn món khác khi giá đổi, không chỉ do giá). Cả 18 hồ sơ vẫn 7/7 ngày, 0 vi phạm ràng buộc cứng.

## Ảnh hưởng ngoài chi phí: 8 test engine đỏ vì dữ liệu mới → phân tích và sửa engine

Nguyên nhân gốc: trong 4 dòng giá đổi, chỉ **`thit_heo_xay_nac` (+13,4%: 112.390 → 127.500 ₫/kg)** làm đổi kết quả p01 (hoàn riêng dòng này là p01 về đúng kết quả cũ; ba dòng còn lại không ảnh hưởng). Tuần cơm rẻ cũ của p01 mức rất nhiều (645k, 13/14 bữa có cơm, nhiều thịt bằm) nay cần ~664k (phương án 4, ngân sách 675k) — vượt ngân sách 650k khoảng 2%.

Phân tích bằng `MonNgon.Tools sweep` (quét ngân sách, `--attempt n` ép một phương án, `--repairit/--repairmeals/--repairalts` đổi độ rộng sửa ngân sách):

- **Bước sửa ngân sách của engine quá hẹp** (30 vòng × 10 bữa đắt nhất × 8 món thay thế). Ba ca `Vua_ho_nhieu_nguoi` (mức Vừa, 2+1 người 1,2tr / 1,5tr, 3+0 người 1,5tr) chỉ còn 6/9/6–7 mâm vì sửa ngân sách chọn không ra các món rẻ hơn mà vẫn là mâm. Mở rộng lên 30 × 20 × 20 cho 8/12/10 mâm (ngưỡng test 7/11/8) và không tốn thêm thời gian đáng kể nhờ nhớ kết quả co giãn của từng phương án thay thế giữa các vòng (giống hệt từng chữ số: băm 216 ô trước/sau khi thêm bộ nhớ trùng nhau).
- Sửa ngân sách rộng hơn hay chọn đi chọn lại vài món rẻ nhất → thực đơn trưa/tối co lại (p02 còn 8 món, p09 5 món; test D-DIV-01 / L-11). Thêm: mỗi món trưa/tối dùng tối đa 2 bữa/tuần khi sửa (không tìm được phương án nào thì bỏ giới hạn), và không đổi món nếu số món trưa/tối khác nhau tụt dưới 6.
- Tuần còn vượt ngân sách sau khi sửa mặc định thì sửa thêm một lần ở mức rộng hơn (300 vòng × 30 bữa × 40 món), chỉ ở bước cuối. p01 rất nhiều ở 650k: từ 6/14 bữa có cơm (phương án 7) lên **10/14** (phương án 1).
- Chọn phương án trong chuỗi xếp hạng cơm: phương án đạt 7/7 + đủ đa dạng nhưng chưa đủ ≥ 12/14 bữa có cơm không nhận ngay nếu còn phương án sau đủ cơm; không phương án nào đủ cơm thì lấy phương án đầu tiên đạt như trước.

Kết quả sau sửa: **240/240 test Engine đạt** (Api 49/49). Hai test còn lại được PM quyết (D-COM-07, D-BUD-03), không nới ngưỡng chung:

| Test | Quyết định PM | Thực hiện |
|---|---|---|
| `Rice98Tests.AC2` (p01 rất nhiều, 650k → 10/14 bữa có cơm, cần ~675k) | Thêm ô p01 × rất nhiều vào danh sách ngoại lệ tường minh (lý do ngân sách); không nâng ngân sách hồ sơ test | `BudgetExemptions` thêm `p01 rat_nhieu`. AC4 vẫn bật cảnh báo lý do ngân sách cho ô này. Ngân sách cần: engine không còn báo số ≤ ngân sách hiện có (647k < 650k vô nghĩa) — chưa biết thì `budget_needed_vnd = null` (app hiện cảnh báo ngắn, không kèm số); test chấp nhận `null` hoặc > ngân sách |
| `BudgetTests.Tang_nguoi_hoac_so_bua…` (+bữa phụ −4,3%) | Bỏ ca "thêm bữa phụ" khỏi phép đơn điệu, không nới dung sai; thay bằng phép kiểm ước tính lệch chi phí thật ≤ 3% khi có bữa phụ | Đổi tên `Tang_nguoi_thi_min_uoc_tinh_max_khong_giam` (giữ 0,97 cho thêm người); thêm `Co_bua_phu_thi_uoc_tinh_lech_chi_phi_tuan_that_khong_qua_3_phan_tram` (p01, p03). Engine.Tests 239 → 240 |

Đã sửa test `WeekChangesTests.Khong_mon_nao_giu_ngay_dat…`: giờ kiểm tra tính chất thật (không món nào giữ ngày đạt; món đứng đầu có mức vi phạm chỉ tiêu ngày nhỏ nhất), không phụ thuộc thứ tự các món còn lại (chọn theo đa dạng đạm chính).

Hiệu năng sau các sửa này và các tối ưu bổ sung: xem `perf-t101.md` (mục cập nhật 2026-11-10).

`backend/test-baseline.json`: Engine 240 (236 + 3 test validator mới + 1 test ước tính có bữa phụ).
