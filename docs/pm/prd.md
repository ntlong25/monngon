# PRD — FitPro - Mâm đủ: lập thực đơn tuần theo protein/calo và ngân sách cho người Việt

> Trạng thái: **v0.2 — đã có quyết định Q1–Q8 (§10); ADR-001 đã chấp nhận; tên app: FitPro - Mâm đủ** · Cập nhật: 2026-11-06 · Tác giả: PM session
> Nguồn: spec phân tích Mealbird (claude.ai/artifact/TtUky6QQWVogpfjuKt1C2M), khung hình `docs/video-frames/`.
> Mã yêu cầu `F-…`, `NFR-…` dẫn chiếu tới spec. Backlog chi tiết: [backlog.md](backlog.md). Kiến trúc engine: [adr-001-engine-location.md](adr-001-engine-location.md).
>
> **Thay đổi v0.2:** stack Flutter + backend .NET (thay Expo); dải calo ±5%; bữa trưa/tối ghép mâm; ảnh placeholder; freemium (§12); tên app "FitPro - Mâm đủ" (§11).

**Nguyên tắc sản phẩm riêng:** Mealbird chỉ là nguồn cảm hứng về *cơ chế* (chỉ tiêu theo ngày, validator, minh bạch số liệu, đi chợ theo bao bì). Không dùng tên, logo, linh vật chim, ảnh, màu sắc nhận diện hay câu chữ của Mealbird. Mọi chuỗi UI tiếng Việt do đội tự viết (task RESEARCH). Món ăn là món Việt thật (cơm, canh, kho, xào), không phải món Tây dịch tên.

---

## 1. Vấn đề và cơ hội

- Người Việt tập luyện / muốn giảm mỡ khó ăn đủ protein mỗi ngày với mâm cơm gia đình quen thuộc; app nước ngoài dùng món Tây, giá đô la, nguyên liệu khó mua.
- Người bận rộn muốn đi chợ 1 lần/tuần nhưng không biết mua bao nhiêu, hết bao nhiêu tiền.
- App ghi nhật ký ăn uống (MyFitnessPal…) bắt người dùng nhập liệu hằng ngày → bỏ cuộc. Sản phẩm này là **planner**: lập sẵn tuần đạt chỉ tiêu, người dùng chỉ việc nấu (NFR-09).

## 2. Mục tiêu MVP

| # | Mục tiêu | Đo bằng (khi có người dùng thử) |
|---|----------|------------------|
| G1 | Từ mở app tới có thực đơn 7 ngày trong ≤ 5 phút | Thời gian hoàn thành onboarding (đo tay khi test) |
| G2 | Mỗi ngày trong 7 ngày đạt sàn protein và nằm trong dải calo | ≥ 90% tuần sinh ra cho bộ hồ sơ test đạt 7/7 ngày; 100% tuần không đạt đều báo rõ ngày + mức thiếu |
| G3 | Chi phí tuần ước tính ≤ ngân sách người dùng chọn | ≥ 90% tuần test nằm trong ngân sách |
| G4 | Thực đơn "giống cơm nhà" với người Việt | ≥ 4/5 điểm cảm nhận trong test nội bộ với 5 người |
| G5 | Mọi con số dinh dưỡng truy ngược được tới nguồn | 100% món có "Cách chúng mình tính" hiển thị đủ nguồn từng nguyên liệu |

**Không phải mục tiêu MVP:** doanh thu, đăng ký tài khoản, đồng bộ đa thiết bị, đa ngôn ngữ.

## 3. Persona

**P1 — Linh, 27 tuổi, nhân viên văn phòng HN, đang giảm mỡ.** Tập gym 3 buổi/tuần, được PT dặn ăn 100–110 g protein. Ở trọ 1 mình, tự nấu trưa mang đi + tối, không ăn sáng ở nhà. Ngân sách 600–800 nghìn/tuần, đi Bách hóa Xanh/WinMart. Nỗi đau: ngày nào cũng nghĩ "ăn gì cho đủ đạm", hay mua thừa rau rồi bỏ.

**P2 — Anh Tuấn, 34 tuổi, TP.HCM, tăng cơ, nấu cho cả nhà.** Vợ + 1 con nhỏ ăn cùng mâm. Chỉ tiêu dinh dưỡng là của riêng anh, nhưng danh sách đi chợ phải đủ cả nhà. Ngân sách 1,5–2 triệu/tuần, đi Co.opmart. Muốn món quen (cá kho, thịt rang, canh) và biết rõ "phần của anh" bao nhiêu gram.

**P3 — Chị Mai, 45 tuổi, ăn chay thứ Hai/rằm, cần giữ cân và tiểu đường type 2 nhẹ.** Không thích gợi ý món lạ, cần ít tinh bột, cần thông báo rõ app không thay lời khuyên bác sĩ (NFR-08). *(Persona phụ — MVP chỉ hỗ trợ chay cả tuần, chưa hỗ trợ chay theo ngày.)*

## 4. Phạm vi

### 4.1 Trong phạm vi MVP (theo thứ tự ưu tiên — mục 7 spec)

| Ưu tiên | Epic | Yêu cầu spec | Ghi chú cho bản Việt |
|---|---|---|---|
| P0-1 | **Onboarding + công thức chỉ tiêu** | F-ONB-01…10, mục 4.8 | Bỏ chọn quốc gia (chỉ VN). Cửa hàng: Bách hóa Xanh, WinMart, Co.opmart, Chợ truyền thống/Nơi khác. |
| P0-2 | **Bộ máy lập tuần + validator** | F-ENG-01…08 | Engine **tất định, dựa trên luật, không dùng LLM**. Bản tham chiếu TS đã xong; port sang **C#/.NET API** (ADR-001). Bữa trưa/tối **ghép mâm** (§6.2). |
| P0-3 | **Tab Kế hoạch + trang công thức** | F-PLN-01…03, F-RCP-01…04 | Có "phần của bạn" và "cả nồi"; chế độ nấu giữ màn hình sáng. |
| P0-4 | **Tab Đi chợ** | F-SHP-01…06 | Không có deep link giao hàng (F-SHP-07 để sau). |
| P1-5 | **Đổi món / ăn ngoài** | F-CHG-01, 02, 03, 04, 07 | F-CHG-05 (bỏ thực phẩm) làm qua tab Bạn + lên lại; F-CHG-06 (dời ngày) là P2. |
| P1-6 | **Tab Bạn (tối thiểu)** | 4.6 | Sửa chỉ tiêu, sửa lựa chọn onboarding, bỏ chặn món, miễn trừ y tế, xóa dữ liệu. |
| P2 | Freemium + paywall | F-PAY-01…03 (đổi sang freemium) | **Để sau MVP.** Ranh giới free/premium ở §12. MVP chạy như bản free nhưng **chưa chặn** giới hạn nào; chừa chỗ trong luồng. |
| P2 | Web ReactJS | — | Làm sau khi mobile xong, dùng chung API .NET. |

### 4.2 Ngoài phạm vi MVP
- Tài khoản, đăng nhập, đồng bộ. MVP có **backend .NET stateless** (chỉ tính toán + phục vụ dữ liệu seed), còn trạng thái người dùng lưu trên máy.
- Thu phí: paywall, thanh toán App Store/Google Play/ví nội địa (để P2, theo §12).
- Web ReactJS (P2, sau mobile).
- Đa ngôn ngữ (chỉ tiếng Việt; vẫn tách chuỗi ra file để dịch sau), đơn vị imperial.
- Crawl giá tự động — MVP dùng bảng giá khảo sát tay, gắn nhãn "ước tính" và ngày khảo sát.
- Giao hàng (GrabMart/ShopeeFood), thông báo đẩy, widget.
- Chay theo ngày (mùng 1/rằm), thực đơn riêng cho trẻ em, nhiều người cùng có chỉ tiêu riêng.
- Ghi nhật ký ăn uống, quét mã vạch, cân.
- Ảnh món thật: MVP dùng **ảnh placeholder**; người dùng sẽ cung cấp ảnh sau (Q5). Trường `image` trong dữ liệu để `null`, app hiển thị placeholder theo nhóm món.
- Bữa sáng/bữa phụ ghép mâm (chỉ trưa/tối ghép mâm).

## 5. User story và tiêu chí chấp nhận

Quy ước: **US-x.y**, AC = acceptance criteria dạng kiểm được. Số liệu ví dụ lấy từ spec.

### Epic 1 — Onboarding + chỉ tiêu (P0-1)

**US-1.1 Đặt chỉ tiêu theo cơ thể.** Là người dùng mới, tôi nhập mục tiêu và chỉ số cơ thể để app tính protein tối thiểu và calo mỗi ngày.
- AC1: Nhập được mục tiêu (Giảm mỡ / Giữ cân / Tăng cơ), giới tính, tuổi (14–90), chiều cao (120–220 cm), cân nặng (30–250 kg), 5 mức vận động; ngoài khoảng → báo lỗi tại chỗ, nút Tiếp tục bị khóa.
- AC2: Công thức đúng mục 4.8 spec: BMR (Mifflin–St Jeor) × hệ số vận động × hệ số mục tiêu, làm tròn 50 kcal; cân nặng tham chiếu; protein theo g/kg làm tròn 5 g; trần 35% calo; sàn thắng trần.
- AC3: Với ví dụ của spec (nam 30t, 177,8 cm, 81,6 kg, vừa vận động, giảm mỡ) app ra **2.200 kcal** và **175 g protein**.
- AC4: Màn kết quả hiển thị từng dòng phép tính (BMR → TDEE → mục tiêu → protein) và cho phép chuyển sang "Tự nhập" protein/calo.
- AC5: Dải calo lập tuần = **[mục tiêu − 5%, mục tiêu + 5%]** (quyết định Q3); protein vẫn là **sàn** (≥ protein tối thiểu, không có trần ở validator).

**US-1.2 Chọn cửa hàng, số người ăn, ngân sách** (thứ tự bước: cửa hàng → hộ gia đình → ngân sách, theo D-ONB-01).
- AC1: Chọn đúng 1 cửa hàng trong danh sách; thẻ được chọn có trạng thái rõ ràng; có chú thích "giá là ước tính".
- AC2: Thanh trượt ngân sách theo bước 50.000 ₫; min/max tính theo chỉ tiêu (đã có từ US-1.1), số người lớn + trẻ em, số bữa và cửa hàng (công thức ở §10, quyết định D-BUD-01); hiển thị nhãn bậc chi tiêu (3 bậc) đổi theo vị trí; vị trí mặc định = mức ước tính.
- AC2b: Ngân sách là **chi phí món ăn trong tuần** (phần nguyên liệu thực sự dùng). Dưới thanh trượt ghi rõ: "Lần đi chợ đầu có thể cao hơn vì mua nguyên chai dầu, nước mắm, gạo…". Con số "trả tại quầy" hiện ở tab Đi chợ (F-SHP-03).
- AC2c: Ở màn tổng kết, nếu sau khi khai báo kiêng/dụng cụ mà ngân sách đã chọn thấp hơn mức tối thiểu khả thi, app báo trước và gợi ý mức tối thiểu (không chặn).
- AC3: Stepper người lớn (1–6), trẻ em (0–4); ghi chú "chỉ tiêu dinh dưỡng là của riêng bạn".
- AC4: Định dạng tiền vi-VN: `600.000 ₫`.

**US-1.3 Chọn bữa cần lên thực đơn.**
- AC1: 5 slot: Sáng, Trưa, Tối, Phụ sáng, Phụ chiều. Bữa chính có 3 chế độ: Lên thực đơn / Tôi tự lo / Không ăn; Trưa có Nóng/Mang đi; Phụ chiều có Ngọt/Mặn.
- AC2: Chân màn hình hiển thị phân bổ "mỗi bữa ~X kcal và Y g protein", cập nhật ngay khi đổi.
- AC3: "Tôi tự lo" giữ lại phần chỉ tiêu dự kiến cho bữa đó (không lên món); "Không ăn" chia lại chỉ tiêu cho các bữa còn lại.
- AC4: Không cho tắt hết bữa chính (còn ≥ 1 bữa chính được lên thực đơn).

