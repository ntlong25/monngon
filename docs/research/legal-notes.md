# Văn bản pháp lý tối thiểu (T-047)

Ngày soạn: 06/11/2026 · Owner: RESEARCH · Đây là bản nháp tự viết để đội và PM duyệt. **Không phải tư vấn pháp lý.** Trước khi phát hành công khai cần luật sư xem lại, đặc biệt là mục 1 và mục 3.

Bốn văn bản: (1) miễn trừ y tế, (2) nguồn dữ liệu, (3) giá là ước tính, (4) chính sách riêng tư MVP. Mỗi văn bản đọc được trong ≤ 1 phút.

---

## 1. Miễn trừ y tế

> **FitPro - Mâm đủ không phải lời khuyên y tế.** Thực đơn và chỉ tiêu protein, calo được tính theo công thức phổ biến và dữ liệu thành phần thực phẩm; chúng không chẩn đoán, không điều trị và không thay thế bác sĩ hay chuyên gia dinh dưỡng.
>
> Đặc biệt, **hãy hỏi bác sĩ trước khi thay đổi chế độ ăn** nếu bạn:
> - đang mắc hoặc nghi ngờ bệnh tiểu đường, bệnh tim mạch, bệnh thận, rối loạn ăn uống hoặc đang dùng thuốc cần theo dõi bữa ăn;
> - có hội chứng buồng trứng đa nang (PCOS) hoặc đang mang thai, cho con bú;
> - dưới 18 tuổi;
> - có dị ứng thực phẩm đã được chẩn đoán. Bộ lọc dị ứng là công cụ hỗ trợ, không thay cho việc đọc nhãn sản phẩm thực tế.
>
> Các lựa chọn "Nhiều chất xơ", "Ít đường", "Tốt cho tim mạch", "Ít béo" chỉ là ưu tiên khi chọn món, không phải chỉ định điều trị.

**Ghi chú cho đội:** hiển thị đoạn này ở tab Bạn (US-6.3) và ngay cạnh các lựa chọn "Xu hướng nấu ăn" ở onboarding (US-1.4 AC5). Danh sách lựa chọn đã chốt theo D-ONB-03 (PRD §10): bốn lựa chọn trên. "Hợp người tiểu đường" và "Chống viêm" không có trong MVP, nên không được xuất hiện ở đây. Vì không có lựa chọn "tiểu đường", câu về bệnh tiểu đường chỉ là lời khuyên hỏi bác sĩ, không liên quan đến một lựa chọn trên UI.

---

## 2. Nguồn dữ liệu

> Dữ liệu dinh dưỡng trong FitPro - Mâm đủ lấy từ:
> - **USDA FoodData Central** (U.S. Department of Agriculture, Agricultural Research Service. FoodData Central, 2019. https://fdc.nal.usda.gov/). Dữ liệu thuộc miền công cộng theo CC0 1.0; FitPro - Mâm đủ ghi nguồn theo đề nghị của USDA. Các mã FDC ID hiển thị ở "Cách chúng mình tính".
> - **Bảng thành phần thực phẩm Việt Nam (Viện Dinh dưỡng)** — *chưa dùng trong bản này; sẽ ghi lại khi đưa vào.*
> - Một số nguyên liệu dùng **bản ghi gần đúng** (proxy), ví dụ cá basa dùng số liệu cá da trơn, nước mắm chay dùng số liệu xì dầu. Các mục này được đánh dấu trong dữ liệu và sẽ được thay khi có nguồn đúng hơn.
>
> Số liệu là giá trị trên 100 g phần ăn được, có thể chênh lệch so với sản phẩm thực tế (giống, cách nấu, nhãn hàng). Các con số là ước tính để lập kế hoạch.
>
> FitPro - Mâm đủ không dùng logo, tên hay nội dung của bất kỳ ứng dụng nào khác.

**Ghi chú:** đây là lời ghi nguồn tối thiểu đúng với CC0 của USDA. Khi đưa bảng Viện Dinh dưỡng vào, phải thêm dòng ghi nguồn và giấy phép tương ứng (kiểm tra điều kiện sử dụng trước).

---

## 3. Giá là ước tính

> **Giá hiển thị trong FitPro - Mâm đủ là ước tính** tại thời điểm khảo sát (ghi ngày ở từng mục). Giá thực tế ở cửa hàng có thể khác do khuyến mãi, khu vực và thời điểm. FitPro - Mâm đủ không kết nối với hệ thống bán hàng của cửa hàng và không đặt hàng thay bạn.
>
> Chi phí "Ước tính trả tại quầy" làm tròn lên theo gói mua, không phải tổng tiền bạn sẽ trả.

**Ghi chú:** đặt nhãn "ước tính" và ngày khảo sát ở mọi nơi có giá (PRD US-4.1 AC3). Nội dung này khớp với `docs/research/prices-method.md`.

---

## 4. Chính sách riêng tư (MVP)

> Dữ liệu của bạn được lưu trên máy này: thông tin cơ thể, lựa chọn ăn uống, thực đơn và danh sách đi chợ. Ứng dụng không có tài khoản và không dùng công cụ phân tích hành vi.
>
> Khi tạo hoặc đổi thực đơn, thông tin cơ thể và lựa chọn của bạn được gửi tới máy chủ của ứng dụng chỉ để tính toán. Máy chủ không lưu lại dữ liệu đó.
>
> Bạn có thể xóa toàn bộ dữ liệu trên máy ở tab Bạn. Thao tác này không hoàn tác được.
>
> Nếu sau này có tài khoản hoặc đồng bộ, chính sách này sẽ được cập nhật và bạn sẽ được hỏi lại trước khi có thay đổi.

**Đối chiếu với code (07/11/2026):**
- Dữ liệu người dùng chỉ đi qua các endpoint `POST` của API (`/v1/targets`, `/v1/plans`, `/v1/plans/*`, `/v1/shopping-list`, `/v1/budget-range`, `/v1/slots/preview`). Đây đều là tính toán không trạng thái; `backend/MonNgon.Api` không có cơ sở dữ liệu, không có ghi file và không có bộ nhớ đệm theo đầu vào người dùng.
- Không có endpoint đăng ký, đăng nhập hay xác thực. `appsettings.json` đặt mức log `Information`, `Microsoft.AspNetCore` là `Warning`; không có middleware ghi nội dung request.
- `mobile/pubspec.yaml` không có SDK phân tích hay báo lỗi (không có Firebase, Sentry, Amplitude...). Lưu trữ trên máy dùng `shared_preferences`; mạng dùng `dio`.

**Ghi chú:**
- Đoạn "máy chủ không lưu lại" đúng với mã ứng dụng hiện tại, khi backend **chưa được triển khai**. Khi có máy chủ thật (PRD §9, mục 4), nhà cung cấp hosting, reverse proxy và CDN có thể ghi log truy cập (IP, thời gian, đường dẫn). Trước khi phát hành, phải kiểm tra cấu hình log đó và cập nhật đoạn này. Luật sư xem lại (mục 1 và 4).
- Nếu thêm analytics, crash report hoặc tài khoản thì phải viết lại đoạn này.

---

## Việc còn lại

1. PM duyệt nội dung và giọng văn trước khi đưa vào `content/` (quyền ghi của lượt này chỉ có `docs/research/`).
2. Luật sư xem lại mục 1 và 4 trước khi phát hành công khai.
3. Khi thêm bảng Viện Dinh dưỡng: cập nhật mục 2.
