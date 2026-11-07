# T-074 (nguồn chuỗi = content/) và T-077 (mâm khi ngân sách eo hẹp)

## T-074 — `content/i18n/vi.json` là nguồn chuỗi duy nhất

- `mobile/tool/gen_arb.py` chỉ đọc `content/i18n/vi.json` (bỏ nhánh bản nháp `docs/research/content-draft`). Thiếu file → dừng.
- `mobile/tool/arb_extra.json` **đã xóa**: mọi khóa của nó đã có trong `vi.json` (đối chiếu: 256/256 khóa, chỉ `profileDisclaimerBody` khác và bản `vi.json` thắng). Chuỗi mới của app phải thêm vào `content/i18n/vi.json` (RESEARCH sở hữu), không thêm vào `mobile/`.
- Kiểm tra ngược: script quét `mobile/lib` tìm `l.xxx` / `AppL10n.of(context).xxx`; khóa không có trong nguồn → lỗi, liệt kê file dùng.
- Khóa dạng dotted `app.name`, `onboarding.generating.wait` → ARB `appName`, `onboardingGeneratingWait` (không còn trùng).
- ARB còn 464 khóa. Khác bản trước ở 3 chuỗi: `profileDisclaimerBody` (danh sách lựa chọn đúng D-ONB-03, hết "Hợp người tiểu đường"/"Chống viêm"), `shoppingWeekCost` ("Chi phí món ăn tuần này"), `shoppingTillCost` ("Ước tính trả tại quầy").
- Nhãn bậc ngân sách dùng `budget.tier.*` + `.desc` (`Labels.budgetTier`: "Tiết kiệm — Chủ yếu là…"). `onboarding.budget.level.*` (deprecated) không còn được mã dùng; vẫn nằm trong `vi.json`.
- Quy trình đổi chuỗi: sửa `content/i18n/vi.json` → `PYTHONIOENCODING=utf-8 python mobile/tool/gen_arb.py` → `flutter gen-l10n`.

### Fixture Flutter

- `test/fixtures/*.json`: bản chụp mới từ API thật (`python mobile/tool/capture_fixtures.py`), dùng cho test hợp đồng.
- `test/fixtures/ui/*.json`: bản chụp **cố định** cho test giao diện (xem `ui/README.md`). Lý do: test giao diện khẳng định tên món, tổng protein, số món đi chợ…; khi `data/` đổi, tuần mẫu đổi hoàn toàn (đợt này vỡ 20 test dù giao diện không đổi). `fixture()` trong `test/support/test_app.dart` đọc thư mục `ui/`.

## Bug engine tìm thấy khi chụp lại fixture

`RefineDay` được gọi lại từ `RepairDesserts` (sau `AddExtras`) và đặt `Macros = kết quả scale + tráng miệng`, làm mất macro "Món thêm" khỏi macro bữa (bữa ≠ tổng món, lệch tới 12 kcal). Sửa: dùng `ExtrasMacros` (tráng miệng + món thêm). Test mới `MealMacrosConsistencyTests` (mọi hồ sơ). Golden (`full_meal_only`) không đổi.

## T-077 — nâng tỉ lệ ghép mâm khi ngân sách eo hẹp (D-MAM-01)

Chẩn đoán (với data mới của Research): p01 93%, p09 43%, p11 21%, p15 21%; lý do đều là **budget** (nới ngân sách ×10 thì 100%). Nguyên nhân: tuần ưu tiên mâm (vòng 0–2) vượt ngân sách → bị bỏ cả vòng, sang vòng 3+ giảm ưu tiên mâm → ra tuần đạt nhưng ít mâm. Sửa ngân sách chỉ chạy một lần ở cuối trên tuần tốt nhất.

Thay đổi (`PlanWeek.cs`, chỉ khi `meal_style` ≠ `full_meal_only`):
1. **Sửa ngân sách ngay trong vòng ưu tiên mâm.** Ở vòng 0–2, nếu tuần chỉ vượt ngân sách (còn lại hợp lệ), chạy `RepairDesserts` + `RepairBudget` trên bản sao; nếu sửa xong đạt 7/7 và trong ngân sách thì nhận luôn (giữ mâm), không bỏ vòng.
2. **Thay món phụ rẻ hơn trước khi hạ cả mâm.** Trong `RepairBudget`, bữa đang là mâm lấy riêng N mâm rẻ nhất (đổi canh/rau/món chính) và N trọn suất rẻ nhất; ứng viên mâm luôn thắng ứng viên hạ xuống trọn suất (`Cand.Downgrade`) dù trọn suất tiết kiệm nhiều hơn. Trước đây N ứng viên rẻ nhất thường toàn trọn suất nên mâm rẻ hơn không bao giờ được xét.
3. **Engine-report có cột lý do không ghép mâm** (`ProfileResult.MamReason`, `MamReasonDetail`): chạy lại hồ sơ với ngân sách ×10 và với đủ dụng cụ; ràng buộc nào nới ra tăng ≥ 5 điểm % mâm nhiều nhất là lý do chính: `budget` | `equipment` | `no_side_candidate` (nới cả hai vẫn thiếu). Dòng mới: `lý do không ghép mâm: budget (nới ngân sách → 100%, đủ dụng cụ → 21%)`; chỉ hiện khi mâm < 100%.

Kết quả (`docs/dev/engine-report-mam.txt`): 16/16 hồ sơ 7/7, 112/112 ngày, **100% bữa trưa/tối là mâm ở mọi hồ sơ** (p14 100%, p11 21% → 100%, p15 21% → 100%, p09 43% → 100%), 100% có tráng miệng, 0 vi phạm ràng buộc cứng, không vượt ngân sách. Test: `MamTests.Moi_ho_so_dat_ti_le_ghep_mam_toi_thieu_khi_ngan_sach_eo_hep`, `Engine_report_neu_ly_do_khong_ghep_mam`.

Lưu ý: kết quả phụ thuộc `data/` (canh/rau rẻ của T-053 và gói nhỏ). Nếu data đổi mà mâm tụt, đọc dòng "lý do không ghép mâm" của engine-report trước.