**US-1.4 Khai báo kiêng/dị ứng và món ghét.**
- AC1: Chọn nhiều; "Không kiêng gì" loại trừ các lựa chọn khác; chỉ chọn tối đa 1 trong Chay / Thuần chay / Chay có cá; "Ít tinh bột" kết hợp được với tất cả. "Ít tinh bột" là **ràng buộc cứng** (cờ `low_carb`), nằm trong nhóm "Chế độ ăn", không thuộc nhóm "Xu hướng nấu ăn" (D-ONB-02).
- AC2: Loại bỏ hoàn toàn (không lợn, không thịt đỏ, không gluten, không sữa, không trứng, không lạc, không hạt cây, không hải sản có vỏ, không cá…) là **ràng buộc cứng**: nguyên liệu bị loại không bao giờ xuất hiện trong tuần (kiểm bằng test tự động).
- AC3: Phân loại dị ứng theo quy tắc của RESEARCH (`docs/research/allergen-rules.md`): lạc ≠ hạt cây; hạt hướng dương/vừng là "hạt giống" có cờ riêng — UI phải nói rõ phạm vi từng lựa chọn.
- AC4: Ô tìm nguyên liệu không muốn thấy có autocomplete không dấu ("rau muong" tìm được "Rau muống"); chip gợi ý ≥ 6 nguyên liệu hay bị ghét.
- AC5: "Xu hướng nấu ăn" gồm Nhiều chất xơ, Ít đường, Tốt cho tim mạch, Ít béo (D-HLT-01). Đây chỉ là ưu tiên mềm, luôn kèm dòng miễn trừ y tế. PCOS và Chống viêm không có trong MVP.

**US-1.4b Thói quen ăn cơm** (D-COM-01; bước ngay sau US-1.4).
- AC1: Câu hỏi "Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?" với 4 lựa chọn. **Nhãn chính là số chén, gram trong ngoặc chỉ để gợi ý**: "½ chén (~75 g)" / "1 chén (~150 g)" (chọn sẵn) / "2 chén (~300 g)" / "3 chén trở lên (~450 g)". Lựa chọn ½ chén có dòng phụ "Ít cơm, ăn nhiều thức ăn". Gram mỗi chén theo số Research chốt ở T-059c.
- AC2: Đã chọn "Ít tinh bột" ở US-1.4 thì bỏ qua bước này; màn tổng kết ghi "Ít tinh bột: mâm không có cơm".
- AC3: Mức đã chọn chiếm > 45% kcal trung bình một bữa chính thì hiện dòng cảnh báo "một số bữa sẽ phải bớt cơm"; không chặn Tiếp tục.
- AC4: Màn tổng kết (US-1.6) hiện mức đã chọn; sửa được ở tab Bạn (US-6.1), đổi xong lên lại các ngày còn lại của tuần.

**US-1.5 Khẩu vị bằng thẻ vuốt và dụng cụ bếp.**
- AC1: 12–16 thẻ xu hướng món Việt; vuốt phải = thích, trái = ít hơn; có nút ✕ / hoàn tác / ♥ cho người không vuốt được (trợ năng).
- AC2: Màn kết quả liệt kê thích / ít hơn, có "Vuốt lại"; kết quả chỉ là trọng số mềm.
- AC3: Chọn nhiều dụng cụ (bếp, nồi cơm điện, lò vi sóng, nồi chiên không dầu, lò nướng, nồi áp suất, máy xay); bắt buộc ≥ 1 thiết bị nấu; công thức cần dụng cụ không có không bao giờ được chọn.

**US-1.6 Tổng kết và tạo tuần.**
- AC1: Màn checklist hiển thị lần lượt: mục tiêu, protein tối thiểu, calo, số bữa, xu hướng, đã loại, căn bếp, ngân sách — đúng giá trị người dùng chọn.
- AC2: Tạo tuần không chặn UI; trên máy tầm trung (hoặc web) hoàn tất ≤ 5 giây với dữ liệu MVP.
- AC3: Tuần bắt đầu từ ngày mai (theo giờ máy); xong thì chuyển sang tab Kế hoạch.
- AC4: Quay lại bất kỳ bước nào giữ nguyên lựa chọn; tắt app giữa chừng mở lại tiếp tục đúng bước.

### Epic 2 — Bộ máy lập tuần + validator (P0-2)

**US-2.1 Tuần đạt chỉ tiêu từng ngày.**
- AC1: Mỗi ngày: tổng protein ≥ sàn **và** kcal trong dải; không lấy trung bình tuần.
- AC2: Macro luôn tính bằng Σ gram × giá trị/100 g của nguyên liệu; không có số liệu nhập tay ở cấp món.
- AC3: Engine chỉ được chỉnh gram của dòng **scale được** (vai trò "đạm", "tinh bột", và dòng chính của tráng miệng) trong biên [min, max] của công thức để khớp chỉ tiêu bữa; **mọi gram luôn nằm trong [min, max]**. Dòng scale được làm tròn 5 g. Dòng cố định (`min_g = max_g`: dầu, gia vị, rau cố định, đường trong chè) giữ nguyên gram của công thức, không làm tròn (D-QA-04).
- AC5: Bữa trưa/tối là **một mâm**: hoặc 1 món trọn suất (`full_meal`), hoặc 1 món chính + tối đa 1 canh + tối đa 1 món rau + cơm (bỏ cơm nếu Ít tinh bột). Chỉ tiêu bữa áp cho **tổng cả mâm** ("miễn đủ chất"). Mâm không có 2 món chính trùng nhóm đạm. Lượng cơm của mâm theo câu trả lời ở US-1.4b (`rice_habit`), các món khác co giãn để giữ chỉ tiêu; chỉ giảm cơm khi bắt buộc, có sàn, và luôn kèm ghi chú cho người dùng (D-COM-01).
- AC6: Mọi bữa trưa/tối được lên thực đơn (cả mâm lẫn `full_meal`) có **đúng 1 món tráng miệng** (D-DES-01), tính vào macro và calo của bữa. Bữa sáng và bữa phụ không có tráng miệng ở MVP.
- AC4: Cùng đầu vào + cùng seed → cùng kết quả (tất định, test được).

**US-2.2 Trung thực khi không đạt.**
- AC1: Nếu không tìm được tuần đạt 7/7, vẫn trả tuần tốt nhất kèm trạng thái `partial`, danh sách ngày thiếu và mức thiếu (vd "Thứ Năm thiếu 8 g protein").
- AC2: Banner ở tab Kế hoạch báo số ngày không đạt; không bao giờ ẩn.

**US-2.3 Ngân sách và tái sử dụng món.**
- AC1: Chi phí thực phẩm ăn trong tuần ≤ ngân sách; nếu không thể → báo vượt bao nhiêu.
- AC2: Món chính lặp có chủ đích (mặc định ~10–12 món khác nhau cho 14 bữa trưa+tối; "nấu 1 lần ăn 2 bữa"); bữa phụ xoay vòng 2–3 món. Ngoại lệ cho hồ sơ ít dụng cụ hoặc kho món hẹp: ≥ 6 món khác nhau (D-DIV-01).
- AC3: Không có món chính giống hệt nhau ở 2 bữa liên tiếp trong cùng ngày.

**US-2.4 Tôn trọng sở thích.**
- AC1: Ràng buộc cứng (dị ứng, chay, ghét, dụng cụ, ít tinh bột) không bao giờ bị vi phạm — test với ≥ 10 hồ sơ.
- AC2: Xu hướng thích được ưu tiên: trong tuần test, tỉ lệ món thuộc xu hướng "thích" cao hơn tuần không có sở thích.

### Epic 3 — Tab Kế hoạch + trang công thức (P0-3)

**US-3.1 Xem tuần.**
- AC1: Thanh tab dưới: Kế hoạch · Đi chợ · Bạn.
- AC2: Lời chào theo giờ; trạng thái tuần ("Tuần của bạn bắt đầu từ ngày mai"/"Hôm nay là ngày 3"); banner kết quả validator.
- AC3: 7 ngày cuộn dọc, mỗi ngày có tiêu đề "Thứ Hai · 26/10" và tổng protein/kcal; mỗi bữa: ảnh, nhãn bữa, thời gian nấu, tên món; nhãn "Nấu 1 lần cho 2 bữa" khi lặp.
- AC4: Bữa "Tôi tự lo"/"Ăn ngoài" hiển thị dạng dòng mờ, không có món.

**US-3.2 Xem và nấu công thức.**
- AC1: Bố cục: ảnh, ngữ cảnh (THỨ HAI · BỮA TRƯA), tên, thời gian, chip macro (protein nổi bật, kcal, tinh bột, béo), link "Cách chúng mình tính", nút "Đổi món này", "Ăn ngoài / bỏ bữa", thẻ Nguyên liệu, thẻ Cách làm, link "Không hợp với tôi".
- AC2: Nguyên liệu: tên + gram + quy đổi đơn vị bếp (thìa canh, thìa cà phê, tép, bát, quả…) khi có.
- AC3: Hộ > 1 người: hai cột "Phần của bạn" và "Cả nồi" (người lớn khác = khẩu phần chuẩn, trẻ em = 0,6 khẩu phần, đã chốt ở Q6).
- AC6: Bữa ghép mâm: màn bữa hiển thị các món của mâm (món chính, canh, rau, cơm, **tráng miệng**) thành từng thẻ; mỗi món mở công thức riêng; chip macro ở đầu là tổng cả mâm.
- AC7: Ảnh: placeholder theo nhóm món (kho, xào, canh, luộc/hấp, cơm, bữa sáng, bữa phụ), không lỗi khi `image` = null.
- AC4: Chạm từng bước để đánh dấu xong; màn hình luôn sáng khi ở trang công thức (`wakelock_plus`), tắt khi rời trang.
- AC5: kcal hiển thị khớp 4/4/9 trong sai số ±5% (kiểm tra chéo).

**US-3.3 "Cách chúng mình tính".**
- AC1: Bảng từng nguyên liệu: gram × giá trị/100 g = protein, kcal, tinh bột, béo; tổng cuối khớp chip macro.
- AC2: Mỗi dòng ghi nguồn: "Bảng TPDD VN 2007 · mã …" hoặc "USDA FDC #…".

### Epic 4 — Đi chợ (P0-4)

**US-4.1 Danh sách mua theo quầy.**
- AC1: Gộp nguyên liệu cả tuần × số người ăn, nhóm theo quầy (Thịt · Cá & hải sản · Trứng & đậu phụ · Rau củ · Trái cây · Gạo & đồ khô · Gia vị & dầu · Sữa).
- AC2: Quy ra số gói theo quy cách bao bì của cửa hàng đã chọn (vd cần 410 g ức gà → 1 khay 500 g); ghi phần dư.
- AC3: Hai con số: "Chi phí món ăn tuần này" và "Ước tính trả tại quầy". **Trạng thái ngân sách so theo chi phí món ăn** (D-QA-02). Nếu tiền tại quầy vượt ngân sách thì hiện thêm một dòng **thông tin** (không phải cảnh báo đỏ) giải thích lý do. Nhãn "ước tính" + ngày khảo sát giá ở mọi nơi có giá.
- AC4: Đánh dấu đã mua; đánh dấu "nhà có sẵn" (gia vị, dầu, gạo mặc định gợi ý có sẵn); trạng thái lưu lại khi tắt app.
- AC5: Nút chia sẻ gửi danh sách dạng văn bản qua share sheet hệ điều hành (Zalo, Ghi chú, Messenger…).

