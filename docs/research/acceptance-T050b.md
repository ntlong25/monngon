# Kiểm thử chấp nhận T-050b (lượt kiểm lại)

Ngày: 07/11/2026 · Owner: RESEARCH · Theo `docs/research/test-scenarios.md` (đã sửa T-057b) và `docs/research/acceptance-T050.md`.
Không sửa mã. Không sửa `data/` trong lượt này. Lỗi mới đánh số từ L-10.

## 1. Trạng thái bước dữ liệu (yêu cầu 1 của session chính)

- **Chưa bỏ được dòng giá `com_trang`.** Thử xóa dòng cơm nấu chín (1 kg, 12.000 ₫, cho_khac): `validate-data` báo lỗi "nguyên liệu com_trang chưa có giá ở cho_khac" (`src/data/validate.ts`, quy tắc fallback). Đã khôi phục đúng dòng cũ.
- `data/prices.json` hiện giống hệt bản đóng băng D1: sha256 `e6f0e35d1da2117252cef899892e60cede14cff925dcd3b30f0b19ccc3081855`. `data_version` = `48a76585a8e7851654d73fd4fb0c3db1c23da419da47ce31846366d80fd2e83e` (không đổi, không đóng băng lại).
- `validate-data` 0 lỗi, 1 cảnh báo (`rau_den`). `export-golden` 55 tệp. `npm test` 173/173.
- Chưa chạy lại `check-tests.py` và `engine-report` trong lượt này (data không đổi; kết quả gần nhất do session chính báo: check-tests OK, Engine 189, Api 45).
- **Cần quyết định:** để dòng com_trang với giá đánh dấu lỗi thời, hoặc Dev nới quy tắc fallback để bỏ qua nguyên liệu có `purchase_as`.

## 2. Môi trường

- API: `http://localhost:5095`, khởi động lại từ mã hiện tại (cổng trước đó đã đóng). Health `ok`, `data_version` khớp bản đóng băng.
- App: build APK release mới từ mã hiện tại (`FITPRO_CLEARTEXT=1`, 55,8 MB), cài trên `emulator-5554`. Đã force-stop và mở lại app trước khi kiểm (theo hướng dẫn L-09).

## 3. Kết quả API (chạy lại `scratchpad/t50_api.mjs`)

Tổng 43 mục: **38 đạt · 2 không đạt · 3 không áp dụng/UI**.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| TC-1-01…1-10, 1-12 (API) | Đạt | Như T-050 |
| TC-1-07 | Đạt | Dải ±5% theo D-QA-03 |
| TC-1-17 / TC-E-02 | **Không đạt** (L-02, còn mở) | API vẫn trả 200 khi tắt trưa và tối. D-QA-05 yêu cầu 400 |
| TC-1-21 | Đạt | Không lạc (5 seed) |
| TC-1-22 | Không áp dụng | D-QA-06 chuyển sang kiểm cấp bộ lọc (unit test), không đo bằng tuần |
| TC-1-23 | **Đạt** (L-03 đã sửa) | `no_seed` loại cả vừng |
| TC-1-24 | **Đạt** (L-04 đã sửa) | "rau muong" → "Rau muống" |
| TC-1-25, 1-26, 1-31, 1-32 | Đạt | 1-31 đã trả 400 |
| TC-2-01…2-05, 2-08, 2-10, 2-11, 2-13 | Đạt | |
| TC-2-04 | **Đạt** (L-01 đã sửa) | Không còn gram ngoài [min, max] |
| TC-2-04b | Đạt | Theo D-QA-04: dòng cố định (dầu 3 g) không làm tròn |
| TC-2-06, TC-2-07 | Đạt | Kiểm trên hồ sơ thiếu đạm (1.500 kcal, 260 g): `partial`, 7 ngày thiếu, có mức thiếu |
| TC-2-09 | **Không đạt** (L-11, nhẹ) | 14 bữa cho 9 món khác nhau, dưới khoảng 10–12 |
| TC-E-03, TC-E-07 | Đạt | |
| TC-4-02, 4-03, 4-06, 4-07 | Đạt | |
| TC-5-01, 5-02, 5-04, 5-06, 5-12 | Đạt | TC-5-04 đã kiểm lại: đổi ức gà/đậu hũ chỉ ra tempeh cùng swap_group |

