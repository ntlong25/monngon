# Đợt T-059c: số liệu chén cơm, max_g tinh bột, chuỗi i18n (D-COM-01)

Ngày: 07/11/2026 · Owner: RESEARCH · Căn cứ: PRD US-1.4b và D-COM-01 (`docs/pm/prd.md`), backlog T-059c (`docs/pm/backlog.md`).
Phạm vi: `data/recipes.json`, `content/i18n/vi.json`, chạy `mobile/tool/gen_arb.py` (chỉ ghi `mobile/lib/l10n/app_vi.arb`), `docs/research/`. Không sửa mã Dart, C#, TS.

## 1. Kiểm số chén cơm

Nguồn: `data/ingredients.json`, `com_trang` (FDC 168878, cơm chín, 130 kcal/100 g), `gao_lut_nau_chin` (123 kcal/100 g).

| Mức (`rice_habit`) | Gram cơm trắng | kcal (130/100 g) | Mục tiêu PRD (≈ kcal) | Lệch |
|---|---|---|---|---|
| `it` | 75 g | 97,5 | ~100 | −2,5% |
| `vua` | 150 g | 195 | ~195 | 0% |
| `nhieu` | 300 g | 390 | ~390 | 0% |
| `rat_nhieu` | 450 g | 585 | ~585 | 0% |

Gạo lứt nấu chín 150 g = 184,5 kcal, lệch −5,4% so với 195 kcal (trong ngưỡng 10%). PRD D-COM-01 yêu cầu cơm trắng và gạo lứt dùng cùng số gram, nên giữ 150 g.

**Kết luận:** số liệu 75 / 150 / 300 / 450 g của PRD đúng; không đổi số chốt.

## 2. Nâng max_g các công thức `carb_base`

Mục tiêu: mức `rat_nhieu` vừa trong `max_g`. Cơm 450 g + biên 50 g (sai số làm tròn ±10 g của engine). Bún và khoai đổi theo kcal tương đương 585 kcal, rồi làm tròn lên.

| Công thức | Nguyên liệu carb | max_g cũ | max_g mới |
|---|---|---|---|
| `com_trang_nau` | `com_trang` | 300 | 500 |
| `com_gao_lut_nau` | `gao_lut_nau_chin` | 300 | 500 |
| `com_hom_vi_song` | `com_trang` | 300 | 500 |
| `com_nguoi_mang_di` | `com_trang` | 400 | 500 |
| `gao_lut_nguoi_mang_di` | `gao_lut_nau_chin` | 300 | 500 |
| `bun_tuoi_luoc` | `bun_pho_nau_chin` (108 kcal/100 g) | 400 | 550 (≥ 542) |
| `khoai_lang_hap` | `khoai_lang` (86 kcal/100 g) | 300 | 700 (≥ 681) |
| `khoai_lang_luoc_mang_di` | `khoai_lang` | 250 | 700 (min 100 giữ nguyên) |

Chỉ đổi `max_g` của dòng `role: carb`. `grams`, `min_g`, `swap_group` không đổi. Diff `data/recipes.json` so với bản trước: 8 dòng.

Lưu ý cho PM và Dev: ở mức `rat_nhieu` khoai cần ~680 g và bún cần ~540 g mỗi bữa. Đây là kcal tương đương theo PRD, nhưng khối lượng này lớn về thực tế. Engine nên chọn mức thực tế thấp hơn `max_g` trừ khi cần.

## 3. Chuỗi i18n (`content/i18n/vi.json`)

Thêm 11 khóa (vi.json chỉ thêm, không sửa khóa cũ):