### Epic 5 — Thay đổi tuần (P1-5)

**US-5.1 Đổi món.** AC1: gợi ý 2–3 món cùng loại bữa, mỗi món hiển thị chênh lệch protein/kcal/chi phí; chỉ gợi ý món giữ ngày đó vẫn đạt (nếu không có, nói rõ và cho chọn món "gần đạt nhất" kèm cảnh báo). AC2: Sau khi đổi, validator chạy lại, danh sách đi chợ cập nhật.

**US-5.2 Đổi một nguyên liệu.** AC1: chỉ hiện nguyên liệu cùng nhóm thay thế (`swap_group`) và không vi phạm ràng buộc cứng; AC2: gram tính lại để giữ protein bữa trong ±5%.

**US-5.3 Ăn ngoài / bỏ bữa.** AC1: Bữa được đánh dấu, các bữa khác trong ngày giữ nguyên; AC2: ngày đó không bị tính "không đạt" (hiển thị "có bữa ngoài"); AC3: nguyên liệu của bữa rút khỏi danh sách đi chợ nếu chưa đánh dấu đã mua; AC4: hoàn tác được.

**US-5.4 Không hợp với tôi.** AC1: món bị chặn khỏi các tuần sau; AC2: bỏ chặn được ở tab Bạn.

**US-5.5 Lên lại phần còn lại của tuần.** AC1: giữ nguyên các ngày đã qua và hôm nay; tạo lại các ngày sau; AC2: banner "Đã lên lại tuần" + kết quả validator. AC3: lưu tuần cũ vào "Tuần đã lưu".

### Epic 6 — Tab Bạn (P1-6)
**US-6.1** Sửa chỉ tiêu (theo công thức hoặc tự nhập) và mọi lựa chọn onboarding; thay đổi áp dụng cho tuần tạo kế tiếp, có nút "Lên lại tuần này với lựa chọn mới". **US-6.2** Danh sách món đã chặn, bỏ chặn. **US-6.3** Miễn trừ y tế, nguồn dữ liệu dinh dưỡng và giá, nút xóa toàn bộ dữ liệu (có xác nhận).

## 6. Giải pháp kỹ thuật (đã chốt ngày 2026-11-06, xem §10 và ADR-001)

### 6.1 Kiến trúc và tech stack

```
Flutter app (Android/iOS) ──HTTPS/JSON──► ASP.NET Core API (.NET 10) ──► MonNgon.Engine (C#, thuần, tất định)
   cache tuần/công thức/đi chợ                stateless ở MVP                 + dữ liệu seed JSON (nạp khi khởi động)
Web ReactJS (P2, sau mobile) ──────────────────┘ cùng API
```

| Lớp | Lựa chọn | Lý do |
|---|---|---|
| Mobile | **Flutter (Dart, kênh stable)**: `go_router`, `flutter_riverpod`, `dio`, `freezed` + `json_serializable`, `shared_preferences`/`hive` cho cache, `wakelock_plus` (chế độ nấu), `share_plus` (đi chợ), `intl` + ARB `vi` | Người dùng chọn. Một codebase Android/iOS/iPad. |
| Backend | **ASP.NET Core Minimal API, .NET 10 LTS**, `System.Text.Json`, OpenAPI. Engine tách thành class library `MonNgon.Engine` không phụ thuộc web | Người dùng là dev .NET, tự bảo trì được. Web dùng chung. Sẵn cho freemium và LLM về sau. |
| Engine | Port 1-1 từ engine TS hiện có (bản tham chiếu, đóng băng), kiểm bằng **golden test** | Giữ nguyên chất lượng đã đạt (166 test, 0 vi phạm ràng buộc cứng) |
| Test | xUnit (backend), `flutter_test` + widget test (mobile); kịch bản thủ công ở `docs/research/test-scenarios.md` | |
| Hợp đồng API | OpenAPI → sinh client Dart (sau này cả TS cho web) | Hai frontend không lệch hợp đồng |
| Dữ liệu | JSON seed trong `data/` (RESEARCH sở hữu), backend nạp và validate khi khởi động; lỗi dữ liệu thì không khởi động | Cập nhật giá/công thức không cần phát hành app |
| Web (P2) | ReactJS + TypeScript, client sinh từ OpenAPI | Người dùng chọn |
| Chạy local | API `http://localhost:5xxx`; Android emulator gọi `10.0.2.2`; Docker cho triển khai | |

### 6.2 Engine lập tuần (thuật toán, không LLM)
1. **Lọc cứng** nguyên liệu → món hợp lệ (dị ứng, chế độ ăn, ghét, dụng cụ, ít tinh bột, món bị chặn).
2. **Phân bổ chỉ tiêu theo bữa** (tỉ lệ mặc định: trưa 35%, tối 35%, sáng 20%, phụ 5%/5%, chuẩn hóa theo bữa được bật).
3. **Chọn món / ghép mâm** cho từng slot theo điểm: khớp macro sau khi scale, sở thích mềm, chi phí, phạt lặp/đơn điệu; tái sử dụng món chính ("nấu 1 lần ăn 2 bữa"). Trưa/tối có hai dạng:
   - `full_meal`: 1 công thức trọn suất;
   - **mâm**: 1 `main` + 0–1 `soup` + 0–1 `side_veg` + cơm (`carb_base` hoặc nguyên liệu cơm), bỏ cơm nếu Ít tinh bột. Engine TS hiện đã có tiền thân là "món phụ" (`PlanMeal.extras`, ghép cơm/đạm gọn); bản C# mở rộng thành mâm thật dựa trên `dish_role`.
4. **Scale gram** của `protein`/`carb` (cả cơm của mâm) trong biên để khớp bữa, rồi tinh chỉnh theo ngày (`refineDay`, `polishDay`).
5. **Validator** từng ngày: protein ≥ sàn, kcal trong **[mục tiêu −5%, +5%]**; chi phí tuần ≤ ngân sách. Không đạt thì thử lại theo seed / sửa ngân sách, rồi trả tuần tốt nhất kèm báo cáo thiếu (`partial`, `unfilled_slots`).

**LLM ở v2/v3**, chỉ chạy ở backend: soạn nháp công thức mới (người duyệt; số liệu vẫn tính từ bảng), phân tích khẩu vị từ hành vi, chuyển yêu cầu tự do thành lựa chọn cho engine. LLM **không bao giờ sinh số liệu dinh dưỡng** (F-ENG-03).

### 6.3 Dữ liệu dinh dưỡng và giá
- Nguồn dinh dưỡng ưu tiên: **Bảng thành phần thực phẩm Việt Nam (Viện Dinh dưỡng, 2007)**; thiếu thì **USDA FoodData Central** (ghi FDC ID). Mỗi nguyên liệu ghi rõ nguồn + mã.
- Hiện có: 46 nguyên liệu, 137 công thức. Mục tiêu MVP: ≥ 110 nguyên liệu, đủ món phụ (canh, rau) cho ghép mâm, đủ món cho các hồ sơ khó (lò vi sóng, thuần chay, mang đi).
- Giá: khảo sát tay trên website Bách hóa Xanh / WinMart / Co.opmart, có ghi ngày; "Chợ/Nơi khác" là mức trung bình. Mọi giá luôn gắn nhãn "ước tính".

### 6.4 Cấu trúc thư mục & quyền sở hữu
| Đường dẫn | Chủ sở hữu |
|---|---|
| `src/` (engine TS tham chiếu, **đóng băng** sau T-051/T-052), `golden/` | DEV |
| `backend/` (solution .NET: `MonNgon.Engine`, `MonNgon.Api`, test) | DEV |
| `mobile/` (Flutter app) | DEV |
| `web/` (ReactJS, P2) | DEV |
| `data/*.json` | RESEARCH (DEV chỉ đọc; schema theo hợp đồng dữ liệu trong backlog) |
| `content/` (chuỗi UI, thẻ vuốt, văn bản pháp lý); bản nháp hiện ở `docs/research/content-draft/` | RESEARCH |
| `docs/research/`, `docs/qa/` | RESEARCH |
| `docs/dev/` | DEV |
| `docs/pm/` | PM |

## 7. Yêu cầu phi chức năng (MVP)
- NFR-01 minh bạch số liệu; NFR-02 trung thực khi không đạt; NFR-06 giữ màn hình sáng; NFR-08 miễn trừ y tế; NFR-09 không bắt ghi nhật ký — **giữ nguyên**.
- NFR-03 rút gọn: chỉ tiếng Việt, nhưng **không hard-code chuỗi** trong component (Flutter: ARB `vi` sinh từ `content/i18n/vi.json`).
- Hiệu năng: tạo tuần ≤ 5 s trên máy tầm trung; mở tab ≤ 300 ms.
- Trợ năng: vùng chạm ≥ 44 pt, tương phản WCAG AA, mọi thao tác vuốt có nút thay thế.
- Riêng tư: MVP chỉ gửi lên API những lựa chọn cần để tính tuần (không tên, không email); API không lưu trữ; không analytics.
- Offline: xem tuần, công thức, đi chợ từ cache khi mất mạng; tạo/đổi tuần cần mạng và báo lỗi thân thiện khi mất mạng.
- API: tạo tuần ≤ 1 s phía server (p95); app hiển thị tổng ≤ 5 s.

## 8. Rủi ro
| Rủi ro | Giảm thiểu |
|---|---|
| Không đủ món hợp lệ khi người dùng loại nhiều → tuần lặp nhàm hoặc không đạt | Kho ≥ 60 món, test với hồ sơ khắt khe; báo trung thực; gợi ý nới lựa chọn |
| Món Việt nhiều cơm → khó đạt sàn protein trong dải calo thấp (vd 1.350 kcal) | Cho engine scale cơm xuống tới biên min; món giàu đạm (ức gà, cá, đậu phụ, trứng); thêm bữa phụ giàu đạm (sữa chua Hy Lạp, trứng luộc) |
| Giá khảo sát tay lỗi thời | Ghi ngày khảo sát, nhãn ước tính; cấu trúc dữ liệu sẵn cho cập nhật |
| Bảng TPDD VN 2007 thiếu/khác USDA | Ghi nguồn từng dòng; RESEARCH đối chiếu và ghi chú chênh lệch lớn |
| Nhầm sản phẩm là bản sao Mealbird | Tên, nhận diện, chuỗi UI, món ăn tự làm; review trước khi demo |

## 9. Câu hỏi còn mở
1. ~~Chọn tên app~~: **ĐÃ ĐÓNG** (2026-11-06), chốt "FitPro - Mâm đủ" (§11).
2. ~~Xác nhận ADR-001~~: **ĐÃ ĐÓNG** (2026-11-06), người dùng duyệt: engine chạy trên backend .NET; app cần mạng khi tạo/đổi tuần.
3. **Mức giá premium** (đề xuất ở §12, cần khảo sát T-056) và kênh thanh toán.
4. **Hosting backend** khi ra mắt (VPS/Azure/khác). Không chặn MVP vì chạy local được.
5. **Cài Flutter SDK** trên máy dev: **đang được session chính cài** (2026-11-06). Máy đã có .NET SDK 9 và 10, Android SDK. T-080 chờ việc cài xong.

## 10. Quyết định (2026-11-06)

