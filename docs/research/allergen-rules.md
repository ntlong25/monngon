# Quy tắc dị ứng & chế độ ăn (T-041)

Ngày soạn: 06/11/2026 · Owner: RESEARCH · Phiên bản: v0.1 (theo hợp đồng dữ liệu v0.1 trong `docs/pm/backlog.md`).

Mục tiêu: để DEV (T-006 bộ lọc cứng, T-016 màn kiêng/dị ứng) ánh xạ đúng từ lựa chọn trên UI sang `allergen_tags` và `diet_tags` của nguyên liệu trong `data/ingredients.json`.

## 1. Bảng ánh xạ lựa chọn → quy tắc máy đọc

Cột phải là quy tắc loại trừ: **nguyên liệu có BẤT KỲ tag nào trong danh sách bị loại**. `allergen_tags` dùng tên trường `allergen_tags`, `diet_tags` dùng `diet_tags`.

| Lựa chọn trên UI | Quy tắc máy đọc (loại nguyên liệu nếu có tag) |
|---|---|
| Không lạc | `allergen_tags` ∋ `peanut` |
| Không hạt cây | `allergen_tags` ∋ `tree_nut` |
| Không hạt giống/vừng | `allergen_tags` ∋ `seed` **hoặc** `sesame` |
| Không gluten | `allergen_tags` ∋ `gluten` |
| Không sữa | `allergen_tags` ∋ `dairy` |
| Không trứng | `allergen_tags` ∋ `egg` |
| Không đậu nành | `allergen_tags` ∋ `soy` |
| Không cá | `allergen_tags` ∋ `fish` |
| Không giáp xác/nhuyễn thể | `allergen_tags` ∋ `crustacean` **hoặc** `mollusc` |
| Không lợn (phù hợp halal) | `diet_tags` ∋ `pork` |
| Không thịt đỏ | `diet_tags` ∋ `red_meat` |
| Ăn chay | `diet_tags` ∋ `meat` **hoặc** `poultry` **hoặc** `pork` **hoặc** `red_meat` **hoặc** `fish` **hoặc** `seafood` |
| Thuần chay | `diet_tags` ∋ bất kỳ tag nào ngoài `plant` (tức: `meat`, `poultry`, `pork`, `red_meat`, `fish`, `seafood`, `egg`, `dairy`) |
| Ăn chay có cá | `diet_tags` ∋ `meat` **hoặc** `poultry` **hoặc** `pork` **hoặc** `red_meat` |
| Ít tinh bột | không loại nguyên liệu; lọc công thức theo cờ `is_low_carb` và ép `carb` = 0 (xem T-006) |
| Không kiêng gì | không loại nguyên liệu nào |

Ràng buộc giữa các lựa chọn chay: tối đa 1 trong 3 lựa chọn "Ăn chay", "Thuần chay", "Ăn chay có cá". "Ít tinh bột" kết hợp được với tất cả.

Quy ước bổ sung:
- Chỉ `diet_tags` và `allergen_tags` của **nguyên liệu** bị kiểm. Công thức được loại nếu có bất kỳ nguyên liệu nào bị loại.
- Ràng buộc "Ăn chay" cũng loại nước mắm, mắm tôm (đều có `fish`/`crustacean`); xem ca biên bên dưới.

## 2. Định nghĩa tag (bổ sung cho hợp đồng)

- `seed` = hạt giống **không phải** hạt cây và **không phải** vừng: hạt hướng dương, hạt bí, hạt chia, hạt lanh.
- `sesame` = vừng/mè và các sản phẩm từ vừng (dầu mè, bột mè).
- `tree_nut` = hạt cây thật: hạt điều, hạnh nhân, óc chó, hạt macca, hạt dẻ.
- `peanut` = lạc (đậu phộng). Lạc là họ đậu, **không** là hạt cây.
- `pork` (diet) = thịt lợn mọi bộ phận. `red_meat` (diet) = thịt bò, cừu, dê, và các phần thịt đỏ không phải lợn.
- `soy` = đậu nành và sản phẩm từ đậu nành: đậu phụ, sữa đậu nành, tương/xì dầu (đều chứa đậu nành).
- `gluten` = lúa mì, lúa mạch, lúa mạch đen và sản phẩm chứa chúng (bánh mì, mì sợi trứng, xì dầu thường, yến mạch thường nhiễm chéo).
- `plant` (diet) = nguyên liệu thực vật thuần: rau, củ, quả, gạo, đậu, hạt, đậu phụ, sữa đậu nành (không có `egg`/`dairy`).

Ngoài 11 tag trong hợp đồng, chất gây dị ứng khác (mù tạt, cần tây, sulfite, đậu lupin) chưa có tag. **Cần PM quyết** có bổ sung không (xem mục 4).

## 3. Ca biên và kết luận