| Khóa | Nội dung |
|---|---|
| `onboarding.rice.title` | Thói quen ăn cơm |
| `onboarding.rice.question` | Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm? |
| `onboarding.rice.note` | Chỉ áp cho bạn. Người lớn khác ăn mức Vừa, trẻ em ăn 0,6 suất. |
| `onboarding.rice.it` | Ít cơm, ăn nhiều thức ăn (~½ chén) |
| `onboarding.rice.vua` | Vừa (1 chén) |
| `onboarding.rice.nhieu` | Nhiều (2 chén) |
| `onboarding.rice.rat_nhieu` | Rất nhiều (3 chén trở lên) |
| `onboarding.rice.warning` | Với mức calo hiện tại, một số bữa sẽ phải bớt cơm. Bạn vẫn có thể giữ lựa chọn này. |
| `meal.rice_reduced` | Bữa này cơm còn khoảng {actual} g (bạn chọn {target} g) để vẫn đủ đạm trong mức {kcal} kcal của bạn. |
| `meal.rice_summary_low_carb` | Ít tinh bột: mâm không có cơm |
| `profile.rice_habit.title` | Thói quen ăn cơm (thêm ngoài danh sách T-059c, để T-095 có nhãn ở tab Bạn) |

Kiểm: `gen_arb.py` chạy OK, 479 chuỗi. Diff `app_vi.arb` chỉ thêm 24 dòng (11 khóa + metadata placeholder). Không khóa cũ nào bị đổi. Không trùng tên ARB.

**Lưu ý cho Dev:** `gen_arb.py` đổi tên placeholder khi có từ 2 tham số trở lên, nên `meal.rice_reduced` thành `mealRiceReduced(v1, v2, v3)` = (actual, target, kcal) theo thứ tự xuất hiện trong vi.json. Dev phải truyền đúng thứ tự.

## 4. Kiểm dữ liệu

- `npm run validate-data`: 0 lỗi, 1 cảnh báo (`rau_den`, đã biết).
- `dotnet run ... validate-data data`: 0 lỗi, cùng cảnh báo.
- `npm run export-golden`: 55 tệp. **data_version đổi:**
  - Cũ: `48a76585a8e7851654d73fd4fb0c3db1c23da419da47ce31846366d80fd2e83e`
  - Mới: `13d35976a23e9e9b603e851105c148b6b5a2b6411ddc344885bfec72cd86b124`
  - `recipes.json`: `a484abb921617b207c48b9882a73bdff2988c9019e311aa6ee04363b64fb0d14`
  - `ingredients.json`, `prices.json`, `stores.json`, `test-profiles.json`: không đổi.
- `npm test`: 176/176 (bản trước 173; số tăng do thay đổi phía code, không do đợt này).
- Dev cần cập nhật golden và các test phụ thuộc `max_g` cơm (nếu có).

## 5. TC mới (`docs/research/test-scenarios.md`)

- Mục US-1.4b, Epic 1: TC-1-39 đến TC-1-45.
- Epic 2: TC-2-14 đến TC-2-18 (data, engine/API, `low_carb`, mặc định khi thiếu trường).
- Epic 3: TC-3-15 (hiển thị cơm trên tab Kế hoạch và chuỗi `rice_reduced`).

## 6. Câu hỏi mở

1. **PM:** "bữa chính" trong quy tắc cảnh báo > 45% kcal là trưa và tối, lấy từ phân bổ US-1.3? Với hồ sơ 1.400 kcal, mức mặc định `vua` (195 kcal) đã vượt 45% của một bữa chính (~370 kcal), nên cảnh báo sẽ hiện ngay từ mặc định. Cần PM xác nhận đây là hành vi mong muốn.
2. **PM/Dev:** khoai ~680 g và bún ~540 g ở mức `rat_nhieu` có khả thi về trải nghiệm không? Nếu không, có thể giảm `rat_nhieu` tương đương cho hai nhóm này và ghi rõ trong PRD.
3. **Dev:** golden và test phụ thuộc `max_g` cần cập nhật (data_version đổi).

## 7. Bổ sung: nhãn theo chén và nguồn gram/chén

Yêu cầu bổ sung từ hub (theo user): nhãn ghi theo số chén, gram trong ngoặc là gợi ý; thêm chuỗi cơm theo chén trên màn mâm; ghi chú giảm cơm dạng chén; chốt số gram/chén có nguồn; thêm TC kiểm nhãn chén.

### 7.1 Nhãn đã đổi (`content/i18n/vi.json`)

