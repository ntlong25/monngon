# Fixture cố định cho test giao diện

Các test giao diện (`test/plan`, `test/shopping`, `test/onboarding`, `test/profile`, `test/a11y`, …) khẳng định chữ và con số cụ thể
(tên món, tổng protein, số món đi chợ…). Nếu chúng đọc thẳng bản chụp mới nhất của API thì mỗi lần `data/` đổi (thêm món, đổi giá)
hàng chục test vỡ dù giao diện không đổi. Vì vậy:

- `test/fixtures/*.json` — **bản chụp mới nhất** từ API thật (`python mobile/tool/capture_fixtures.py`). Dùng cho **test hợp đồng**
  (`test/api/contract_test.dart`): client sinh ra phải đọc được phản hồi thật hiện tại.
- `test/fixtures/ui/*.json` — bản chụp **cố định** (tuần mẫu p01, data_version cũ) cho test giao diện. Chỉ cập nhật khi cố ý đổi
  nội dung mẫu, và phải sửa các con số trong test theo.
