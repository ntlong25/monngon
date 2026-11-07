# Engine notes (T-002 schema → T-009)

Chạy: `npm test` (tsc --noEmit + vitest), `npm run validate-data -- <thư mục>` (mặc định `data/`; thử fixture: `src/engine/__fixtures__`).
Import trong `src/` dùng đuôi `.ts` tường minh (`allowImportingTsExtensions`) để `node` chạy được script validate không cần bundler; Metro/Expo vẫn resolve được.

| Task | File | Ghi chú |
|---|---|---|
| T-002 | `src/types/{schema,profile}.ts`, `src/data/{load,validate,loadFs,validate-cli}.ts`, `__fixtures__/` | zod theo hợp đồng v0.1; phần schema + nạp + validate. Fixture: 12 nguyên liệu, 7 công thức. |
| T-003 | `targets.ts` | Mifflin–St Jeor; sàn thắng trần = `max(sàn, min(mục tiêu, trần))`; trả `steps` cho UI. |
| T-004 | `mealSlots.ts` | `allocateSlots`; `self` giữ phần, `skip` chia lại; lỗi `NoMainMealError`. |
| T-005 | `nutrition.ts`, `units.ts` | macro chưa làm tròn + `roundForDisplay`; trace `source` từng dòng. |
| T-006 | `filter.ts` | `filterRecipes` (lý do loại), `recipesForSlot` (hot/packed, ngọt/mặn, ít tinh bột). |
| T-007 | `scale.ts` | Tìm vét cạn trên ứng viên gram bước 5 g (nhóm protein × nhóm carb). |
| T-008 | `score.ts` | `DEFAULT_SCORE_WEIGHTS` gom trọng số. |
| T-009 | `shopping.ts` | `buildShoppingList`, `servingCostVnd`. |

## Quyết định / giả định cần PM biết
1. **edible_portion**: `grams` của công thức hiểu là gram *ăn được* (macro tính trực tiếp); danh sách đi chợ chia cho `edible_portion` để ra lượng phải mua. RESEARCH cần ghi `grams` theo cách này.
2. **Sàn protein** làm tròn `Math.round` (nguyên g); trần `floor5`. Ví dụ spec: trần 190 g (floor5(192.5)), sàn 139 g, kết quả 175 g.
3. **TDEE ví dụ**: tính không làm tròn BMR → 2762,5 (spec ghi 2.763 do làm tròn BMR 1.783 trước); kcal cuối vẫn 2.200.
4. **Dải calo** mặc định −5%/0% (`TargetOptions`), làm tròn nguyên kcal.
5. **Kiểm 4/4/9**: lấy sai lệch nhỏ hơn giữa công thức thuần và công thức tính xơ 2 kcal/g (carb đã gồm xơ), ngưỡng 15%, chỉ là cảnh báo (rau ít kcal như súp lơ sẽ lệch >15% nếu không tính xơ).
6. **Bảng ánh xạ loại trừ** (`EXCLUSION_BANS`, `DIET_BANS` trong `filter.ts`) là tạm theo hợp đồng; cần đối chiếu `docs/research/allergen-rules.md` (T-041). Đã thêm `no_sesame`, `no_soy` ngoài danh sách trong PRD. `no_red_meat` dựa vào tag `red_meat` trên nguyên liệu (thịt heo phải có cả `pork` và `red_meat`).
7. **Scale** coi "khả thi" khi protein không thiếu quá 3 g và |kcal| ≤ 5%; protein dư quá 3 g không bị coi là infeasible (nhưng bị phạt nhẹ khi chọn nghiệm).
8. **Chi phí tuần** `week_food_cost` (theo gram dùng) và `till_cost` (theo gói) đều làm tròn 1.000 ₫; "nhà có sẵn" do UI truyền vào `pantry_ids` (gợi ý `defaultPantryIds`).

