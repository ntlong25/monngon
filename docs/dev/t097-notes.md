# T-097 — L-12 (hai mức ngân sách tối thiểu) và L-13 (tab Bạn offline)

## L-12 — nguyên nhân (D-QA-08)
- **Không phải lỗi tính.** App gọi `POST /v1/budget-range` hai lần với **đầu vào khác nhau**:
  - Bước ngân sách (trước bước kiêng/dị ứng, dụng cụ, thói quen cơm): dạng rút gọn `store_id/adults/children/slots`; server coi như không kiêng, không ghét, **đủ mọi dụng cụ**, mức cơm vừa.
  - Màn tổng kết: dạng đầy đủ `preferences` (kiêng, ghét, dụng cụ, mức cơm…). Lọc món và dụng cụ làm tập món rẻ nhất thay đổi nên mức tối thiểu có thể cao hơn (650.000 → 700.000 ₫).
- **Kiểm chứng "cùng lựa chọn → cùng số":** `V1Tests.BudgetRange_dang_rut_gon_va_day_du_cung_lua_chon_thi_cung_muc_toi_thieu` gửi dạng rút gọn và dạng đầy đủ với các lựa chọn trung tính (không kiêng/ghét, đủ dụng cụ, cơm vừa) cho 3 cấu hình cửa hàng/số người: `min_vnd`, `max_vnd`, `estimate_vnd` bằng nhau.
- **Quyết định (theo PRD D-QA-08):** giữ hai lần gọi; chỉ đổi câu cảnh báo ở tổng kết để nêu lý do và cả hai con số, kèm nút "Dùng {mức}" (phần app, cần hai chuỗi mới ở `content/i18n/vi.json`).

## L-13 — nguyên nhân (D-QA-09)
- Dòng "Chỉ tiêu mỗi ngày" ở tab Bạn đọc `targetsProvider` (gọi `POST /v1/targets`); offline provider lỗi nên giá trị là `null` → hiện "…" và không có thông báo.
- Sửa: `targetsProvider` ghi `cache.targets` ({hồ sơ, chỉ tiêu}) mỗi lần tính xong; `savedTargetsProvider` trả chỉ tiêu đã lưu **chỉ khi hồ sơ lưu trùng hồ sơ hiện tại** (hồ sơ đã sửa mà chưa tính lại thì không dùng số cũ). Tab Bạn: có số mới hoặc số đã lưu → hiện số; đang tải → "Đang tải…"; lỗi và chưa có số → `ApiErrorView` (theo `ApiException.isNetwork`) có nút Thử lại; không còn "…" ở dòng này. "Xóa toàn bộ dữ liệu" xóa luôn `cache.targets` (xóa mọi khóa).
- Test: `test/profile/profile_page_test.dart` nhóm "Chỉ tiêu mỗi ngày khi offline" (lưu khi online, offline có số lưu, offline chưa có số + Thử lại, số lưu của hồ sơ khác không dùng).
- Còn lại dòng Ngân sách ở tab Bạn hiện "…" khi `weekly_budget_vnd` ≤ 0 (chưa chọn ngân sách) — không liên quan mạng, giữ nguyên.

## Ghi chú cho PM (từ T-096)
- p01 mức vừa chỉ có **9 món trưa/tối khác nhau/14 bữa** (ngân sách 647.000/650.000 ₫ sát trần, cơm giữ 150 g) — chưa khôi phục ≥ 10 như trước T-094; test `Tuan_14` đã đặt ngưỡng chung ≥ 9. PM quyết định có nới ngân sách mặc định của p01 hay chấp nhận 9.