## 4. Kết quả UI (emulator)

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Mở app mới, tab Kế hoạch | Đạt | Tuần còn lưu, banner "Mọi ngày đều đạt protein và calo" |
| **Tab Bạn (L-09)** | **Đạt sau khi mở lại app** | Chạm tab Bạn mở đúng danh sách "Chỉ tiêu và lựa chọn", có mục tiêu, cơ thể, vận động, chỉ tiêu, cửa hàng, người ăn, ngân sách, số bữa, xu hướng, đã loại |
| Đi chợ: gạo sống, "Nếu phải mua", trạng thái ngân sách (L-08) | **Chưa kiểm lại** | Lần trước (bản build cũ) thấy "Còn trong ngân sách, dư 255.234 ₫". Bản build hiện tại chưa chụp lại. Nếu `gen_arb.py` chưa chạy lại thì chuỗi D-QA-02 chưa lên app |
| Onboarding, công thức, đổi món/nguyên liệu trên UI, mất mạng, xóa dữ liệu, trợ năng | **Chưa kiểm** | Không đủ thời gian trong lượt này |

## 5. Lỗi

- **L-02 (còn mở, nặng):** API vẫn chấp nhận tắt hết bữa chính. D-QA-05 yêu cầu API trả 400. Không kiểm được app có khóa nút Tiếp tục trước khi gọi API (onboarding chưa kiểm).
- **L-10 (nhẹ, quy trình):** Mục "bỏ dòng giá com_trang" trong yêu cầu không thực hiện được vì quy tắc fallback của validator: mọi nguyên liệu phải có giá cho_khac. Cần Dev nới quy tắc (cho nguyên liệu có `purchase_as`) hoặc PM chấp nhận giữ dòng với nhãn lỗi thời.
- **L-11 (nhẹ):** Hồ sơ 14 bữa chỉ có 9 món chính khác nhau, dưới khoảng 10–12 của TC-2-09. Lượt trước (trước D1) là 12. Nguyên nhân có thể do thay đổi giá gạo và rau muống làm đổi cách chọn món. Cần Dev xem.

Không có lỗi chặn trong phạm vi đã kiểm.

## 6. Chưa xong

- Kiểm UI đầy đủ (onboarding, công thức, đổi món trên UI, mất mạng, xóa dữ liệu, trợ năng, L-08 và "Nếu phải mua" trên bản build hiện tại).
- Chạy lại `check-tests.py` và `engine-report` cho bản data hiện tại (đã báo kết quả ở lượt trước).
- Quyết định về dòng com_trang (mục 1).

## 7. Lượt kiểm thứ hai (07/11/2026, theo yêu cầu bổ sung)

Build: APK release mới từ mã hiện tại (`FITPRO_CLEARTEXT=1`), cài trên `emulator-5554`, mở lại app trước khi kiểm.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| L-08: trạng thái ngân sách | **Đạt** | Đi chợ hiện "Chi phí món ăn tuần này nằm trong ngân sách (dư 204.797 ₫)." và dòng thông tin trung tính "Lần đi chợ này ước tính 1.040.478 ₫, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau." Chuỗi D-QA-02 đã lên app |
| Dòng "Nếu phải mua: +X ₫" | **Đạt** | Hiện ở mục "Nhà đã có sẵn (11)", ví dụ "Nếu phải mua: +220.000 ₫" cho thịt bò đùi |
| Gạo sống trong danh sách | **Chưa xác nhận** | Không thấy trong phần đã đọc. Cần cuộn lên để kiểm mục "Gạo & đồ khô" |
| Công thức (TC-3-06…3-10), đổi món và đổi nguyên liệu trên UI, onboarding (TC-1-08…1-38), mất mạng, xóa dữ liệu, trợ năng | **Chưa kiểm** | Không đủ thời gian trong lượt này |