| Khóa | Nội dung |
|---|---|
| `onboarding.rice.it` | ½ chén (~75 g) |
| `onboarding.rice.vua` | 1 chén (~150 g) |
| `onboarding.rice.nhieu` | 2 chén (~300 g) |
| `onboarding.rice.rat_nhieu` | 3 chén trở lên (~450 g) |
| `meal.rice_cups` (mới, dùng trên màn mâm) | {cups} chén cơm (~{grams} g) |
| `meal.rice_reduced_cups` (mới, ghi chú giảm cơm) | Bữa này bớt còn {cups} chén cơm để giữ đúng calo. |

Nhãn mô tả cũ ("Ít cơm, ăn nhiều thức ăn", "Vừa", "Nhiều", "Rất nhiều") đã bỏ khỏi khóa `onboarding.rice.*`. `meal.rice_reduced` (bản gram, có kcal và đạm) vẫn giữ.

Kiểm: `gen_arb.py` chạy OK, 481 chuỗi. Trong ARB, `mealRiceCups` có `v1` (chén) và `v2` (gram): app phải truyền theo đúng thứ tự. `mealRiceReducedCups` chỉ có một tham số `cups`. `validate-data` 0 lỗi. `npm test` 176/176. `data_version` không đổi (không đổi dữ liệu trong bước này).

### 7.2 Gram mỗi chén: chốt tạm 150 g, chưa có nguồn chính thức

Đã tìm (WebSearch, 07/11/2026). **Không tìm được** bảng Viện Dinh dưỡng có giá trị "1 bát cơm" hay "1 chén cơm" tính bằng gram, nên không chốt được "có nguồn chính thức".

| Nguồn | Thông tin | Ghi chú |
|---|---|---|
| Berkeley, "Vietnamese health lesson 2-6" (https://nature.berkeley.edu/departments/nut/extension/vietnamese.health/lesson2-6.htm) | Chén cơm Việt Nam coi là 1 cup; ½ chén cơm nấu chín là một khẩu phần tinh bột | Nguồn giáo dục, không cho gram |
| Bảng thành phần dinh dưỡng (nguồn thứ cấp, dẫn trong kết quả tìm kiếm) | 1 cup cơm trắng nấu chín = 150 g | Không phải bảng VN |
| Mục "cơm nấu chín" trong bảng USDA (FDC 168878) | 130 kcal/100 g (đã dùng trong `com_trang`) | Dùng cho kcal, không cho gram chén |
| Nhiều trang dinh dưỡng VN (Long Châu, Pharmacity, FPT Shop...) | ~100 g cơm chín ≈ 130 kcal; một bát ~150–200 g cơm chín ≈ 150–250 kcal | Thứ cấp, không thống nhất |
| USDA (1 cup cooked = 186 g) | Cup Mỹ 240 ml, khác chén VN | Không dùng làm chuẩn cho chén VN |

**Kết luận tạm:** giữ 150 g cho 1 chén (khớp PRD và bảng thứ cấp), 75 g cho ½ chén, 300 g và 450 g cho 2 chén và 3 chén (cùng bội số). Kcal của 150 g cơm trắng = 195 kcal (đã kiểm ở mục 1).

**Việc cần làm để chốt chính thức (không thực hiện được trong phiên này):**
1. Cân một bát cơm thường dùng ở nhà (cơm chín) bằng cân nhà bếp, ghi vào `docs/research/` cùng ngày.
2. Hoặc lấy bảng gốc của Viện Dinh dưỡng (VTN_FCT_2007 đã có bản PDF của FAO, `https://www.fao.org/fileadmin/templates/food_composition/documents/pdf/VTN_FCT_2007.pdf`) và tra mục gạo nấu chín, nếu bảng có khối lượng khẩu phần.
3. Nếu kết quả cân lệch quá 10% so với 150 g, cập nhật `rice_habit` gram trong PRD và `data/` (đổi `data_version`).

### 7.3 TC mới

- TC-1-46: kiểm bốn nhãn chén và gram trong ngoặc.
- TC-3-16: màn mâm hiện "1 chén cơm (~150 g)" hoặc "½ chén cơm (~75 g)"; ghi chú giảm cơm dạng "Bữa này bớt còn 1 chén cơm để giữ đúng calo."