| # | Câu hỏi | Quyết định của người dùng | Hệ quả |
|---|---|---|---|
| Q1 | Tên app | "Món Ngon" chỉ là tên tạm; sau khi xem đề xuất, chốt **"FitPro - Mâm đủ"** | Đổi tên mọi tài liệu; kiểm tra trùng tên/nhãn hiệu sớm (T-056) |
| ADR-001 | Engine chạy ở đâu | **Duyệt** phương án (a): port sang C#/.NET API | Dev bắt đầu T-060 |
| Q2 | Tech stack | **Flutter cho mobile**; xong mobile thì **web ReactJS** | Bỏ Expo. Engine port sang **.NET API** (ADR-001). Task UI Expo bị hủy, thay bằng task Flutter |
| Q3 | Dải calo | **±5%** quanh mục tiêu | Validator: kcal ∈ [mục tiêu −5%, +5%]; protein vẫn là sàn. Sửa engine TS trước khi xuất golden (T-051) |
| Q4 | Cấu trúc bữa | **Ghép mâm**, miễn đủ chất | Trưa/tối = mâm (món chính + canh/rau + cơm) hoặc món trọn suất; hợp đồng dữ liệu v0.2 thêm `dish_role` |
| Q5 | Ảnh món | **Placeholder trước**; người dùng cung cấp ảnh sau | `image: null`; placeholder theo nhóm món |
| Q6 | Khẩu phần người khác | Người lớn khác = 1 khẩu phần chuẩn, trẻ em = 0,6 | Giữ nguyên |
| Q7 | Thu phí | **Freemium** | Ranh giới free/premium ở §12; T-029 viết lại |
| Q8 | Chọn món bằng gì | Người dùng là dev .NET, hỏi tự xử lý được không hay cần LLM; nếu LLM thì v2/v3 | **Chọn món bằng thuật toán, không cần LLM** (engine hiện có đã làm được). LLM để v2/v3 cho gợi ý/soạn công thức mới và phân tích khẩu vị (ADR-001) |

### Quyết định sau T-065 (PM, 2026-11-06)

**D-BUD-01 — Công thức khoảng ngân sách (`POST /v1/budget-range`).**

Công thức tạm của Dev: ước tính = trung vị chi phí khẩu phần chuẩn × người × bữa × 7; min = 60%, max = 200%, bước 50.000 ₫. Đo thử trên dữ liệu hiện tại (giá `cho_khac`):
- 1 người, trưa + tối + phụ chiều: ước tính 350.000 ₫, min 200.000 ₫, max 700.000 ₫.
- Engine-report baseline cho cấu hình tương tự: chi phí món ăn thật **395.000–600.000 ₫/tuần** (p01 600.000 ₫, p10 540.000 ₫).

**Không đạt.** Có ba vấn đề:
1. Ước tính thấp hơn thực tế 15–40%, vì dùng khẩu phần chuẩn chứ không phải khẩu phần đã scale theo chỉ tiêu (người tăng cơ ăn nhiều hơn), và bỏ qua món phụ/extras.
2. Min 60% (200.000 ₫) không thể đạt được. Người chọn bậc "Tiết kiệm" sẽ gần như luôn nhận tuần vượt ngân sách.
3. Max 200% quá hẹp cho người muốn ăn thoải mái (bò, tôm, cá hồi). Spec gốc cho trần khoảng 5 lần mức sàn.

Quyết định:
- **Đầu vào thêm `targets`** (kcal + protein, đã có từ bước chỉ tiêu). Chi phí mỗi slot = chi phí món sau khi **scale theo chỉ tiêu slot** (dùng `Scale`). Phần người khác trong nhà vẫn dùng khẩu phần chuẩn × hệ số (Q6).
- **Ước tính** = trung vị chi phí đã scale của các món hợp lệ theo từng slot, cộng lại cho cả tuần.
- **Min khả thi** = phân vị 20% chi phí đã scale theo từng slot × 7 × 1,10 (biên an toàn), **làm tròn lên** 50.000 ₫.
- **Max** = max(ước tính × 2,5; min + 500.000 ₫), làm tròn lên 50.000 ₫.
- **Bậc:** "Tiết kiệm" [min, ước tính × 0,9) · "Vừa phải" [ước tính × 0,9, ước tính × 1,4) · "Thoải mái" [ước tính × 1,4, max]. API trả **key** bậc (`economy | moderate | comfortable`). Nhãn và mô tả lấy từ `content/i18n` (không hard-code trong API).
- **Màn tổng kết:** gọi lại `budget-range` kèm `preferences` đầy đủ (kiêng, ghét, dụng cụ) để lọc món trước khi tính min. Nếu ngân sách đã chọn < min thì cảnh báo (AC2c).
- **Tiêu chí kiểm:**
  - Với mọi hồ sơ test, tạo tuần với ngân sách = min trả về thì ≥ 90% hồ sơ không vượt ngân sách.
  - Ước tính nằm trong ±15% so với chi phí món ăn thật (engine-report) ở ≥ 80% hồ sơ.
- Task: **T-069**.

**D-BUD-02 — Sửa D-BUD-01 sau T-069 (PM chấp nhận có điều kiện, 2026-11-06).**

Dev đổi cách tính ước tính: ước tính = **chi phí món ăn của tuần engine lập thật** với ngân sách 10.000.000 ₫ (seed 1). Trung vị chỉ còn là phương án dự phòng khi engine không lập được tuần. Lý do: trung vị chỉ đạt ±15% ở 3/14 hồ sơ, vì engine không chọn món ở mức trung vị (`docs/dev/api-notes.md`).

**Chấp nhận**: ước tính bám đúng thứ app sẽ thực sự lập, và chi phí 30–150 ms mỗi lần gọi là chấp nhận được. Min, max và các bậc giữ nguyên D-BUD-01. Điều kiện kèm theo (T-072):
1. **Kẹp ước tính** vào [min, max]. Ước tính là vị trí mặc định của thanh trượt nên không được nằm dưới min. Hiện code chỉ kẹp ranh giới các bậc, chưa kẹp ước tính.
2. **Sửa tiêu chí kiểm.** Theo cách mới, so ước tính với chính tuần mô phỏng là tự đúng. Thay bằng: tạo tuần với **ngân sách = ước tính** thì ≥ 90% hồ sơ không vượt ngân sách và chi phí thật ≥ 70% ước tính (ước tính không bị thổi phồng).
3. **Hiệu năng:** cache kết quả trong bộ nhớ theo hash đầu vào + `data_version`; p95 ≤ 300 ms khi chưa có cache.
4. **Tráng miệng:** ước tính phải gồm chi phí tráng miệng (D-DES-01). Kiểm lại khi có dữ liệu T-058.
5. Ghi bảng kiểm từng hồ sơ vào `docs/dev/budget-range-check.md`, như AC T-069 yêu cầu; file này hiện chưa có.

**D-HLT-01 — Xu hướng sức khỏe trong MVP (PM, 2026-11-06).** Dữ liệu hiện có thẻ `giau_dam`, `nhieu_xo`, `it_beo`, `chay`, `omega3`, `low_carb`; chưa có món nào gắn thẻ liên quan tiểu đường. Gắn nhãn bệnh lý cho món ăn là rủi ro (NFR-08), nên MVP chỉ dùng **thẻ mô tả tính chất món** có tiêu chí khách quan, không dùng tên bệnh làm thẻ:

| Lựa chọn trên UI | Thẻ dữ liệu | Ghi chú |
|---|---|---|
| Nhiều chất xơ | `nhieu_xo` | đã có |
| Ít đường (cho người cần kiểm soát đường huyết) | `it_duong` (mới) | tiêu chí do Research định nghĩa ở T-059 |
| Tốt cho tim mạch | `tot_cho_tim` (mới) | ít béo bão hòa, có cá béo/omega-3 hoặc nhiều xơ; tiêu chí ở T-059 |
| Ít béo | `it_beo` | đã có |

- "Phù hợp PCOS" và "Chống viêm" **ra khỏi MVP**: bằng chứng gắn với món ăn cụ thể yếu, dễ thành tuyên bố y tế.
- Mọi lựa chọn sức khỏe vẫn chỉ là **ưu tiên mềm** và luôn kèm miễn trừ y tế.
- `GET /v1/reference` liệt kê một xu hướng khi có ≥ 10 món mang thẻ đó; hiện API đang đúng như vậy.

**Duyệt các chỗ lệch ở onboarding T-083…T-086 (PM, 2026-11-07).**

**D-ONB-01 — Thứ tự bước (chấp nhận).** Thứ tự chính thức: Mục tiêu & cơ thể → Chỉ tiêu → Cửa hàng → **Hộ gia đình → Ngân sách** → Bữa ăn → Kiêng/dị ứng → Không muốn thấy → Khẩu vị → Dụng cụ → Tổng kết. Lý do: min/max ngân sách phụ thuộc số người (và chỉ tiêu, D-BUD-01). Vì bước Bữa ăn nằm sau Ngân sách, API ước tính ngân sách theo cấu hình bữa mặc định (trưa + tối + phụ chiều); màn Tổng kết gọi lại `budget-range` với cấu hình thật (US-1.2 AC2c). Không cần sửa code.

**D-ONB-02 — "Ít tinh bột" là cờ riêng (chấp nhận).** Đúng spec: "Ít tinh bột" là ràng buộc cứng trong nhóm "Chế độ ăn" (`preferences.low_carb`), không phải ưu tiên mềm. Không cần sửa code.

**D-ONB-03 — Danh sách xu hướng sức khỏe chính thức (chốt).** Giữ đúng D-HLT-01. Danh sách lựa chọn người dùng thấy (`health_leanings`) **chỉ gồm 4 id**: `nhieu_xo` (Nhiều chất xơ), `it_duong` (Ít đường), `tot_cho_tim` (Tốt cho tim mạch), `it_beo` (Ít béo).
- Các thẻ `giau_dam`, `omega3`, `chay`, `low_carb` trong `data/` là **thẻ nội bộ**, không hiện trên UI:
  - `omega3` là một tiêu chí cấu thành `tot_cho_tim`;
  - `chay` trùng với chế độ ăn (lọc bằng `diet_tags`);
  - `low_carb` trùng `is_low_carb`;
  - `giau_dam` thì gần như mọi món đều có (208/286), nên không phân biệt được món nào.
- **Không** có thẻ "tiểu đường": `it_duong` thay thế, kèm miễn trừ y tế.
- API: `reference.health_leanings` lọc theo danh sách trắng 4 id này; một id chỉ hiện khi có ≥ 10 món mang thẻ. Nhãn lấy từ i18n.
- Task: Dev T-073 (danh sách trắng); Research T-059 (gắn thẻ `it_duong`, `tot_cho_tim`, rà `nhieu_xo`, `it_beo`), nâng lên P0 vì màn onboarding đã có.

**D-ONB-04 — Chuỗi UI và thời gian chờ (sửa).**
- `content/i18n/vi.json` chưa có, nên Dev phải để chuỗi tạm ở `mobile/tool/arb_extra.json`. Research làm T-055 (đã có, P0): đưa bản nháp cùng toàn bộ key trong `arb_extra.json` vào `content/i18n/vi.json`. Sau đó Dev chuyển `gen_arb.py` sang đọc nguồn chính thức và xóa `arb_extra.json` (T-074).
- Câu chờ ở màn Tổng kết phải nhất quán với AC tạo tuần ≤ 5 giây: dùng "chỉ vài giây", **không** dùng "mất một phút".

**D-ONB-05 — Request `budget-range` có `store_id`/`adults` thừa ở cấp ngoài (P2).** Khi có `preferences`, server lấy các trường này từ `preferences` và bỏ qua cấp ngoài. Làm sạch schema sau: các trường cấp ngoài thành tùy chọn và chỉ dùng khi không có `preferences`, kèm mô tả trong OpenAPI (T-075, P2).

**D-HLT-02 — Ngưỡng `nhieu_xo` và nguyên tắc ưu tiên mềm (PM, 2026-11-07).**
- **Ngưỡng:** `nhieu_xo` khi **xơ ≥ 4 g/khẩu phần chuẩn** (97 món). Không dùng ≥ 5 g (67 món) như bản nháp `docs/research/health-tags.md`. Lý do:
  - Khuyến nghị khoảng 25–30 g xơ/ngày; 4 g/món là khoảng 15% nhu cầu ngày trong một món. Hai bữa chính cộng rau/trái cây vẫn đủ xơ, nên nhãn vẫn trung thực.
  - Số món đủ nhiều để không thu hẹp lựa chọn của engine.
  - ≥ 3 g (136 món) thì gần như món nào cũng có rau, nên nhãn mất ý nghĩa.

  Research cập nhật `health-tags.md` và thẻ trong `data/`.