Số liệu mới đáng chú ý: chi phí món ăn tuần này 495.203 ₫ (trước đó 444.766 ₫ ở build cũ), tiền tại quầy vẫn 1.040.478 ₫. Đậu hũ hiện "13 × bìa 300 g (ước tính)" với giá 156.000 ₫ — số gói lớn cần xem lại khi có giá thật.

Phần chưa xong của T-050b: công thức, đổi món/nguyên liệu trên UI, onboarding, mất mạng, xóa dữ liệu, trợ năng, gạo sống trong danh sách. Lỗi mới đánh số từ L-12 nếu phát sinh.

## 8. Lượt kiểm thứ ba (07/11/2026): mục Gạo & đồ khô

- **Trên app (tuần đã lưu trên emulator):** mục "Gạo & đồ khô" vẫn hiện **"Cơm trắng (đã nấu chín)"**, "1 × gạo tẻ 5 kg, quy đổi sang cơm chín (ước tính)", **160.000 ₫**, "Cần 690 g · Dư 4.310 g". Yêu cầu "phải hiện gạo sống, không còn cơm" **chưa đạt trên màn này**.
- **Nguyên nhân khả dĩ:** tuần đã lưu được lập trước D1, khi dòng cơm còn quy cách 5 kg / 160.000 ₫. Dữ liệu hiện tại không có gói gạo 5 kg (`gao_te` chỉ có 1 kg, 22.000 ₫). Cần xác nhận bằng cách lập lại tuần.
- **Kiểm API cùng lúc (cùng data đóng băng 48a7…2e83):** tuần mới lập có `gao_te` "Gạo tẻ 1 kg (ước tính)", 1 gói, cần 689 g; không có dòng cơm nấu chín. **Hành vi đúng theo dữ liệu**, chỉ màn hiển thị đang dùng tuần cũ.
- **Hành động cần làm:** lập lại tuần trên app (tạo tuần mới) rồi chụp lại mục Gạo & đồ khô. Chưa làm được trong lượt này vì phải đi qua onboarding.
- **Lỗi mới:** không đánh số L-12 vì nguyên nhân có vẻ là dữ liệu tuần cũ, chưa xác nhận. Nếu lập lại tuần mà vẫn hiện cơm 5 kg thì ghi L-12 (nặng: sai dòng gạo đi chợ).

Các mục chưa kiểm (không đổi so với mục 7): công thức TC-3-06…3-10, đổi món và đổi nguyên liệu trên UI, onboarding TC-1-08…1-38, mất mạng, xóa dữ liệu, trợ năng.

## 9. Lượt kiểm thứ tư (07/11/2026): luồng xóa dữ liệu và onboarding (làm dở)

Build: APK release hiện tại. Thao tác trên emulator, chỉ xóa dữ liệu app trên máy test.

| TC | Kết quả | Ghi chú |
|---|---|---|
| TC-6-05: bấm "Xoá toàn bộ dữ liệu" | **Đạt (một phần)** | Hiện hộp xác nhận bước 1 "Xoá toàn bộ dữ liệu trên máy này?" có Huỷ / Tiếp tục. Bước 2 "Thao tác này không hoàn tác được. Bạn chắc chứ?" có Huỷ / Xóa tất cả. Sau khi xóa, app về onboarding |
| TC-6-05: không còn tuần đã lưu | **Chưa kiểm** | Chưa mở lại tab Bạn sau khi xóa |
| TC-1-37/TC-E-05 và onboarding | **Làm dở** | Đã vào bước 1 "Bạn muốn đạt mục tiêu nào?", mặc định "Giảm mỡ" đã chọn, có "Tiếp tục". Chưa đi tiếp các bước 2–10 |
| TC-1-08…1-38 (còn lại) | **Chưa kiểm** | Chưa đi hết onboarding, nên chưa tạo tuần mới để kiểm Đi chợ "Gạo & đồ khô" (mục 3 của yêu cầu) |
| Công thức (TC-3-06…3-10), đổi món, đổi nguyên liệu | **Chưa kiểm** | Phụ thuộc tuần mới |
| Mất mạng (TC-E-04 và các màn) | **Chưa kiểm** | |
| Trợ năng, font scale 1.3 | **Chưa kiểm** | |