| # | Câu hỏi | Kết luận | Gắn tag |
|---|---|---|---|
| 1 | Hạt hướng dương có phải hạt không? | Là **hạt giống**, không phải hạt cây. "Không hạt cây" **không** loại; "Không hạt giống/vừng" **loại**. | `seed` |
| 2 | Lạc có phải hạt cây không? | Không. Lạc là họ đậu; "Không hạt cây" không loại lạc; "Không lạc" loại. (Khớp AC T-006.) | `peanut` |
| 3 | Vừng/mè có thuộc "hạt giống"? | Tách riêng: vừng là `sesame`, "Không hạt giống/vừng" vẫn loại vừng. | `sesame` |
| 4 | Nước mắm có chay được không? | **Không**. Nước mắm làm từ cá cơm/cá cuốn, nên là `fish`. Với "Ăn chay" và "Thuần chay", nước mắm bị loại. Với "Ăn chay có cá", nước mắm được giữ. DEV cần thay bằng tương/xì dầu không gluten cho công thức chay (xem ca 5). | `fish` |
| 5 | Xì dầu có gluten không? | **Thường có**: xì dầu/nước tương thông thường ủ từ đậu nành và lúa mì, nên có `soy` và `gluten`. Tương không lúa mì (tamari, xì dầu không gluten) chỉ có `soy`. Dữ liệu tách 2 nguyên liệu: `xi_dau` (có gluten) và `tuong_khong_gluten` (không gluten, cần nguồn). | `soy`, `gluten` |
| 6 | Đậu phụ có phải "đậu nành" và có chay được không? | Có `soy`. Là `plant`, nên đạt Thuần chay và Chay. Loại khi chọn "Không đậu nành". | `soy`; diet `plant` |
| 7 | Sữa đậu nành có phải "sữa" không? | Không phải `dairy`. Có `soy` và là `plant`: đạt Thuần chay, loại khi chọn "Không đậu nành". | `soy`; diet `plant` |
| 8 | Sữa chua Hy Lạp không đường có chay không? | Là `dairy`. Đạt "Ăn chay" (ăn trứng sữa) nhưng bị loại khi chọn "Thuần chay" hoặc "Không sữa". | `dairy`; diet `dairy` |
| 9 | Yến mạch có gluten không? | Yến mạch tự nhiên không có gluten, nhưng thường nhiễm chéo lúa mì trong sản xuất. Quy tắc bảo thủ: gắn `gluten` trừ khi là yến mạch ghi "không gluten". | `gluten` |
| 10 | Mì trứng có loại được bằng "Không trứng" và "Không gluten"? | Có. Mì trứng chứa `gluten` (lúa mì) và `egg`. Bún, phở, miến (gạo, đậu xanh) không có `gluten`. | `gluten`, `egg` |
| 11 | Mắm tôm có phải giáp xác? | Có, làm từ tôm nên là `crustacean`. Không gắn `fish`, vì tôm không phải cá. Với "Không giáp xác/nhuyễn thể" loại mắm tôm. Mắm tôm cũng bị loại khi chọn "Ăn chay" và "Thuần chay" (diet `seafood`). | `crustacean`; diet `seafood` |
| 12 | Mực, ốc có tính là "nhuyễn thể"? | Có: `mollusc`. Mực không phải `crustacean`. | `mollusc` |
| 13 | Trứng vịt, trứng cút, trứng muối có phải `egg`? | Có. Trứng cút và trứng vịt đều `egg`. Trứng muối cũng `egg`. | `egg`; diet `egg` |
| 14 | Mayonnaise thường có chay không? | Chứa `egg`, nên đạt "Ăn chay" nhưng loại khi chọn "Thuần chay" hoặc "Không trứng". Mayonnaise chay (từ đậu nành hoặc đậu gà) chỉ có `soy`. | `egg` (thường) |
| 15 | Thịt bò có thuộc "thịt đỏ" và "Không lợn" không? | Thịt bò: `red_meat`, không `pork`. "Không thịt đỏ" loại bò; "Không lợn" không loại bò. Thịt heo: `pork`, **không** `red_meat` (xem mục 4). | `red_meat`; `pork` |
| 16 | Cá basa có phải "cá" để loại khi chọn "Không cá"? | Có, `fish`. Đạt "Ăn chay có cá". | `fish`; diet `fish` |
| 17 | Tôm có đạt "Ăn chay có cá" không? | Có: `seafood` là hải sản, được phép ở "Ăn chay có cá" nhưng không ở "Ăn chay". | `crustacean`; diet `seafood` |
| 18 | Bún, phở, gạo, khoai lang có `gluten`? | Không. Gạo và củ không có gluten. | không tag |

## 4. Câu hỏi mở gửi PM

1. **"Không thịt đỏ"**: hiện định nghĩa là bò, cừu, dê, không gồm lợn (vì đã có "Không lợn"). Nếu muốn gộp lợn vào "thịt đỏ" thì đổi quy tắc sang `red_meat` ∋ `pork`.
2. **Tag chất gây dị ứng thiếu** (cần tây, mù tạt, sulfite, lupin): có bổ sung vào hợp đồng v0.2 không? Web nêu 12 chất, hợp đồng hiện có 11 tag.
3. **Xì dầu không gluten**: cần thêm nguyên liệu `tuong_khong_gluten` vào kho để công thức chay có thể thay nước mắm/xì dầu.

## 5. Gắn tag đã áp dụng cho `data/ingredients.json` (lô 1)

Các nguyên liệu trong lô 1 đã được gắn theo bảng trên (xem `data/ingredients.json`). Nguyên liệu chưa có trong lô 1 sẽ gắn tag khi nhập.