- **Nguyên tắc (áp cho mọi xu hướng sức khỏe và khẩu vị):** xu hướng chỉ là **ưu tiên mềm**. **Không bao giờ** được làm một ngày rớt chỉ tiêu cứng (sàn protein, dải kcal ±5%), ngân sách hay ràng buộc cứng.
  - Engine chỉ dùng xu hướng để xếp hạng **giữa các phương án cùng đạt**.
  - Khi không còn phương án đạt, engine bỏ qua xu hướng cho slot/ngày đó.
- **Tiêu chí kiểm:** với mọi hồ sơ test, tỉ lệ ngày đạt khi bật xu hướng **≥** tỉ lệ khi tắt hết xu hướng (cùng seed). Có test hồi quy riêng cho p01 + `nhieu_xo` (phải về lại 7/7). Task: Dev T-076.

**D-MAM-01 — Tỉ lệ ghép mâm khi ngân sách eo hẹp (PM, 2026-11-07).**

Bối cảnh: p14 (hộ 3 người lớn, ngân sách 1,2 triệu, ít dụng cụ) tụt từ 57% xuống 21% bữa ghép mâm (3/14) sau khi thêm tráng miệng bắt buộc; tuần vẫn đạt 7/7 ngày.

Chọn **(c)**: chấp nhận tạm, cải thiện ở P1.
- **Thứ tự ưu tiên chính thức** (đã cập nhật ở D-COM-01: chèn "lượng cơm theo lựa chọn" ngay sau mục 2):
  1. ràng buộc cứng;
  2. sàn protein + dải kcal;
  3. ngân sách;
  4. tráng miệng (yêu cầu của người dùng, D-DES-01);
  5. ghép mâm;
  6. xu hướng/khẩu vị.

  Ghép mâm là cách trình bày ưu tiên, không phải chỉ tiêu cứng. Người dùng đã nói "ghép mâm, miễn sao đủ chất".
- **Ngưỡng kiểm:**
  - Toàn bộ hồ sơ test: ≥ 60% bữa trưa/tối ghép mâm (giữ AC T-066; hiện đạt 81%).
  - Từng hồ sơ: ≥ 40%, **trừ** hồ sơ có ngân sách nằm ở bậc "Tiết kiệm" hoặc ít dụng cụ: các hồ sơ này cho phép ≥ 20%. p14 thuộc nhóm này, nên chấp nhận ngưỡng 20% Dev đã đặt cho p14.
  - Engine-report ghi lý do mỗi khi một bữa không ghép mâm (`budget` / `no_side_candidate` / `equipment`) để đo.
- **Không** bỏ hay giảm tráng miệng để lấy chỗ cho mâm: tráng miệng đứng trên mâm trong thứ tự ưu tiên. Khi ngân sách eo hẹp, engine chọn tráng miệng rẻ nhất hợp lệ (đã làm).
- **Cải thiện (P1):**
  - Dev T-077: khi chi phí tương đương, engine ưu tiên mâm với món phụ rẻ hơn món `full_meal`.
  - Research bổ sung canh/rau giá rẻ (≤ 8.000 ₫/khẩu phần) trong T-053.
  - Mục tiêu đưa p14 lên ≥ 40%.

**D-MAM-02 — Phần cơm trong bữa mâm (PM, 2026-11-07). ĐÃ THAY BẰNG D-COM-01 (cùng ngày)**: sàn 60% khẩu phần chuẩn bị bỏ, lượng cơm theo câu trả lời của người dùng. Giữ đoạn dưới làm bối cảnh.

Bối cảnh: integration test it-05 (p01): mâm 496 kcal gồm đậu phụ xào 268, canh 64, rau 74, **cơm gạo lứt 37 kcal (~33 g, ~1 g protein)**, tráng miệng 53. Cả tuần chỉ cần 47 g gạo. Nguyên nhân: sàn cơm hiện là 20% khẩu phần chuẩn (`CarbBaseFloorRatio = 0.2`, 150 g → 30 g), canh và rau bị ghim gram, nên khi thừa kcal engine cắt cơm trước món chính. Không ai ăn mâm như vậy.

Quyết định:
- **Sàn cứng phần tinh bột (`carb_base`) = 60% khẩu phần chuẩn của công thức**, làm tròn bước 5 g, tính cho một suất chuẩn: cơm trắng/gạo lứt 150 g → **≥ 90 g chín** (~105–115 kcal), bún 200 g → ≥ 120 g, khoai lang 150 g → ≥ 90 g. Trần giữ `max_g` của công thức.
- **Mục tiêu mềm:** phần tinh bột chiếm **20–40% kcal của mâm** (không tính tráng miệng).
- **Khi mâm thừa kcal, thứ tự giảm:** (1) dòng scalable của món chính (dầu/béo trước, rồi phần đạm, nhưng không xuống dưới sàn protein bữa); (2) cơm, chỉ đến sàn 60%; (3) nếu vẫn không vào ±5% thì **chọn tổ hợp mâm khác** (món chính nhẹ hơn, canh/rau khác hoặc bỏ canh/rau theo AC5 "tối đa 1"); (4) cuối cùng mới dùng món `full_meal`. Không bao giờ cắt cơm dưới sàn để vừa kcal.
- Hồ sơ Ít tinh bột (low_carb) không có cơm: không đổi.
- Thứ tự ưu tiên D-MAM-01 giữ nguyên: ràng buộc cứng > protein/kcal > ngân sách > tráng miệng > mâm. Nếu sàn mới làm một hồ sơ trượt 7/7, Dev **không tự hạ sàn**, báo session chính kèm hồ sơ và số liệu; PM quyết (phương án dự phòng: sàn 40% cho riêng hồ sơ kcal thấp).
- Task: T-094.

**D-COM-01 — Hỏi thói quen ăn cơm, lượng cơm của mâm theo câu trả lời (PM, 2026-11-07).**

Bối cảnh: it-05 (p01) cho mâm chỉ có 37 kcal cơm (xem D-MAM-02). Yêu cầu của người dùng: "Lúc mở app sẽ phải có bước hỏi người dùng có thường ăn cơm nhiều không? Sau đó sẽ điều chỉnh vào bữa ăn. Chứ không biết lượng cơm người dùng ăn mà tự động gán ăn ít cơm thì sẽ ko ai dùng app đâu."

- **Bước onboarding mới (US-1.4b)**, hỏi "Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?". 4 mức, tính cho **người dùng chính**, cơm chín (1 chén ≈ 150 g ≈ 195 kcal với cơm trắng; Research kiểm lại ở T-059c, số chốt có thể đổi theo kết quả):

| Mã (`rice_habit`) | Nhãn hiển thị | Cơm chín mỗi bữa mâm | ≈ kcal (cơm trắng) |
|---|---|---|---|
| `it` | ½ chén (~75 g) · dòng phụ "Ít cơm, ăn nhiều thức ăn" | 75 g | ~100 |
| `vua` (mặc định) | 1 chén (~150 g) | 150 g | ~195 |
| `nhieu` | 2 chén (~300 g) | 300 g | ~390 |
| `rat_nhieu` | 3 chén trở lên (~450 g) | 450 g | ~585 |

- **Cách hiển thị (người dùng chỉnh, 2026-11-07):** người dùng đọc theo **chén**, gram chỉ là gợi ý trong ngoặc. Áp dụng ở onboarding, màn mâm ("Cơm gạo lứt · 1 chén (150 g)") và ghi chú giảm cơm. Gram thực tế quy ra chén bằng cách làm tròn đến ½ chén gần nhất, nhỏ nhất là ½ chén (vd 90 g → "khoảng ½ chén (90 g)", 225 g → "1½ chén (225 g)"). Số gram mỗi chén là một hằng số, lấy theo T-059c.

- Cơm trắng và gạo lứt dùng **cùng số gram** (người dùng nghĩ theo chén). Bún, khoai lang và tinh bột khác quy theo **kcal tương đương** của mức (làm tròn 5 g). `max_g` của các công thức `carb_base` phải đủ chứa mức `rat_nhieu` (dữ liệu, T-059c).
- Đã chọn "Ít tinh bột" (`low_carb`, ràng buộc cứng) thì bỏ qua bước này và mâm không có cơm, như cũ.
- **Engine:** cơm của bữa mâm **được ghim theo mức đã chọn** (sai số ±10 g do làm tròn). Món chính, canh, rau và tráng miệng co giãn trong [min_g, max_g] của dòng scalable (dòng cố định không đổi, D-QA-04) để giữ kcal ±5% và sàn protein.
- **Khi không vừa:** (1) thử tổ hợp mâm khác với cơm vẫn đúng mức (món chính nhẹ/đạm đậm đặc hơn, bỏ canh hoặc rau theo AC5 "tối đa 1"); (2) nếu vẫn không được thì **giảm cơm từng bước 25 g**, không xuống dưới **sàn = max(50% mức đã chọn, 60 g)**; (3) vẫn không được thì dùng món `full_meal`; (4) cuối cùng là "không đạt" trung thực theo US-2.2. **Mọi bữa bị giảm cơm phải có ghi chú hiển thị cho người dùng**; không bao giờ giảm cơm mà không báo.
- **Ghi chú trong API:** mỗi bữa mâm trả `rice: { habit, target_g, actual_g }`; khi `actual_g < target_g − 10` thì thêm `notes: [{ code: "rice_reduced", target_g, actual_g, reason: "kcal" | "protein" }]`. App hiện (chuỗi i18n, Research soạn), ghi theo chén: "Bữa này cơm còn khoảng {actual_chen} chén ({actual} g), bạn chọn {target_chen} chén, để vẫn đủ đạm trong mức {kcal} kcal của bạn."
- **Cảnh báo sớm ở onboarding:** nếu kcal cơm của mức đã chọn > 45% kcal trung bình một bữa chính (tính từ chỉ tiêu US-1.1 và phân bổ US-1.3), bước này hiện dòng "Với mức calo hiện tại, một số bữa sẽ phải bớt cơm. Bạn vẫn có thể giữ lựa chọn này." Không chặn.
- **Hộ gia đình:** mức cơm chỉ áp cho người dùng chính. Người lớn khác ăn mức `vua`, trẻ em 0,6 × `vua` (như quy ước khẩu phần). Danh sách đi chợ cộng gạo theo cơm thực tế của cả nhà (hệ số 0,36 gạo trắng / 0,34 gạo lứt).
- **Phạm vi:** chỉ bữa mâm trưa/tối. Bữa sáng, bữa phụ và phần cơm bên trong món `full_meal` (cơm tấm, cơm rang…) chưa theo mức ở MVP; áp cho `full_meal` là P1. **(Cập nhật D-COM-04: `full_meal` có cơm đưa vào MVP.)**
- **Thứ tự ưu tiên (thay D-MAM-01):** ràng buộc cứng > sàn protein + dải kcal > **lượng cơm theo lựa chọn (có sàn, có ghi chú)** > ngân sách > tráng miệng > ghép mâm > xu hướng/khẩu vị.
- **Đổi câu trả lời ở tab Bạn:** đổi xong hỏi xác nhận rồi lên lại các ngày còn lại của tuần (theo US-5.5: giữ ngày đã qua và hôm nay), danh sách đi chợ cập nhật.
- API: thêm `preferences.rice_habit` (enum trên). Thiếu trường thì coi là `vua` để không vỡ máy khách cũ và golden.
- Task: T-094 (engine + API), T-095 (Flutter), T-059c (Research: số liệu chén cơm, dữ liệu, chuỗi), T-050c (Research: kiểm thử lại).