## T-011 cải tiến engine (sau báo cáo đầu)
- **Dung sai xếp hạng món** nới (protein 8 g, kcal 12%) vì validator xét theo ngày; `scale.ts` giữ nguyên dung sai 3 g / 5% để cờ `infeasible` còn nghĩa.
- **Bù chênh giữa các bữa**: tinh chỉnh theo ngày 5 vòng (trước 3), phân phần dư theo tỉ lệ bữa.
- **Món phụ** (`PlanMeal.extras`): khi cả ngày còn thiếu protein/calo, ghép cơm (tinh bột rẻ nhất/kcal trong aisle `gao_do_kho`) hoặc đạm gọn rẻ nhất (aisle thịt/cá, ≥12 g protein/100 kcal) vào bữa sáng/trưa/tối, bội 5 g, tối đa 300 g cơm / 150 g đạm mỗi bữa; không dùng nguyên liệu bị cấm, không thêm cơm vào bữa bị ép ít tinh bột. Macro bữa đã gồm món phụ; danh sách đi chợ tính cả món phụ.
- **Sửa ngân sách** (`repairs`): nếu vẫn vượt ngân sách, đổi bữa tốn nhất sang công thức rẻ hơn cùng bữa hoặc đổi protein/carb sang nguyên liệu rẻ hơn cùng `swap_group` (ghi ở `PlanMeal.substitutions`, `grams` theo nguyên liệu mới), chỉ nhận thay đổi giữ ngày đang đạt và thực sự giảm chi phí.
- `npm run engine-report -- --profiles data/test-profiles.json|tmp --legacy` ; test `src/engine/__tests__/profiles.test.ts` (ngưỡng đạt `PASS_RATE_MIN`, mặc định 0.9).

## Bản cuối engine (2026-11-06)
- Không còn `NoRecipesError`: bữa hết ứng viên → `status:'unfilled'`, `WeekPlan.unfilled_slots`, tuần `partial`; chỉ tiêu dồn sang bữa khác; validator báo ngày thiếu + lượng thiếu.
- `polishDay`: tinh chỉnh ±5 g (protein/carb/món phụ) để giảm vi phạm ngày sau mỗi vòng.
- Chi tiết: `engine-report-final.md`.

## T-051 / T-052 — dải ±5% và TS đóng băng (2026-11-06)
- Dải calo mặc định ±5% (`calorieBand`); baseline: `engine-report-v1-baseline.md`.
- `npm run export-golden` ghi `golden/` (xem `golden/README.md`): vector rng/targets/slots/nutrition/scale + 42 ca `WeekPlan` (14 hồ sơ × seed 1, 2, 3). Phiên bản dữ liệu = SHA-256 `data/*.json`. Đầu ra giống hệt từng byte giữa các lần chạy (có test).
- **TS ĐÓNG BĂNG**: không sửa logic `src/engine/`; chỉ sửa lỗi, và khi đó phải chạy lại `npm run export-golden`. Test `golden/ trên đĩa` bắt trường hợp engine đổi mà golden không xuất lại (chỉ kiểm khi dữ liệu `data/` chưa đổi so với manifest).
- Nếu Research đổi `data/` thì golden cần xuất lại (ca golden phụ thuộc dữ liệu).