Lỗi mới: không ghi nhận trong lượt này. Phần chưa xong sẽ làm tiếp khi có tuần mới.

## 10. Lượt kiểm thứ năm (07/11/2026): onboarding đi được đến bước Kiêng (dừng giữa chừng)

Đi tiếp từ bước 1 sau khi xóa dữ liệu (mục 9). Dùng lựa chọn mặc định. Chưa tạo được tuần.

| TC | Kết quả | Ghi chú |
|---|---|---|
| TC-1-08 | Đạt (một phần) | Cửa hàng: chỉ một thẻ được chọn ("Bách hóa Xanh" mặc định, có dấu tích), có "Giá khảo sát ngày 06/11/2026" |
| TC-1-11 | Đạt (một phần) | Người lớn: nút − bị vô hiệu ở mức 1 (không xuống dưới 1). Trẻ em: 0 |
| TC-1-13 | Đạt | Có dòng "Mục tiêu dinh dưỡng vẫn là của riêng bạn, dù ai ngồi cùng mâm." |
| TC-1-09 | Đạt (một phần) | Ngân sách 650.000 ₫, nhãn bậc "Vừa phải — Có thêm đạm và rau đa dạng.", tối thiểu 650.000 ₫, tối đa 1.450.000 ₫ |
| TC-1-10 | Đạt (một phần) | "Tuần này có 28 bữa." (4 bữa × 7 ngày), ghi chú ngân sách là chi phí món ăn (D-QA-02) |
| TC-1-02 / TC-1-07 | Đạt | Màn chỉ tiêu: BMR → TDEE → mục tiêu → protein, dải calo 1.853–2.048 quanh 1.950 kcal (±5%) |
| TC-1-14 | Đạt (một phần) | Chân màn "Mỗi bữa ~487 kcal và 36 g protein" |
| TC-1-15 / TC-1-16 | Đạt (một phần) | Mỗi bữa có ba chế độ "Lên thực đơn / Tự lo / Không lên món"; bữa trưa có "Nóng / Mang đi" |
| TC-1-29 | Chưa kiểm | |
| TC-1-18 / TC-1-19 | Chưa kiểm | Bước Kiêng hiển thị đúng. Chưa bấm để kiểm loại trừ lẫn nhau |
| TC-1-22 / TC-1-23 (nhãn) | Đạt (nhãn) | Có "Không hạt giống & vừng" và "Không vừng" tách riêng, đúng D-QA-01 |
| Bước 1, 2, 3 (mục tiêu, cơ thể, vận động) | Đạt | Mặc định Giảm mỡ, Nam, 30 tuổi, 170 cm, 65 kg, vận động "Vừa, 3–4 buổi" |

Chưa làm: bước Kiêng (thao tác chọn), Xu hướng, Ghét, Vuốt, Dụng cụ, Tổng kết; tạo tuần; Đi chợ "Gạo & đồ khô"; công thức và đổi món/nguyên liệu; mất mạng; font 1.3; tab Bạn sau khi có tuần (không còn tuần đã lưu).

Không ghi nhận lỗi mới trong các bước đã kiểm. Mục 9 còn mở các bước trên.

## 11. Đối chiếu 36 ảnh của Dev (`docs/dev/screens/it-*.png`) với TC (07/11/2026)

Nguồn: integration test của Dev trên emulator-5554 (xanh). Đối chiếu từng ảnh đã mở; ảnh chưa mở ghi rõ. Kết quả: **Đạt (ảnh)** = ảnh cho thấy đúng yêu cầu; **Một phần** = ảnh chỉ thể hiện một phần, còn hành vi chưa thấy; **Chưa phủ** = không có ảnh hoặc không mở được.