**D-COM-02 — p01 bị giảm cơm 92% bữa: nguyên nhân và hướng sửa (PM, 2026-11-07).**

Bối cảnh: sau T-094 (`docs/dev/engine-report-rice.md`), ở mức "1 chén" p01 có 92% bữa mâm bị giảm cơm (trung vị 88 g), p02 23%; 14 hồ sơ còn lại ≤ 8%.

**Phân tích (PM chạy engine-report với biến thể p01, seed 1, mức `vua`):**

| Biến thể p01 | % bữa mâm có ghi chú | Cơm trung vị |
|---|---|---|
| Gốc (thích xào + canh, xu hướng nhiều chất xơ, ngân sách 650k) | 92% | 88 g |
| Ngân sách 800k | 92% | 75 g |
| Bỏ xu hướng nhiều chất xơ | 75% | 120 g |
| Bỏ khẩu vị thích (xào, canh) | 27% (min 150 g; ghi chú chủ yếu ở bữa khoai lang) | 175 g |
| Bỏ chất xơ + ngân sách 800k | 14% | 150 g |

- **Không phải do chỉ tiêu:** p09 có cùng chỉ tiêu (1.330–1.470 kcal, ≥ 120 g đạm) và ngân sách thấp hơn (600k) nhưng chỉ 8% bữa có ghi chú, vì chọn món đạm nạc (ức gà, thịt nạc hấp, đậu hũ hấp).
- **Ngân sách một mình không phải nguyên nhân** (800k vẫn 92%).
- **Nguyên nhân chính: ưu tiên mềm đang thắng lượng cơm khi chọn mâm.** Khẩu vị "thích xào, canh" và xu hướng "nhiều chất xơ" kéo engine chọn món chính nhiều kcal mà ít đạm: đậu xanh, đậu lăng hầm (nhiều tinh bột), lạc rang + đậu phụ chiên, món xào nhiều dầu; mâm có tới 2 canh. Engine chọn mâm trước, sau đó mới giảm cơm cho vừa kcal, nên trái thứ tự D-COM-01 (lượng cơm > ngân sách > tráng miệng > mâm > khẩu vị/xu hướng).

**Quyết định:**
- **Engine phải đánh giá "cơm có giữ được không" ngay khi chọn mâm**, không để đến bước scale. Với mỗi ứng viên mâm, tính chỗ trống kcal = kcal bữa − kcal cơm theo mức − tráng miệng, và kiểm phần còn lại (món chính + canh + rau) đạt được đạm bữa trong chỗ trống đó. Ứng viên phải giảm cơm bị phạt **lớn hơn mọi điểm cộng mềm** (khẩu vị, xu hướng, chống lặp), theo thứ tự từ điển, không cộng dồn.
- Khẩu vị và xu hướng chỉ dùng để xếp hạng **trong nhóm ứng viên giữ được cơm**. Nếu nhóm này rỗng thì mới xét ứng viên giảm cơm (có ghi chú như D-COM-01).
- Mâm không có 2 món cùng vai trò canh. Món chính dạng canh (`*_mam` từ canh) tính là món chính; khi đó không thêm canh thứ hai.
- **Không chấp nhận "để nguyên và giải thích"** cho mức mặc định: người chọn 1 chén mà gần như bữa nào cũng bị bớt sẽ bỏ app (lời người dùng ở D-COM-01). Không đổi phân bổ kcal sáng/trưa/tối (p09 cho thấy không cần).
- Task: T-096.

**Nới test của Dev trong T-094:**
- Sai số ước tính ngân sách 2% → 3%: **chấp nhận**. Đây là sai số ước tính, ngưỡng sản phẩm D-BUD-02 không đổi.
- `Tuan_14` số bữa mâm p04 ≥ 9 (trước 10), p10 ≥ 8 (trước 9): **chấp nhận tạm**. Ngưỡng sản phẩm là ≥ 60% bữa trưa/tối ghép mâm trên toàn bộ hồ sơ (D-MAM-01) vẫn giữ. Khôi phục ≥ 10 / ≥ 9 trong T-096 nếu đạt; không đạt thì Dev ghi số đo.
- p01 tráng miệng ≥ 2 loại (trước ≥ 3): **không chấp nhận lâu dài**. 2 loại tráng miệng cho cả tuần là quá lặp với yêu cầu tráng miệng mọi bữa (D-DES-01). Tạm để 2 cho T-094 qua; T-096 phải **khôi phục ≥ 3**.

**D-COM-03 — Thẻ tinh bột khi mâm không dùng cơm (PM, 2026-11-07).** Không ẩn thẻ (người dùng cần thấy mức của mình được thay bằng gì). Nhãn theo **tên món**, quy đổi chén cơm đặt sau: "Khoai lang hấp · ~115 g (thay ½ chén cơm)", "Bún tươi · ~200 g (thay 1 chén cơm)". Chữ "chén cơm" chỉ dùng khi món là cơm trắng/gạo lứt. Ghi chú giảm cơm cũng theo dạng này ("Bữa này khoai lang còn ~90 g, thay khoảng ½ chén cơm…"). API trả thêm `rice.kind` (`com` | `other`) và `rice.rice_equiv_g` (gram cơm trắng tương đương) để app quy ra chén; app không tự đoán. Task: T-098 (API), T-099 (Flutter).

**D-COM-04 — Mức 2 chén / 3+ chén lại ít bữa có cơm (PM, 2026-11-07).**

Số đo (p01, 1.400 kcal / 120 g đạm, sau T-096): bữa mâm có cơm mỗi tuần: ½ chén 14, 1 chén 13, 2 chén 5, 3+ chén 2. **Gạo sống cần mua: 1 chén 575 g/tuần, 2 chén 678 g, 3+ chén 429 g**, tức người chọn ăn nhiều cơm nhất lại được mua ít gạo nhất. Ngược ý người dùng, không chấp nhận.

Nguyên nhân:
- Với 1.400 kcal, 2 chén (~390 kcal) mỗi bữa trưa/tối là ~56% kcal cả ngày. Phần còn lại không đủ chỗ cho 120 g đạm, nên đa số bữa thật sự không giữ được đủ mức. Việc này dự kiến được; cảnh báo onboarding (US-1.4b AC3) có để báo trước.
- **Lỗi thứ tự:** sau T-096, bữa đủ món không có cơm (`full_meal`) được coi là "không phải giảm cơm" nên xếp trên mâm phải bớt cơm. D-COM-01 quy định ngược lại: mâm bớt cơm đến sàn (có ghi chú) đứng **trước** `full_meal`.

Quyết định:
- **Thứ tự xếp hạng bữa trưa/tối** khi người dùng không chọn Ít tinh bột:
  1. Mâm giữ đủ mức cơm.
  2. Mâm bớt cơm, không dưới sàn max(50% mức, 60 g), có ghi chú.
  3. Món `full_meal` có cơm (cơm tấm, cơm gà…), dòng cơm theo mức trong [min_g, max_g] (đưa phần P1 của D-COM-01 vào MVP).
  4. `full_meal` không cơm.

  Bữa đủ món không cơm tính như **cơm thực tế 0 g**, không được coi là "giữ cơm".
- **Được dồn kcal trong ngày** cho mức 2 chén và 3+ chén: engine được chuyển tối đa **15% kcal của ngày** từ bữa sáng/bữa phụ sang trưa/tối. Kiểm đạt vẫn theo ngày (kcal ±5%, đạm ≥ sàn). Mức ½ và 1 chén giữ phân bổ cũ.
- **Onboarding nói trước bằng con số:** dòng cảnh báo US-1.4b AC3 kèm số chén khả thi: "Với 1.400 kcal và 120 g đạm, mỗi bữa bạn ăn được khoảng 1½ chén mà vẫn đủ đạm. Bạn vẫn có thể giữ 3 chén; app sẽ bớt cơm ở bữa cần bớt và ghi chú." Số chén khả thi do server tính (`budget-range` hoặc endpoint riêng, Dev chọn), app không tự tính.
- Task: T-098 (engine + API), T-099 (Flutter).

**D-DIV-02 — p01 chỉ 9 món trưa/tối khác nhau (PM, 2026-11-07).** PM đo: cùng p01, ngân sách 650k → 9 món; **800k → 11 món**. Nguyên nhân là ngân sách sát, không phải lỗi engine. Ngân sách xếp trên đa dạng món, nên **chấp nhận**. Sửa D-DIV-01: thêm ngoại lệ "ngân sách sát" (chi phí món ≥ 90% ngân sách và nới ngân sách 20% thì đạt ≥ 10 món) với ngưỡng **≥ 8**. Engine-report thêm dòng "món trưa/tối khác nhau khi nới ngân sách 20% → N" (như dòng lý do không ghép mâm) để phân biệt với lỗi engine. Không làm task dữ liệu riêng; T-053/T-054 (món rẻ) sẽ nâng số này. Ghi vào T-098.

**D-QA-10 — TC-E-04 tạo tuần khi mất mạng (PM, 2026-11-07).** Bảng TC sai, không phải app sai. Theo ADR-001, tạo/đổi tuần cần mạng; xem tuần, công thức, danh sách đi chợ đã tạo thì offline được. Kỳ vọng đúng: hiện "Chưa tạo được thực đơn" + thông báo mất mạng + nút Thử lại; dữ liệu trên máy giữ nguyên; có mạng lại thì Thử lại tạo được tuần. Research sửa bảng (T-057c).

**D-QA-11 — TC-E-09 riêng tư: câu chữ đúng (PM, 2026-11-07).** "Không gửi dữ liệu ra ngoài máy" sai với ADR-001: tạo/đổi tuần và `budget-range` gửi chỉ số cơ thể, mục tiêu và lựa chọn ăn uống lên API. Câu đúng, khớp NFR riêng tư (§7) và đoạn chính sách trong `docs/research/legal-notes.md`: **app chỉ gửi dữ liệu cần để lập thực đơn, chỉ tới máy chủ của app; không gửi bên thứ ba; không gửi tên, email hay mã định danh thiết bị; máy chủ không lưu nội dung yêu cầu sau khi trả kết quả.** Các điểm kiểm được: (1) mọi request chỉ tới host API đã cấu hình, không domain nào khác (không analytics, không SDK báo lỗi); (2) payload chỉ có trường trong OpenAPI, không có tên/email/ID thiết bị; (3) cấu hình log của API không ghi body request. Log truy cập của hosting/proxy (IP, thời gian, đường dẫn) là điểm mở trước phát hành theo legal-notes, không thuộc TC này.

