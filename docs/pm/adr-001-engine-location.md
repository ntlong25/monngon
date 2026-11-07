# ADR-001 — Engine lập thực đơn chạy ở đâu?

- **Trạng thái:** **Đã chấp nhận** (người dùng duyệt 2026-11-06) · **Ngày:** 2026-11-06
- **Liên quan:** PRD §6, §10 "Quyết định" (Q2, Q8) · backlog v0.2

## Bối cảnh

- Người dùng chốt stack: **Flutter cho mobile**, sau đó **web bằng ReactJS** (Q2).
- Engine hiện có viết bằng **TypeScript thuần** (`src/engine/`, khoảng 1.300 dòng không tính test). Engine dựa trên luật, tất định theo seed (mulberry32), **không dùng LLM**. Hiện trạng: 166 test xanh. Theo `docs/dev/engine-report-final.md`, 12/14 hồ sơ test đạt 7/7 ngày và 0 vi phạm ràng buộc cứng. Hai hồ sơ chỉ đạt một phần (p09 chỉ có lò vi sóng, p14) **do thiếu món trong dữ liệu**, không phải lỗi engine.
- Flutter (Dart) không chạy được TypeScript. Nhúng JS engine vào Flutter thì nặng, khó debug, không đáng.
- Người dùng là **dev backend .NET**: họ sẽ tự bảo trì phần lõi lâu dài.
- Freemium (Q7) cần kiểm soát quyền lợi (số lần đổi món, đi chợ theo cửa hàng…). Kiểm soát ở phía máy khách thì dễ bị vượt, nên sớm muộn cũng cần backend.
- Dữ liệu dinh dưỡng, giá và công thức sẽ cập nhật thường xuyên (giá theo tuần). Phát hành lại app chỉ để đổi dữ liệu là chậm (duyệt store).

## Các phương án

| Tiêu chí | (a) Port sang **C#/.NET**, làm API | (b) Port sang **Dart**, chạy offline trên máy | (c) Giữ **TS**, chạy trên **Node** backend |
|---|---|---|---|
| Người dùng tự bảo trì | **Tốt nhất**: đúng chuyên môn | Phải học Dart sâu cho phần thuật toán | Được, nhưng không phải thế mạnh; thêm một runtime để vận hành |
| Dùng chung cho web ReactJS | **Có**: cùng API | **Không**: web phải port lần nữa sang TS hoặc gọi Dart compile-to-JS | Có |
| Công port | Trung bình (~1.300 dòng + test); C# và TS gần nhau về cú pháp/kiểu | Trung bình | **Không cần port** |
| Cập nhật dữ liệu/giá không cần phát hành app | **Có** | Không: phải bundle hoặc tự viết cơ chế tải dữ liệu | Có |
| Kiểm soát freemium/quyền lợi | **Có** (server) | Yếu (máy khách) | Có |
| Chạy offline | Không: cần mạng khi tạo/đổi tuần (xem đã tạo thì cache được) | **Có** | Không |
| Chi phí vận hành | Cần host (container nhỏ; engine ~30 ms/tuần nên tải thấp) | Không | Cần host |
| Đường tới LLM v2/v3 | Tốt: gọi LLM ở server, khóa API không nằm trong app | Khó: không để khóa API trong app được, vẫn phải có backend | Tốt |
| Rủi ro | Lệch kết quả khi port (làm tròn, sort, RNG) → giảm bằng golden test | Như (a), cộng thêm rủi ro làm hai lần cho web | Hai ngôn ngữ backend nếu sau này người dùng thêm dịch vụ .NET |

## Quyết định

**Chọn (a): port engine sang C#/.NET (ASP.NET Core, .NET 10 LTS), làm API stateless cho Flutter và sau này cho web ReactJS.**

Lý do chính:
1. Người dùng tự bảo trì được phần quan trọng nhất của sản phẩm bằng đúng chuyên môn của họ.
2. Một engine, hai frontend: web ReactJS dùng lại nguyên API.
3. Freemium và LLM (v2/v3) đằng nào cũng cần server. Làm backend ngay từ đầu thì không phải dời engine thêm lần nữa.
4. Dữ liệu giá/công thức cập nhật ở server, không phụ thuộc chu kỳ duyệt store.

