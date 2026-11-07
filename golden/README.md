# golden/ — đầu ra tham chiếu của engine TypeScript (T-052)

Bản port C# (T-062…T-064) phải khớp các file này. **Không sửa tay.** Tạo lại bằng:

```
npm run export-golden
```

- Ngày xuất: 2026-11-06 (cố định trong script; `--date` để đổi). Đầu ra không phụ thuộc đồng hồ: chạy lại cho ra file giống hệt từng byte.
- Phiên bản dữ liệu (SHA-256 của `data/*.json` theo tên file): `13d35976a23e9e9b603e851105c148b6b5a2b6411ddc344885bfec72cd86b124`; chi tiết từng file ở `manifest.json`.
- Engine TS đã đóng băng: chỉ sửa lỗi, và khi sửa phải xuất lại golden.
- JSON: khóa sắp tăng dần, thụt 1 khoảng trắng; số là double đúng như JS (macro so với sai số ≤ 1e-6, chi phí/gram khớp tuyệt đối).
- Nếu Research đổi `data/`, `manifest.json` sẽ lệch phiên bản dữ liệu: chạy lại lệnh trên và báo PM.

## Cấu trúc
| Đường dẫn | Nội dung |
|---|---|
| `manifest.json` | phiên bản dữ liệu, danh sách ca, SHA-256 từng file |
| `vectors/rng.json` | 1.000 giá trị đầu của mulberry32 với seed 1 và 42; `deriveSeed(seed, n)` cho n = 0…15 |
| `vectors/targets.json` | `computeTargets` cho 16 hồ sơ test, dải calo (±5% và −5%/0%), mốc làm tròn .5 của `Math.round` |
| `vectors/slots.json` | `allocateSlots` từng hồ sơ |
| `vectors/nutrition.json` | macro chưa làm tròn của khẩu phần chuẩn từng công thức (có `source` từng dòng) |
| `vectors/scale.json` | `scaleRecipe` mỗi công thức × 3 mục tiêu (450/30, 600/45, 800/60) × {thường, ép ít tinh bột} |
| `cases/<hồ sơ>.seed<N>.json` | 48 ca: đầu vào (hồ sơ, tùy chọn, chỉ tiêu, ngày bắt đầu, seed), `slots`, `plan` = `WeekPlan` đầy đủ (món, gram, macro, extras, substitutions, unfilled, validation/shortfall, shopping) |

Seed: 1, 2, 3 · ngày bắt đầu tuần: 2026-11-09 · tùy chọn engine: mặc định.