## T-093 hậu T-050b (L-02, L-10, L-11)
- **L-02 / TC-1-17:** TC ghi "tắt trưa, tối (chỉ còn sáng)" nhưng US-1.3 AC4 và D-QA-05 coi **sáng là bữa chính**; còn bữa sáng "on" là hợp lệ (API 200). API trả 400 khi cả ba bữa chính không ở "on" (kể cả khi bữa phụ còn bật) — test `Plans_khong_con_bua_chinh_nao_tra_400…`. TC-1-17 cần sửa: dùng "tắt cả sáng, trưa, tối".
- **L-10:** validator (C# và TS) không còn đòi giá `cho_khac` cho nguyên liệu có `purchase_as`; đổi lại đích phải tồn tại, có giá `cho_khac`, không tự trỏ/nối chuỗi. **Lưu ý:** chế độ parity (`full_meal_only`, dùng cho golden) không có `purchase_as` nên vẫn cần giá `com_trang`/`gao_lut_nau_chin`; bỏ hai dòng giá này làm parity và `export-golden` (TS) ném lỗi "Không có giá" (đã thử).
- **L-11:** nguyên nhân: điểm chọn món chỉ phạt lặp từ lần dùng thứ 3 (`FreeUses = 2`) nên engine dồn 14 bữa vào 7 mâm × 2 lần (mọi hồ sơ, mọi seed; seed không đổi kết quả vì tuần chọn tất định theo điểm). Thêm `PlanOptions.NoveltyBonus = 3` cộng cho mâm trưa/tối chưa dùng lần nào trong tuần (không áp dụng ở parity). Kết quả engine-report: 10–11 mâm khác nhau ở các hồ sơ đủ dụng cụ; p09 (chỉ lò vi sóng) 6 và p15 (nồi chiên + nồi cơm) 8 do kho món hạn chế.

## T-094 — lượng cơm theo thói quen (D-COM-01)
- **Tham số:** `preferences.rice_habit` ∈ `it|vua|nhieu|rat_nhieu` = 75/150/300/450 g cơm chín (hằng số ở `RiceHabits` trong `Mam.cs`; thiếu = `vua`; sai giá trị → 400 `preferences.rice_habit`). Cơm trắng và gạo lứt cùng gram; tinh bột khác (bún, khoai) quy theo kcal tương đương cơm trắng, làm tròn 5 g. `low_carb` → mâm không có cơm, không có `rice`/`notes`. Chế độ parity (`full_meal_only`) không đổi (golden giữ nguyên, **không cần xuất lại**: golden chỉ dựng bằng TS/`full_meal_only`, không có mâm).
- **Engine:** dòng tinh bột của mâm (`RecipeIngredient.RiceTargetG/RiceFloorG`, `MamInfo.RiceIdx`) được `Scaler` **ghim** ở mức chọn (`ScaleOptions.RiceOverrideG` để hạ). Gram chuẩn của composite = mức "vừa" (150 g) → người lớn khác trong hộ ăn mức vừa, trẻ 0,6×; chính chủ ăn đúng mức (đi chợ tính gạo theo cơm thực tế). Món chính/canh/rau/tráng miệng co giãn như cũ.
- **Thứ tự cứu ngày không đạt (đúng PRD):** (1) đổi tổ hợp mâm (các vòng lập 0–1 không giảm cơm), (2) từ vòng `RiceRescueFromIteration = 2`: `RescueDayWithRice` giảm cơm từng 25 g (bữa nhiều cơm nhất trước) đến sàn `max(50% mức, 60 g)`, (3) `RescueDayWithFullMeal` đổi một bữa mâm sang trọn suất, (4) không đạt (partial). Ngoài ra khi chọn món `ScaleMeal` hạ cơm trước nếu bữa lệch >10% kcal (`RiceSlotKcalTolPct`, đã thử 5%/10%/15%/20%/30%: 5–15% cho quá nhiều ghi chú; 30% còn 2/16 hồ sơ >20%; chọn 0,30) và phạt điểm `RiceReducePenalty` cho mâm phải hạ cơm.
- **API/ghi chú:** mỗi bữa mâm có cơm trả `rice{habit,target_g,actual_g}`; `actual_g < target_g − 10` → `notes[{code:"rice_reduced",target_g,actual_g,reason:"kcal"|"protein"}]` (tính hậu kỳ ở `FillRice`, nên không thể giảm mà thiếu ghi chú). Khi chỉnh tuần chỉ tính lại cho bữa đổi; ngày đã qua giữ mức cũ. Đổi món giữ mức cơm (`TrialSwap` dùng `ScaleMeal`, chỉ bớt cơm của chính bữa đó khi ngày không đạt).
- **Sửa lỗi có sẵn gặp trên đường:** `RepairBudget` nhận biết "đổi nguyên liệu" bằng `key.Contains('~')`, nhưng id mâm trưa mang đi cũng kết thúc bằng `~L` ⇒ đổi sang mâm `~L` bị coi là đổi nguyên liệu (RecipeId giữ, Grams của mâm khác ⇒ ném `ArgumentOutOfRange`). Nay dùng `Subs.Count == 0`.
- **Kết quả (seed 1, data hiện có)** — `docs/dev/engine-report-rice.md`: 16/16 hồ sơ 7/7 ở cả 4 mức; mức vừa: 98% bữa trưa/tối là mâm, 0 vi phạm cứng, 0 bữa cơm dưới sàn/không ghi chú; ghi chú giảm cơm TB 9% (it 1%, nhiều 34%, rất nhiều 64%). **Mức vừa có 2 hồ sơ >20% bữa có ghi chú: p01 (92%, cơm trung vị 88 g) và p02 (23%)** — hai hồ sơ ~1.350–1.400 kcal ăn nhiều đạm; báo hub, không tự đổi gram. Ma trận p01 × 4 mức: cơm trung vị và gạo sống cần mua tăng dần (test `P01_bon_muc…`).
- **Test tự động đã nới (kèm lý do):** `BudgetTests` dung sai ước tính 2% → 3%; `DessertTests` p01 ≥ 2 tráng miệng khác nhau (trước ≥ 3); `MamTests.Tuan_14…` p04 ≥ 9 (trước ≥ 10), p10 ≥ 8 (trước ≥ 9) — cơm ghim làm tổ hợp mâm của hồ sơ chật calo/ngân sách đổi nhẹ.

## T-096 — giữ cơm khi chọn mâm (D-COM-02)
- **Nguyên nhân (PRD §10 D-COM-02):** vòng chọn bữa chấm mâm bằng điểm cộng (khẩu vị, xu hướng, chống lặp); giảm cơm chỉ bị trừ `RiceReducePenalty × riceShort` (≈ vài điểm) nên mâm hợp khẩu vị nhưng không đủ chỗ cho cơm vẫn thắng → p01 mức vừa có 92% bữa mâm giảm cơm.
- **Luật mới (thứ tự từ điển):** mỗi ứng viên mâm lunch/dinner được chấm "giữ được cơm" bằng `ScaleMeal(..., strict: true)` với đích = chỉ tiêu bữa − ước lượng tráng miệng (`RiceDessertEstKcal` 50 kcal / `RiceDessertEstProteinG` 2 g) — `Scaler` coi khả thi (đạm không thiếu quá dung sai, kcal ±5%) khi cơm ghim đúng mức thì là "giữ". Vòng chọn bữa xếp **mọi ứng viên giữ cơm trước mọi ứng viên phải giảm cơm**, điểm mềm chỉ xếp hạng trong cùng nhóm (`keeps` trong `PlanWeek.cs`). Chấm điểm pool cũng trừ `RiceKeepPenalty` (1000) cho ứng viên phải giảm cơm để pool không lọc mất ứng viên giữ cơm. Bữa nguyên (không phải mâm) ở trưa/tối **không** tính là "giữ cơm" (nếu tính, mức nhiều/rất nhiều sẽ bỏ mâm hàng loạt để khỏi phải bớt cơm — đã đo 192 g gạo/tuần cho p01 rất nhiều).
- **Một canh mỗi mâm:** `MamBuilder` bỏ canh phụ khi món chính đã là canh (`cuisine_tags` có `canh`).
- **Bữa phụ ≥ 40 kcal (P1):** `PlanOptions.SnackMinKcal = 40` (0 = tắt; parity không áp dụng): `RefineDay` không kéo đích kcal của bữa phụ xuống dưới 45 (dư 5 vì gram làm tròn) và `PolishDay` không bước giảm làm bữa phụ rơi dưới 40. Không dùng trạng thái `skipped` để "bỏ trống" bữa phụ vì `IsOut` miễn kiểm cả ngày. Test: `RiceTests.T096_bua_phu_len_mon_phai_tu_40_kcal` (mọi hồ sơ × 4 mức).
- **Công tắc đo trước/sau:** `PlanOptions.RiceKeepFirst` (mặc định true); `engine-report --rice-keep-first false` tắt xếp hạng giữ cơm. Cột mới: `khẩu vị thích: x% bữa mâm khớp · n loại tráng miệng/tuần` (`EngineReport.LikeMatchOf`, `ProfileResult.DessertKinds`).
- **Kết quả** (`docs/dev/engine-report-rice.md`, 3 seed): mức vừa — p01 0% bữa mâm giảm cơm (trước: 64–67%), trung vị 150 g, trung bình 16 hồ sơ 0%, không hồ sơ nào > 20%, 98% bữa là mâm; nhiều/rất nhiều — TB ghi chú 21%/64% (T-094: 34%/64%), các hồ sơ > 20% đều thuộc mức bị cảnh báo ở onboarding; 16/16 hồ sơ 7/7 ở 4 mức, 0 vi phạm cứng.
- **Đánh đổi cần biết:** p01 mức vừa khớp khẩu vị thích 85–92% (vẫn ≥ 50%) nhưng chỉ còn 3 loại tráng miệng/tuần (trước 4–6) và 9 món trưa/tối khác nhau/14 bữa; p02 (ngân sách 600k) còn ~71% bữa mâm vì ngân sách, không phải vì cơm. Thời gian lập tuần mức nhiều/rất nhiều tăng (TB ~0,8–1,1 s, tối đa ~3,7 s) vì chấm "giữ cơm" thêm một lần `ScaleMeal` mỗi ứng viên.
- **Test khôi phục:** `DessertTests` p01 ≥ 3 loại/tuần (dữ liệu thật; bộ 3 món giả vẫn ≥ 2), `MamTests.Tuan_14…` mọi hồ sơ ≥ 9 và p03/p04/p07 ≥ 10 (p10 đạt 11). `p01` còn 9 món — chưa khôi phục ≥ 10 (đã báo hub). `RiceTests.P01_bon_muc…` chỉ còn khẳng định trung vị không giảm theo mức và gạo it < vừa (mức cao bị trần kcal của p01 nên bữa nguyên không cơm thay mâm bớt cơm). Test mới: `T096_*` ×4. Baseline: Engine 206, Api 46.