| TC | Kết quả | Ảnh | Ghi chú |
|---|---|---|---|
| TC-1-14 | Đạt | onb-08-bua-an | Chân màn "Mỗi bữa ~350 kcal và 30 g protein" |
| TC-1-15 / 1-16 | Đạt (nhãn) | onb-08-bua-an | Ba chế độ "Lên thực đơn / Tự lo / Không lên món"; hành vi chia lại chỉ tiêu chưa thấy |
| TC-1-17 | Một phần | onb-08-bua-an | Chưa có ảnh trạng thái tắt hết bữa chính; gating nút Tiếp tục chưa phủ |
| TC-1-18 / 1-19 | Một phần | onb-09-kieng | Chỉ có trạng thái cuối; loại trừ lẫn nhau chưa thấy |
| TC-1-21 | Chưa phủ | — | |
| TC-1-22 / 1-23 | Đạt (nhãn) | onb-09-kieng | "Không hạt giống & vừng" và "Không vừng" tách riêng; hành vi loại trừ chưa thấy |
| TC-1-30 | Một phần | onb-11-vuot-the-ket-qua | Có nút "Vuốt lại" và tóm tắt "Bạn thích / Ít hơn"; hành vi xóa kết quả chưa thấy |
| TC-1-31 / 1-32 | Một phần | onb-12-dung-cu | Chọn Bếp + Nồi cơm điện, Tiếp tục bật; trường hợp bỏ chọn hết chưa có ảnh |
| TC-1-33 | Đạt | onb-13-tong-ket | Checklist khớp lựa chọn: Giảm mỡ, 120 g protein, 1.400 kcal, 4 bữa, Nhiều chất xơ, Không có loại, Bếp + Nồi cơm điện, 650.000 ₫ |
| TC-1-34 | Một phần | 03-tao-tuan-dang-tao | Có màn "Đang lên thực đơn"; thời gian ≤ 5 s chưa đo |
| TC-1-35 | Đạt | 04-ke-hoach-ngay-1 | Ngày đầu "Chủ nhật · 08/11". 07/11/2026 là thứ Bảy, nên "ngày mai" là Chủ nhật 08/11 |
| TC-3-01 | Đạt | 09-tab-ban, 04-ke-hoach-ngay-1 | Thanh tab: Kế hoạch · Đi chợ · Bạn |
| TC-3-02 | Chưa phủ | — | Lời chào theo giờ và dòng trạng thái tuần chưa thấy |
| TC-3-03 | Đạt | 04-ke-hoach-ngay-1 | "Chủ nhật · 08/11 · 120 g protein · 1.466 kcal". Cộng 4 bữa: protein 25+38+10+47 = 120 g; kcal 270+496+79+622 = 1.467, lệch 1 kcal do làm tròn |
| TC-3-04 | Đạt | 04-ke-hoach-ngay-1 | Ảnh/placeholder, nhãn bữa + thời gian, tên món, chip macro |
| TC-3-05 | Đạt | 07-an-ngoai | Bữa trưa "Ăn ngoài" hiện dạng dòng không có món. "Tôi tự lo" chưa thấy |
| TC-3-06 | Một phần | 06-doi-mon-xong | Có ảnh, "CHỦ NHẬT · BỮA TRƯA", tên, 25 phút, chip, "Cách chúng mình tính", "Đổi món này", "Ăn ngoài / bỏ bữa", thẻ Nguyên liệu. Chưa thấy "Cách làm" và "Không hợp với tôi" trên trang công thức (nút này chỉ thấy ở màn mâm) |
| TC-3-07 | Đạt | 06-doi-mon-xong | "≈ 2,5 thìa canh" (dầu), "≈ 0,6 thìa canh" (nước mắm); thịt heo không có quy đổi nên không hiện |
| TC-3-08 | Chưa phủ | — | Cần hồ sơ 2 người lớn + 1 trẻ, kiểm thủ công |
| TC-3-09 | Chưa phủ | — | Cần đánh dấu bước rồi mở lại app, kiểm thủ công |
| TC-3-10 | Chưa phủ | — | Cần chế độ nấu và đợi 2 phút, kiểm thủ công |
| TC-3-11 | Một phần | 06-doi-mon-xong; 05-cach-chung-minh-tinh | Khoai tây: 38×4 + 6×4 + 34×9 = 482 so với 477 kcal, lệch +1%, đạt. Mâm đậu hũ (bảng "Tổng" trên 05-cach-chung-minh-tinh): 38×4 + 38×4 + 26×9 = 538 so với 496 kcal, lệch 8,5%, vượt ±5%. Đây là tổng cả mâm, không phải một công thức; cần Dev xác nhận, chưa ghi thành lỗi |
| TC-3-12 / 3-13 | Đạt | 05-cach-chung-minh-tinh | Bảng "gram × giá trị/100 g" (ví dụ "30 g × 123 kcal/100 g = 37 kcal"); tổng "đúng số trên chip ở màn bữa" |
| TC-3-14 | Đạt | 05-cach-chung-minh-tinh | Dòng ghi "USDA FDC #…" |
| TC-4-01 | Một phần | 08-di-cho-gao-song | Thấy "Gạo tẻ (sống) · Cần 47 g", "Nếu phải mua: +22.000 ₫" ở mục "Nhà đã có sẵn (10)". Không có "Cơm trắng". Tiêu đề quầy "Gạo & đồ khô" chưa thấy trong ảnh |
| TC-4-02 / 4-03 / 4-04 | Chưa phủ | 08-di-cho-da-mua chưa đối chiếu | |
| TC-5-01 | Đạt | 06-doi-mon-goi-y | Ba món; mỗi món có Δprotein, Δkcal, Δ₫ và "Ngày vẫn đạt" |
| TC-5-02 | Một phần | 06-doi-mon-xong | Có "Đã đổi món" và "Hoàn tác"; danh sách đi chợ cập nhật chưa thấy |
| TC-5-06 | Đạt | 07-an-ngoai | Bữa trưa ghi "Ăn ngoài", có "Hoàn tác" |
| TC-5-09 | Đạt | 07-an-ngoai-hoan-tac | Hiện "Đã hoàn tác"; bữa trưa trở lại 38 g protein, 496 kcal |
| TC-6-01 | Một phần | 09-tab-ban | Có dòng "Thay đổi áp dụng cho tuần tạo kế tiếp. Tuần hiện tại giữ nguyên…"; nút "Lên lại tuần này với lựa chọn mới" chưa thấy |
| TC-6-03 | Chưa phủ | — | |
| TC-6-05 | Một phần | 09-xoa-du-lieu-buoc-2; 01-xoa-du-lieu | Hộp xác nhận bước 2 có "Xóa tất cả"; sau xóa về onboarding. Ảnh chụp lúc mở hộp thoại có "Tuần đã lưu 0 tuần"; không xác nhận được "không còn tuần đã lưu" sau xóa |
| TC-E-04 | Chưa phủ | — | Mất mạng: kiểm thủ công (mục 12) |
| TC-E-08 | Chưa phủ | — | Trợ năng: chưa kiểm |

