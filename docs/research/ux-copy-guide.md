# Hướng dẫn nội dung UI (T-045)

Ngày: 06/11/2026. Bản nháp: `docs/research/content-draft/i18n-vi.json`. Chưa đặt vào `content/i18n/vi.json` vì quyền ghi của lượt này chỉ gồm `data/` và `docs/research/`; cần xác nhận để chép sang `content/`.

## Giọng văn

- Thân thiện, ngắn, xưng "mình" và gọi người dùng là "bạn".
- Câu chữ tự viết. Không dịch hay chép câu chữ của Mealbird.
- Nêu lý do ngắn gọn, không hứa hẹn về sức khỏe hay kết quả giảm cân.

## Thuật ngữ thống nhất

| Dùng | Không dùng |
|---|---|
| protein tối thiểu | sàn protein (trong UI) |
| dải calo | khoảng calo |
| ước tính | xấp xỉ, dự kiến |
| bữa phụ | snack |
| đi chợ | mua sắm |
| thực đơn tuần | meal plan |
| Chỉ tiêu | target (trong UI) |
| Tự lo | self (trong UI) |

## Quy tắc kỹ thuật

- Biến dùng cú pháp `{{count}}`, `{{range}}`, `{{min}}`, `{{max}}`, `{{detail}}`.
- Nút và nhãn ngắn, dưới 40 ký tự. Kiểm tra bằng script trước khi bàn giao.
- Mỗi màn có ít nhất một chuỗi trạng thái rỗng hoặc lỗi.

## Phần còn thiếu

- Các màn chưa có key: onboarding bước 9–10 chi tiết, paywall (Q7 chưa chốt), banner validator chi tiết theo số ngày.
- Chưa có review chéo của PM.