(c) rẻ nhất trước mắt nhưng đặt lõi sản phẩm vào runtime người dùng không chuyên. (b) chỉ thắng ở offline. Offline không phải yêu cầu cốt lõi: app là planner, người dùng tạo tuần 1 lần/tuần và xem lại từ bộ nhớ đệm.

## Hệ quả và cách làm

- **TS engine thành bản tham chiếu (reference) và bị đóng băng** sau khi làm xong hai việc: (1) đổi dải calo thành ±5% (Q3), (2) xuất bộ **golden output**, gồm mọi hồ sơ test × một số seed, kết quả `WeekPlan` + danh sách đi chợ + chỉ tiêu dạng JSON. Bản C# phải khớp golden: cùng món, cùng gram; macro sai số ≤ 1e-6. Tính năng mới (ghép mâm, đổi món…) **chỉ làm ở C#** sau khi khớp.
- **Bẫy khi port**, ghi rõ trong task:
  - `Math.round` của JS làm tròn .5 lên +∞. `Math.Round` của C# mặc định làm tròn kiểu ngân hàng, nên phải dùng `Math.Floor(x + 0.5)` hoặc `MidpointRounding.AwayFromZero` và kiểm cả số âm.
  - `Array.prototype.sort` của JS ổn định; `List<T>.Sort` của C# không ổn định, nên dùng `OrderBy`/`ThenBy`.
  - mulberry32 dùng phép 32-bit không dấu (`>>> 0`, `Math.imul`), nên port bằng `uint` + `unchecked`.
  - Thứ tự duyệt `Object.keys`/`Map` trong JS theo thứ tự chèn; `Dictionary` của C# không bảo đảm thứ tự, nên dùng list có thứ tự khi thứ tự ảnh hưởng kết quả.
- **API stateless cho MVP:** máy khách gửi hồ sơ/lựa chọn và nhận tuần; trạng thái người dùng lưu trên máy (Flutter). Khi bật freemium (T-029) thì thêm tài khoản + lưu tuần ở server.
- **Offline:** Flutter cache tuần hiện tại, công thức đã tải và danh sách đi chợ. Khi mất mạng vẫn xem/nấu/đánh dấu đi chợ được; chỉ tạo/đổi tuần là cần mạng.
- **Hợp đồng API** công bố bằng OpenAPI, sinh client Dart (Flutter) và TypeScript (web sau này) tự động.
- Phép tính chỉ tiêu (mục 4.8) đơn giản và cần hiện ngay khi gõ ở onboarding, nên **có thể** viết thêm bản Dart dùng chung bộ vector test với C#. Nếu vậy thì server vẫn là chuẩn.

## Trả lời câu hỏi Q8 của người dùng

> "Tôi là dev backend .net, có thể xử lý chọn món ăn không? Hay dùng LLM?"

**Có, chọn món xử lý hoàn toàn bằng thuật toán, không cần LLM.** Engine hiện tại đã làm việc này: lọc cứng (dị ứng, kiêng, dụng cụ), chấm điểm mềm (khẩu vị, chi phí, chống lặp), scale gram để khớp protein/calo, rồi validator kiểm từng ngày và ngân sách. Kết quả tất định, kiểm thử được, chi phí gần bằng 0 và không bao giờ "bịa" số dinh dưỡng. Người dùng sẽ bảo trì nó bằng C#.

**LLM để v2/v3**, dùng cho việc thuật toán làm kém:
- gợi ý và soạn nháp công thức mới (người duyệt lại; số dinh dưỡng vẫn tính từ bảng, LLM không sinh số);
- phân tích khẩu vị từ hành vi (món hay đổi, món bị chặn) để chỉnh trọng số mềm;
- trả lời câu hỏi tự do ("tuần này đổi sang món miền Nam được không?") bằng cách chuyển thành lựa chọn có cấu trúc cho engine.

LLM luôn gọi từ backend .NET, không để khóa API trong app.