Ảnh chưa mở: 08-di-cho-da-mua, 09-ve-onboarding, 02-onb-01…07, 02-onb-10 (khong-thich), 04-ke-hoach-ngay-2…7, 05 (bữa mâm chip đã mở), 06-doi-mon-hoan-tac, 07 (đã mở). Các ảnh này chỉ được tra cứu khi cần cho TC chưa phủ.

## 12. Kiểm tay mất mạng và cỡ chữ 1.3 (07/11/2026): chưa hoàn tất

- **Phát hiện:** trên emulator-5554 không còn cài `vn.fitpro.fitpro_mamdu` (chỉ còn `com.ntlong25.momcare`). Dữ liệu app của lượt trước đã mất.
- **Đã làm:** cài `mobile/build/app/outputs/flutter-apk/app-debug.apk` (bản Dev chụp ảnh IT, 12:06). Đặt cỡ chữ 1.3 (`font_scale` 1.3), mở app.
- **Chặn:** app dừng ở màn splash Flutter sau hơn 60 giây. Tiến trình đang chạy và Dart VM service đã khởi động, nhưng không có khung hình nào mới. Chưa xác định nguyên nhân (bản debug chạy độc lập không qua `flutter run`, hoặc emulator).
- **Chưa kiểm:** TC-E-04 (mất mạng), cỡ chữ 1.3 trên các màn, TC-3-08 (hồ sơ 2 người lớn + 1 trẻ), TC-3-09 (lưu bước đã xong), TC-3-10 (giữ màn hình khi nấu).
- **Đã khôi phục:** `font_scale` về 1.0. App debug vẫn cài trên máy; chưa gỡ.
- **Việc tiếp theo:** Dev xác nhận cách chạy bản test (ví dụ `flutter run` hoặc APK release có `FITPRO_CLEARTEXT=1`), hoặc cho phép cài lại app và làm lại onboarding trên máy này.