**D-COM-05 — Kết quả T-098: duyệt ngoại lệ (PM, 2026-11-08).** Không nâng ngân sách hồ sơ test: hồ sơ test phản ánh người dùng thật.
- **AC2 (≥ 12/14 bữa có cơm ở 2 chén / 3+ chén):** chấp nhận ngoại lệ **"ngân sách sát"**: hồ sơ mà Dev đo được mọi phương án ≥ 12/14 bữa có cơm đều vượt ngân sách (hiện p02 3+ chén, p09 3+ chén, p14 2 chén và 3+ chén). Ngân sách là ràng buộc của người dùng nên thắng. Điều kiện: engine-report ghi cho từng ngoại lệ **ngân sách cần để đạt** (vd p02 ≥ 652k), và app phải cảnh báo (AC4).
- **AC4 (cảnh báo khi thiếu cơm): không có ngoại lệ, phải 64/64.** Ước lượng số chén khả thi phải tính cả **ngân sách**, không chỉ kcal/đạm. p14 ở mức 2 chén phải bật cảnh báo. Câu cảnh báo nêu đúng lý do: "Với ngân sách {X}, khoảng {n}/14 bữa có đủ {m} chén cơm; cần khoảng {Y} để bữa nào cũng đủ." (lý do kcal/đạm giữ câu D-COM-04).
- **AC1 (gạo tăng dần):** đo lại bằng **tổng tinh bột quy ra cơm** (`rice_equiv_g` cả tuần), không đo gạo sống, vì mâm khoai/bún thay cơm là hợp lệ. Yêu cầu tuyệt đối: không giảm khi tăng mức (cho phép sai số làm tròn ≤ 2%). Hồ sơ thuộc ngoại lệ ngân sách ở AC2 được miễn ở các mức thuộc ngoại lệ. Gạo sống chỉ ghi trong report. **Không nới luật 1 canh / 1 món chính.** Kho mâm cơm hẹp giao Research bổ sung trong T-053/T-054: ưu tiên món chính rẻ hợp mâm cơm.
- **AC7 (đa dạng) ở 2 chén / 3+ chén:** chấp nhận **≥ 6 món trưa/tối** cho MVP (ngưỡng ở ½ chén và 1 chén giữ theo D-DIV-01/02). Theo dõi trong report; T-053/T-054 nâng lên.
- Rice98Tests: các ngoại lệ phải đọc từ một danh sách có tên hồ sơ, mức và lý do (`budget`), không nới ngưỡng chung.

**D-SHP-01 — Đồ "nhà có sẵn" trong con số tại quầy (PM, 2026-11-07).** Câu (a) trong `docs/research/prices-small-packs-notes.md`. Chọn **có, loại khỏi mặc định**:
- Nguyên liệu `default_pantry` (dầu ăn, nước mắm, xì dầu, muối, đường, tiêu, gia vị khô…) được đánh dấu sẵn "Nhà có sẵn" ở tuần đầu. **Không** cộng vào "Ước tính trả tại quầy" mặc định.
- Tab Đi chợ có mục riêng "Có thể nhà đã có" liệt kê các dòng này, ghi "Nếu phải mua: +X ₫". Người dùng bỏ đánh dấu thì dòng đó quay lại danh sách và con số tại quầy.
- **Chi phí món ăn tuần (dùng để so ngân sách) vẫn tính phần gram đã dùng** của các nguyên liệu này. Vì vậy ngân sách trung thực và không đổi; chỉ con số tại quầy thay đổi.
- Lựa chọn của người dùng được nhớ cho các tuần sau.
- API: `pantry_ids` không gửi thì dùng danh sách `default_pantry`; gửi `[]` thì không coi gì là có sẵn. Golden parity chạy với `pantry_ids: []` để không lệch. Response thêm `pantry_cost_if_buy_vnd`.
- Task: Dev T-078.

**D-SHP-02 — Cơm/gạo: mua gạo sống, nấu ra cơm (PM, 2026-11-07).** Câu (b). Chọn **có**, nhưng chỉ đổi ở **danh sách đi chợ**, không đổi công thức và dinh dưỡng:
- Công thức và dinh dưỡng giữ nguyên `com_trang`, `gao_lut_nau_chin` (gram **cơm chín**). Người dùng cân/xới cơm chín, và Bảng TPDD có số liệu cơm chín.
- Hợp đồng dữ liệu thêm trường tùy chọn cho nguyên liệu: `purchase_as: { "ingredient_id": "gao_te", "factor": 0.36 }`, nghĩa là 1 g cơm chín cần 0,36 g gạo sống (1 g gạo → khoảng 2,8 g cơm). Gạo lứt dùng 0,34. Hai hệ số đã sửa theo D-SHP-03.
- Danh sách đi chợ quy cơm ra gạo sống, theo quy cách bao gạo (1 kg, 2 kg, 5 kg). Giá và chi phí tính theo gạo sống. Phần dư gạo để lâu (`shelf_life_days` lớn), nên tính như đồ khô.
- Gạo tẻ cũng là `default_pantry` (đa số nhà có sẵn gạo), nên mặc định không cộng vào con số tại quầy (D-SHP-01).
- Trang công thức ghi "Cơm 200 g (≈ 72 g gạo)" để người tự nấu biết đong.
- Bún/phở tươi giữ nguyên, vì vẫn mua dạng tươi.
- Task: Research T-042c (gạo sống + hệ số + giá); Dev T-078.

**Quyết định sau kiểm thử chấp nhận T-050 (PM, 2026-11-07).** Nguồn: `docs/research/acceptance-T050.md` (API: 33 đạt, 6 không đạt, 2 chưa xác nhận; app chưa kiểm được phần lớn UI).

**D-QA-01 — "Không hạt giống" và vừng (L-03).** Theo đúng `docs/research/allergen-rules.md` (đã thống nhất từ T-041): lựa chọn trên UI là **"Không hạt giống & vừng"**, id `no_seed`, cấm cả tag `seed` **và** `sesame`. Giữ thêm `no_sesame` (chỉ cấm vừng) cho người chỉ dị ứng vừng.
- TC-1-23 đúng, **code sai** → Dev sửa bảng ánh xạ trong `Filter.cs` (và mô tả `description`).
- Đây là lỗi an toàn dị ứng, nên ưu tiên cao nhất. Sửa ở code, không đụng dữ liệu đang đóng băng.

**D-QA-02 — Ngân sách so theo số nào (L-08).** Cách báo hiện tại **đúng ý**: ngân sách là chi phí món ăn trong tuần (D-BUD-01 AC2b, D-SHP-01). Cần sửa hai chỗ:
- Câu chữ ghi rõ đối tượng so: "Chi phí món ăn tuần này nằm trong ngân sách (dư X ₫)", không viết chung chung "Còn trong ngân sách".
- Khi tiền tại quầy > ngân sách: thêm dòng thông tin màu trung tính, ví dụ "Lần đi chợ này ước tính Y ₫, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau."

Sau D-SHP-01 (đồ nhà có sẵn không tính vào tiền tại quầy), khoảng chênh sẽ giảm nhiều. Không cần cảnh báo đỏ cho tiền tại quầy.

**D-QA-03 — Dải calo trong tài liệu test (L-07).** Theo PRD: [mục tiêu −5%, mục tiêu +5%]. Research sửa TC-1-07 và rà mọi TC còn ghi dải cũ.

**D-QA-04 — Làm tròn gram (L-06, L-01).**
- Chỉ dòng scale được mới làm tròn 5 g. Dòng cố định giữ nguyên gram công thức (vd dầu 3 g là hợp lệ). Research sửa TC-2-04b theo US-2.1 AC3 mới.
- L-01 (đường trong chè ra 5 g trong khi công thức cố định 8 g) là **lỗi engine**: scale tráng miệng không được chạm dòng cố định, và mọi gram phải nằm trong [min, max].

**D-QA-05 — Chặn đầu vào (L-02).** Cả app **và** API phải chặn:
- tắt hết bữa chính (phải còn ≥ 1 bữa trưa/tối hoặc sáng ở chế độ "Lên thực đơn");
- `equipment` không có thiết bị nấu nào.

API trả 400 kèm trường lỗi. App khóa nút Tiếp tục kèm lời nhắc.

**D-QA-06 — Lạc không bao giờ được chọn (L-05).** Chưa phải lỗi. TC-1-22 đổi cách kiểm sang **cấp lọc**: với "Không hạt cây", các món chứa lạc vẫn nằm trong tập hợp lệ (unit test `Filter`), không đòi lạc phải xuất hiện trong tuần. Dev kiểm nhanh xem điểm của món lạc có bị phạt bất thường không; Research đếm số món có lạc. Ưu tiên thấp.

**D-QA-07 — Dữ liệu thiếu (L-04: rau muống).** Đúng là thiếu dữ liệu và PRD dùng làm ví dụ. Đưa vào **đợt mở băng dữ liệu D1** (T-054b): rau muống cùng các món dùng rau muống, cộng các việc dữ liệu đang chờ (gạo sống T-042c, ngưỡng `nhieu_xo` ≥ 4 g nếu chưa áp dụng, chuẩn hóa `allergen_tags` vừng nếu cần).
- Mở băng **sau** khi Dev xong nhóm lỗi P0 của T-093, để kết quả test không bị lẫn giữa lỗi code và thay đổi dữ liệu.
- Sau D1: xuất lại golden và chạy lại engine-report.

**D-QA-08 — L-12: hai mức ngân sách tối thiểu khác nhau (PM, 2026-11-07). Ưu tiên P1.** Ngân sách phải là con số người dùng tin được.
- **Một nguồn sự thật:** mức tối thiểu luôn lấy từ `budget-range` của server (D-BUD-02). Không có phép tính tối thiểu thứ hai ở app.
- Bước ngân sách đứng trước các bước kiêng/dị ứng, dụng cụ, thói quen ăn cơm, nên ở đó mức tối thiểu chỉ là **tạm tính**. Màn tổng kết gọi lại `budget-range` với **đầy đủ** lựa chọn và là con số cuối.
- Nếu mức ở tổng kết cao hơn mức ở bước ngân sách, cảnh báo phải nói lý do: "Sau các lựa chọn chế độ ăn/dụng cụ, mức tối thiểu gợi ý là 700.000 ₫ (lúc chọn ngân sách là 650.000 ₫)", kèm nút "Dùng 700.000 ₫". Không hiện câu khiến người dùng nghĩ họ chọn sai ở bước trước.
- Nếu **cùng lựa chọn** mà ra hai số khác nhau thì đó là lỗi tính, phải sửa về một hàm.

**D-QA-09 — L-13: tab Bạn offline hiện "…" (PM, 2026-11-07). Ưu tiên P2.** Chỉ tiêu mỗi ngày đã tính lúc onboarding nên phải **lưu trên máy và hiện số đã lưu** khi offline. Chỉ khi chưa có số lưu mới hiện thông báo theo quy tắc lỗi mạng (`ApiException.isNetwork`) kèm nút Thử lại; không bao giờ để "…" trơ trọi.

**D-SHP-03 — Hệ số cơm → gạo (PM xác nhận, 2026-11-07).**
- **Chấp nhận** hệ số của Research trong đợt D1 (`docs/research/data-batch-D1.md`): `com_trang → gao_te` = **0,36**, `gao_lut_nau_chin → gao_lut` = **0,34**.
- Lý do: hệ số phải khớp dinh dưỡng, vì kcal không mất đi khi nấu. Gạo tẻ 365 kcal × 0,36 ≈ 131 kcal, khớp cơm 130 kcal/100 g. Với 0,4 thì lệch 12%. Hệ số 0,36 ứng với khoảng 2,8 g cơm/1 g gạo, hợp với cơm nấu nồi điện thông thường.
- Quy tắc chung cho mọi `purchase_as`: kcal/100 g của nguyên liệu gốc ≈ kcal/100 g của nguyên liệu đích × `factor`, sai số ≤ 5%. Validate-data cảnh báo khi lệch quá mức này.

**D-SHP-04 — Nhiều quy cách bao bì cho một nguyên liệu – cửa hàng: để P2 (PM, 2026-11-07).**
- MVP giữ **một dòng giá** cho mỗi cặp nguyên liệu – cửa hàng, chọn quy cách phổ biến nhất cho hộ 1–4 người (gạo: bao 2 kg; dầu: chai 400–500 ml).
- Lý do:
  - Gạo, dầu, gia vị là đồ nhà có sẵn mặc định, không cộng vào tiền tại quầy (D-SHP-01), nên ảnh hưởng tới con số người dùng thấy là nhỏ.
  - Phần dư đã được ghi và tính cho tuần sau.
  - Đổi schema giá ảnh hưởng validate, engine, golden và dữ liệu đang đóng băng.
- P2 (T-079): nhiều quy cách, engine chọn tổ hợp gói rẻ nhất đủ lượng cần. Dev ước lượng công khi rảnh, không chặn MVP.
- Ghi nhận: giá gạo siêu thị **chưa xác minh** (trang BHX không tải được danh sách). Giữ nhãn "ước tính" và theo dõi ở T-042b.

