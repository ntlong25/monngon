# Chuỗi i18n T-116b (PRD D-SHP-09)

Ngày: 2026-11-16 · Owner: RESEARCH · Nguồn vi: `content/i18n/vi.json`

## Ba chuỗi mới

| Khóa | Dùng cho | vi (đã thêm vào vi.json) | en (đề xuất) |
|---|---|---|---|
| `shop.freeze_saving_hint` | Gợi ý trên tab Đi chợ khi mua Theo ngày tốn hơn mua một lần quá 15% | Mua thịt cá cả tuần rồi cấp đông để bớt khoảng {amount} ₫ | Buy meat and fish for the week and freeze it to save about {amount} ₫ |
| `shop.freeze_switch_label` | Nhãn công tắc cấp đông (≤ 3 từ) | Bật cấp đông | Turn on freezing |
| `shop.batch_saving_negative` | Chênh lệch âm: mua theo cân ở chợ rẻ hơn | −{amount} ₫ nhờ mua theo cân | −{amount} ₫ from buying by weight |

Ghi chú:
- Chuỗi `shop.batch_extra` ("+{amount} ₫ do mua theo đợt") vẫn dùng cho chênh lệch dương, như PM yêu cầu.
- Chuỗi vi có " ₫" sau `{amount}`, giống `shop.batch_extra` và `shop.pantry_if_buy`. PM duyệt giữ " ₫" vì `formatVnd` của app không tự thêm ₫.
- Dấu trừ là U+2212 (−), như PM viết.

## Lưu ý về tiếng Anh

`content/i18n/` hiện chỉ có `vi.json`, và `mobile/tool/gen_arb.py` chỉ đọc file này và ghi `app_vi.arb` (locale vi). Chưa có nguồn en nào trong repo. Các chuỗi en ở trên chỉ là bản đề xuất trong tài liệu này. PM đã quyết: để sau. MVP chỉ có tiếng Việt (PRD §2). Không tạo `content/i18n/en.json`, không sửa `gen_arb.py`. Bản nháp en ở file này dùng khi mở đa ngôn ngữ.