## 13. Lượt kiểm tay theo yêu cầu bổ sung (APK profile, API 5097, 07/11/2026)

Cài và chạy theo `mobile/README.md`. APK profile đã có sẵn trên emulator, API `http://localhost:5097` trả `ok`, `data_version` 13d35976…b124. Tạo tuần mới bằng hồ sơ mặc định (giảm mỡ, nam 30 tuổi, 170 cm, 65 kg, 1.950 kcal, 4 bữa).

| TC | Kết quả | Ghi chú |
|---|---|---|
| TC-1-46 (nhãn chén) | **Đạt** | Bước "Thói quen ăn cơm" hiện "½ chén (~75 g)", "1 chén (~150 g)", "2 chén (~300 g)", "3 chén trở lên (~450 g)"; mặc định "1 chén" được chọn; ghi chú "Chỉ áp cho bạn…" hiện đúng |
| TC-3-16 (thẻ cơm) | **Đạt một phần** | Mâm trưa có dòng "1 chén cơm (~150 g)" với chữ đúng; món "Gạo lứt nguội mang đi" 150 g, 185 kcal khớp 150 × 123/100. Chưa kiểm được ghi chú giảm cơm (chưa có bữa bị giảm) |
| TC-1-39…1-45 (bước thói quen, tab Bạn) | Đạt một phần | Bước hiện đúng; tóm tắt ở màn "Đây là thiết lập của bạn" hiện "Thói quen ăn cơm: 1 chén (~150 g)". Chưa kiểm đổi mức ở tab Bạn (TC-1-43) |
| TC-E-04 (mất mạng) | **Một phần; có lỗi nghi ngờ** | Tắt Wi-Fi và dữ liệu: tab Đi chợ hiện đủ danh sách và chi phí (dữ liệu trên máy, không lỗi). Tab Bạn hiện đủ danh sách nhưng dòng "Chỉ tiêu mỗi ngày" hiện "…" thay vì "120 g protein · 1.400 kcal" như lúc online. Chưa thử "Tạo thực đơn tuần" offline (cần qua onboarding) |
| Cỡ chữ 1.3 (màn Kế hoạch) | Đạt một phần | Tiêu đề, banner, thẻ bữa và thanh tab hiển thị đủ, không cắt chữ. Các màn khác chưa kiểm |
| TC-3-08 (2 người lớn + 1 trẻ) | **Chưa kiểm** | Chưa đổi "Người ăn" |
| TC-3-09 (lưu bước đã xong) | **Chưa kiểm** | Chưa mở "Cách làm" |
| TC-3-10 (giữ màn hình khi nấu) | **Chưa kiểm** | Chưa mở "Chế độ nấu" |