**D-SHP-05 — Dòng giá `com_trang` và `gao_lut_nau_chin` (PM ghi nhận quyết định của session chính, 2026-11-07).**
- **Giữ** hai dòng giá cơm nấu chín trong `data/prices.json` và đánh dấu **deprecated**, không xóa.
- Lý do: engine TS đã đóng băng và chỉ dùng để sinh golden ở chế độ parity, mà chế độ này không đọc `purchase_as`. Xóa hai dòng thì golden vỡ, còn sửa TS chỉ để bỏ hai dòng thì không đáng.
- Engine C# ưu tiên `purchase_as` (gạo sống). Hai dòng cũ chỉ còn dùng cho parity và không được hiển thị cho người dùng.
- Validate-data không báo lỗi với hai dòng này.

**D-DIV-01 — Độ đa dạng món khi kho hẹp (L-11, PM 2026-11-07).** (Bổ sung ngoại lệ "ngân sách sát" ≥ 8 món ở D-DIV-02.)

Sau đợt D1, 12/14 hồ sơ có 10–11 mâm khác nhau/tuần. p09 (chỉ lò vi sóng) ra 6, p15 ra 8, vì kho món hợp lệ hẹp.

Chọn **chấp nhận ngoại lệ, không tạo task mới**:
- **Ngưỡng:**
  - Hồ sơ bình thường: 10–12 món chính khác nhau cho 14 bữa trưa+tối (US-2.3 AC2).
  - Hồ sơ ít dụng cụ (không có bếp) hoặc có ≤ 20 món chính hợp lệ sau lọc: ≥ 6.
- **Dữ liệu:** không tạo task mới. T-054 (món chỉ cần lò vi sóng/nồi cơm điện) và T-053 đã có, sẽ tự nâng p09/p15 khi làm xong.
- **Engine-report:** ghi thêm "số món chính hợp lệ sau lọc" cạnh số món khác nhau, để phân biệt kho hẹp (chấp nhận) với engine chọn kém (lỗi).
- **Cảnh báo:** nếu hồ sơ bình thường nào rơi xuống dưới 10, đó là lỗi engine và phải mở lại L-11.

**D-SHP-01 và D-SHP-02** (đồ nhà có sẵn không tính tiền tại quầy; cơm quy ra gạo sống khi đi chợ) **đã chốt** ở trên ngày 2026-11-07, task T-078 và T-042c.

**D-API-01 — Bổ sung API cho màn Flutter T-083…T-089.** Rà `backend/openapi/openapi.json` thấy thiếu dữ liệu cho các màn (chi tiết ở **T-070**):
- Kế hoạch/công thức chạy offline mà không phải gọi N lần `GET /v1/recipes/{id}`.
- Quy đổi đơn vị bếp.
- Danh sách xu hướng sức khỏe và chip gợi ý món ghét.
- Tính lại danh sách đi chợ khi đánh dấu "nhà có sẵn".
- Schema số đang là `number | string`, làm client Dart sinh sai kiểu.

**D-DES-01 — Món tráng miệng (yêu cầu người dùng, PM chốt 2026-11-06).** Người dùng yêu cầu mỗi bữa có tráng miệng, ví dụ trái cây hoặc sữa.
- **Phạm vi:**
  - Bắt buộc **1 món tráng miệng ở mỗi bữa trưa và tối được lên thực đơn**, cả bữa ghép mâm lẫn `full_meal`.
  - Bữa sáng, bữa phụ: không thêm ở MVP. Bữa phụ thường đã là trái cây/sữa; thêm nữa sẽ trùng.
  - Bữa "Tôi tự lo", "Ăn ngoài" và `unfilled`: không có tráng miệng.
  - MVP chưa có công tắc tắt tráng miệng. Nếu người dùng phản hồi thì thêm vào tab Bạn (P1).
- **Dinh dưỡng:**
  - Tráng miệng tính vào macro và calo của bữa, nên tổng ngày vẫn phải nằm trong dải ±5% và đạt sàn protein.
  - Engine **trừ trước** phần kcal của tráng miệng khỏi chỉ tiêu bữa, rồi mới scale món chính/cơm.
  - Khẩu phần tráng miệng được scale trong biên hẹp (vd trái cây 100–200 g) để làm "núm" tinh chỉnh kcal.
  - Mục tiêu kcal 50–180 kcal/món.
- **Loại món:**
  - trái cây tươi;
  - sữa tươi không/ít đường, sữa chua (không đường, có đường, Hy Lạp);
  - sữa đậu nành/sữa hạt (cho chay);
  - chè ít đường;
  - thạch/rau câu ít đường.
- **Ràng buộc:**
  - Tráng miệng là một công thức có nguyên liệu. Mọi ràng buộc cứng áp như món khác: thuần chay → không sữa bò; không sữa; dị ứng đậu nành/lạc/hạt; món ghét; món bị chặn.
  - Ít tinh bột: chỉ món có cờ `low_carb_ok` (sữa chua không đường, ổi, bưởi, dưa hấu phần nhỏ…). Không dùng chè.
  - Xu hướng "Phù hợp người tiểu đường": ưu tiên mềm cho món ít đường.
  - Trưa mang đi: chỉ món có `portable: true` (trái cây nguyên quả, sữa hộp, sữa chua).
- **Đa dạng:**
  - Không lặp cùng một món tráng miệng trong một ngày.
  - ≥ 3 món tráng miệng khác nhau trong tuần (nếu đủ ứng viên).
  - Ưu tiên mềm: trái cây hạn dùng ngắn xếp đầu tuần, loại để lâu (cam, táo, bưởi) xếp cuối tuần (dùng `shelf_life_days`).
- **Đi chợ:**
  - Trái cây bán theo quả hoặc theo kg, sữa/sữa chua bán theo hộp/lốc. Cả hai dùng `pack_g` + `pack_label` có sẵn: 1 quả = `pack_g` là gram trung bình một quả, `pack_label` "1 quả"; bán cân thì bước 100 g; sữa thì `pack_label` "lốc 4 hộp 180 ml".
  - Danh sách hiển thị theo đơn vị mua ("3 quả chuối", "1 lốc sữa chua") kèm gram.
  - Chất lỏng lưu bằng gram (1 ml sữa ≈ 1,03 g; ghi trong `household_units`).
- **Không có ứng viên hợp lệ** (vd loại quá nhiều thứ): bữa vẫn được lên, không có tráng miệng, kèm cảnh báo mềm `dessert_missing` trên bữa. Không tính là ngày không đạt.
- **Dữ liệu:** thêm `dish_role: "dessert"` cùng hai cờ `portable` và `low_carb_ok` vào hợp đồng dữ liệu (backlog v0.2). Research soạn khoảng 20 món (T-058).
- **Tiêu chí:**
  - Engine-report: 100% bữa trưa/tối được lên thực đơn có tráng miệng (trừ `dessert_missing` có lý do).
  - Tỉ lệ hồ sơ đạt 7/7 không thấp hơn baseline quá 1 hồ sơ.
  - 0 vi phạm ràng buộc cứng.
- **Task:** T-071 (engine + API). Có thể gộp vào T-066 nếu Dev chưa chốt T-066. Dữ liệu: T-058.

## 11. Tên app (Q1): **ĐÃ ĐÓNG**, chốt "FitPro - Mâm đủ" (2026-11-06)

Người dùng ghép "FitPro" với đề xuất "Mâm Đủ". Rủi ro: "FitPro" là chữ phổ biến trong app/thương hiệu thể hình, nên **Research cần kiểm tra trùng trên store và nhãn hiệu sớm** (T-056). Nếu vướng, dự phòng là giữ "Mâm đủ" làm tên chính.

Danh sách đề xuất ban đầu (lưu tham khảo):

| Tên | Lý do |
|---|---|
| **Mâm Đủ** *(PM khuyến nghị)* | Nói đúng lời hứa của sản phẩm: mâm cơm Việt (Q4) mà vẫn "đủ" protein/calo mỗi ngày. Ngắn, dễ nhớ, dễ làm logo hình mâm. |
| Mâm Tuần | Một mâm cơm lo cho cả tuần; nhấn vào việc lập kế hoạch 7 ngày + đi chợ 1 lần. |
| Đủ Đạm | Nói thẳng giá trị cốt lõi (sàn protein) với người tập luyện; hơi hẹp với hộ gia đình. |
| Cơm Nhà Fit | Ghép "cơm nhà" quen thuộc với "fit"; rõ đối tượng tập luyện nhưng lai tiếng Anh. |
| Cân Mâm | "Cân đối mâm cơm", gợi đến gram chính xác và minh bạch số liệu. |
| Bếp Tuần | Trung tính, rộng: bếp nhà cả tuần, dễ mở rộng tính năng sau. |
| Chợ Gọn | Nhấn vào đi chợ đúng lượng, đúng ngân sách; hợp người bận rộn, nhưng lệch khỏi trọng tâm dinh dưỡng. |
| Ăn Đủ | Rất ngắn, dễ nhớ, dễ phát âm; phải kiểm tra trùng tên vì khá phổ thông. |

Trước khi chốt cần kiểm tra trùng tên trên Google Play/App Store, tên miền và nhãn hiệu (task RESEARCH T-056).

## 12. Freemium: ranh giới free / premium (đề xuất, P2)

Nguyên tắc: bản free phải **dùng thật được mỗi tuần** để tạo thói quen. Mọi thứ liên quan **an toàn** (dị ứng, kiêng) và **minh bạch số liệu** luôn free. Premium bán sự **tiện lợi và linh hoạt**.

| Tính năng | Free | Premium |
|---|---|---|
| Onboarding, chỉ tiêu theo công thức/tự nhập | ✓ | ✓ |
| Dị ứng, kiêng, món ghét, dụng cụ | ✓ (đầy đủ) | ✓ |
| Kế hoạch tuần | **1 tuần đang chạy**; tạo tuần mới 1 lần/tuần | Không giới hạn; xem trước tuần tới |
| Ghép mâm, công thức, chế độ nấu, "Cách chúng mình tính" | ✓ | ✓ |
| Đổi món / đổi nguyên liệu | **3 lần/tuần** (tổng) | Không giới hạn |
| Ăn ngoài / bỏ bữa, "Không hợp với tôi" | ✓ | ✓ |
| Lên lại phần còn lại của tuần | ✗ | ✓ |
| Tuần đã lưu (lịch sử, dùng lại tuần cũ) | Chỉ tuần hiện tại | ✓ |
| Danh sách đi chợ | Giá chung ("Chợ/Nơi khác"), gộp theo quầy | **Giá + quy cách bao bì theo cửa hàng đã chọn**, phần dư, chi phí tại quầy |
| Hộ gia đình | Chỉ mình bạn | **Nhiều thành viên**: "cả nồi", danh sách đi chợ nhân cả nhà |
| Khẩu vị nâng cao (vuốt lại, chỉnh trọng số) | Cơ bản | ✓ |
| v2/v3: gợi ý món mới bằng LLM | ✗ | ✓ |

- Dùng thử: **7 ngày premium miễn phí** sau onboarding (tuần đầu trải nghiệm đầy đủ, sau đó về free).
- Giá tham khảo (giả định, cần T-056 khảo sát): **49.000 ₫/tháng**, **299.000 ₫/năm**.
- Thanh toán: trên mobile phải dùng In-App Purchase của Google Play/App Store (chính sách store với gói số). Web (P2) có thể dùng MoMo/ZaloPay/VNPay. Quyền lợi kiểm ở backend, nên cần tài khoản (T-029).
- MVP: chưa chặn giới hạn nào. App ghi lại số lần đổi món để sau này đo xem ngưỡng 3 lần/tuần có hợp lý không.
