# Vì sao tổng số test .NET thay đổi giữa các lần chạy

## Triệu chứng

`dotnet test` lúc thì báo Engine 173 + Api 39, lúc thì 128 + 36, 118 + 13, 145 + 2 — code không đổi, dòng nào cũng "Passed!".

## Nguyên nhân (đã tái hiện)

Số test **không đổi** (`dotnet test --list-tests`: Engine 173, Api 39; chạy 3 lần liên tiếp `--no-build` đều 173). Số nhỏ hơn xuất hiện khi
**tiến trình `testhost.exe` bị giết giữa chừng**. Khi đó `dotnet test` in:

```
The active test run was aborted. Reason: Test host process crashed
Passed!  - Failed: 0, Passed: 137, Skipped: 0, Total: 137, ...
Test Run Aborted.
```

tức là dòng "Passed!" vẫn xuất hiện với số test đã chạy tới lúc bị dừng (137/173 trong lần tái hiện). Các tổng 118, 128, 145… chính là điểm bị dừng khác nhau.

Ai giết `testhost`: nhiều session cùng làm việc trong một thư mục. Khi build/test vướng khóa file (`MSB3027: Could not copy ... MonNgon.Engine.Tests.dll`),
session này (Dev) đã dùng `taskkill /IM testhost.exe /F` để dọn — lệnh đó giết **mọi** testhost trên máy, kể cả lượt test đang chạy của session khác (Research, PM). Đây là
lỗi quy trình của Dev, không phải test không ổn định hay theory đếm sai. Các lần chạy song song cùng một `bin/` cũng gây khóa file (MSB3027) và làm tình trạng trên dễ xảy ra.

Đã loại trừ: `[Theory]` đếm không ổn định (không, 173 mọi lần), dữ liệu `data/` đổi (chỉ làm test đỏ, không làm mất test), test tự thoát (không có).

## Cách phòng

1. **Không** giết tiến trình hàng loạt (`taskkill /IM testhost.exe`, `dotnet.exe`) khi dùng chung máy. Gặp lỗi khóa file thì chờ lượt chạy kia xong rồi chạy lại.
2. **Đừng chỉ nhìn dòng "Passed!"**. Chạy bằng script kiểm tra:

   ```
   python backend/check-tests.py              # build + chạy Engine rồi Api, tuần tự
   python backend/check-tests.py --no-build
   python backend/check-tests.py --update-baseline   # sau khi CỐ Ý thêm/xóa test
   ```

   Script dùng `--logger trx` và thất bại (mã thoát 1) khi: có "Test Run Aborted"/"Test host process crashed", mã thoát ≠ 0, không có file .trx,
   số đã chạy < tổng, có test không đạt, số khám phá được (`--list-tests`) ≠ số báo cáo, hoặc tổng < chuẩn trong `backend/test-baseline.json`
   (hiện Engine 173, Api 39).
3. CI nên gọi `python backend/check-tests.py` thay cho `dotnet test` trần.

Thử nghiệm: giết đúng testhost của lượt chạy của mình lúc test đang chạy cho ra đúng chuỗi "Test host process crashed / Passed! 137 / Test Run Aborted" ở trên.