**Quan sát cần Dev/PM xem (chưa ghi thành lỗi L-xx):**
1. Ngân sách 650.000 ₫ ở bước ngân sách, nhưng màn tổng kết cảnh báo "Ngân sách 650.000 ₫ thấp hơn mức tối thiểu gợi ý 700.000 ₫". Hai con số không khớp nhau.
2. Tab Bạn khi offline: "Chỉ tiêu mỗi ngày" hiện "…" (không có thông báo lỗi mạng).
3. Đi chợ offline: "Chi phí món ăn tuần này" 549.414 ₫ và "Ước tính trả tại quầy" 838.885 ₫ cho tuần lập online; cần đối chiếu với lúc online.

Đã khôi phục: mạng bật lại, `font_scale` về 1.0. Ảnh lưu ở `scratchpad/t50d/`.

## 14. Lỗi mới từ lượt 13 (đánh số tiếp từ L-12)

Hai điểm nghi ngờ ở mục 13 được ghi thành lỗi. Mức ưu tiên là đề xuất của RESEARCH; PM quyết định cuối.

### L-12 · Ngân sách: bước chọn và màn tổng kết nêu hai mức tối thiểu khác nhau (đề xuất: vừa)

- **Các bước:** onboarding → "Mỗi tuần bạn muốn chi bao nhiêu cho đi chợ?" → kéo về mức tối thiểu → tiếp tục đến "Đây là thiết lập của bạn".
- **Thực tế:** ở bước ngân sách hiện "Tối thiểu 650.000 ₫" (bước nhảy 50.000 ₫). Ở màn tổng kết có khối cảnh báo "Ngân sách 650.000 ₫ thấp hơn mức tối thiểu gợi ý 700.000 ₫ cho lựa chọn của bạn", kèm nút "Dùng mức tối thiểu". Với cùng hồ sơ (giảm mỡ, nam 30 tuổi, 170 cm, 65 kg, 4 bữa, bếp và nồi cơm điện, bách hóa xanh), hai con số không khớp.
- **Kỳ vọng:** một con số tối thiểu thống nhất giữa bước chọn và tổng kết, hoặc cảnh báo chỉ hiện khi tổng kết thật sự thấp hơn mức tối thiểu đã cho phép (TC-1-09, TC-1-33).
- **Vì sao vừa:** cảnh báo ghi con số không đúng với mức người dùng vừa đặt, dễ khiến họ đổi ngân sách mà không cần thiết. Không chặn tạo tuần và không mất dữ liệu.
- **Ảnh:** `scratchpad/t50d/06-step.png` (tổng kết), `scratchpad/t50d/02-step.png` (bước ngân sách, 650.000 ₫, tối thiểu 650.000 ₫).

### L-13 · Tab Bạn khi offline: "Chỉ tiêu mỗi ngày" hiện "…", không có thông báo mạng (đề xuất: nhẹ)

- **Các bước:** tạo tuần khi online → tắt Wi-Fi và dữ liệu di động → mở tab Bạn.
- **Thực tế:** dòng "Chỉ tiêu mỗi ngày" hiện "…" thay vì "120 g protein · 1.400 kcal" (hoặc số tương ứng) như khi online. Các mục khác (mục tiêu, cơ thể, vận động, cửa hàng, người ăn, ngân sách, số bữa, xu hướng) vẫn hiện đúng. Không có thông báo lỗi mạng và không có nút thử lại trên dòng này. Tab Đi chợ offline vẫn đủ dữ liệu.
- **Kỳ vọng:** TC-E-04 và quy tắc lỗi mạng trong `mobile/README.md` (`ApiException.isNetwork`): nếu dòng cần máy chủ thì hiện thông báo thân thiện, không để "…" trơ trọi. Hoặc lấy số đã lưu trên máy.
- **Vì sao nhẹ:** không mất dữ liệu và không chặn luồng chính; chỉ thiếu thông tin và thiếu thông báo khi ở tab Bạn.
- **Ảnh:** `scratchpad/t50d/14-offline-ban.png`.

Lỗi mới chưa được xác nhận lại trên bản build sau. Cần Dev kiểm nguyên nhân: L-12 có thể do hai nơi tính tối thiểu khác nhau, L-13 có thể do dòng chỉ tiêu đọc từ máy chủ.
