# FitPro - Mâm đủ — app Flutter (`mobile/`)

Ứng dụng di động (Android + iOS) lên thực đơn tuần theo protein/kcal và ngân sách. Gọi API `backend/` (ASP.NET Core); không có logic engine trong app.

## Yêu cầu

- Flutter stable ≥ 3.47 (Dart ≥ 3.13). Trên máy này: `C:\Users\PC\flutter\bin` (đã có trong PATH người dùng).
- Android SDK + emulator `Pixel_7` (hoặc thiết bị thật). iOS cần macOS.
- Python 3 (chỉ để sinh lại client Dart / chụp fixture).
- Backend đang chạy: `dotnet run --project backend/MonNgon.Api` (cổng 5095).

## Chạy

```bash
cd mobile
flutter pub get
flutter run -d emulator-5554        # Android emulator: tự gọi http://10.0.2.2:5095
```

Địa chỉ API theo môi trường — mặc định: Android emulator `http://10.0.2.2:5095`, nền tảng khác `http://localhost:5095`. Ghi đè:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5095     # điện thoại thật cùng Wi-Fi
flutter build apk --dart-define=API_BASE_URL=https://api.example.com
```

Bản **debug** cho phép HTTP thường (`usesCleartextTraffic` chỉ ở `android/app/src/debug`); bản release bắt buộc HTTPS.

## Cài APK chạy được lên emulator (kiểm tay, T-095)

Dùng bản **profile** (AOT, ~41 MB, mở tay không kẹt splash): bản debug x64 nặng ~200 MB và emulator ít bộ nhớ báo `INSTALL_FAILED_INSUFFICIENT_STORAGE`; bản release bắt buộc HTTPS. Manifest profile cho phép HTTP tới API dev (`android/app/src/profile`).

```bash
# 1. API dev (cần cho tuần mới/đổi món): dotnet run --project backend/MonNgon.Api --no-launch-profile --urls http://0.0.0.0:5097
# 2. Build + cài (emulator trỏ máy host qua 10.0.2.2)
cd mobile
flutter build apk --profile --target-platform android-x64 --dart-define=API_BASE_URL=http://10.0.2.2:5097
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-profile.apk
adb -s emulator-5554 shell monkey -p vn.fitpro.fitpro_mamdu -c android.intent.category.LAUNCHER 1   # hoặc bấm biểu tượng FitPro
```

- Kiểm offline: bật chế độ máy bay trên emulator sau khi đã tạo tuần (dữ liệu lưu trên máy). Cỡ chữ 1.3: Settings → Display → Font size / Display size.
- Đổi cổng API: build lại với `--dart-define=API_BASE_URL=http://10.0.2.2:<cổng>`.
- Nếu `INSTALL_FAILED_INSUFFICIENT_STORAGE`: gỡ bản cũ (`adb uninstall vn.fitpro.fitpro_mamdu`) rồi cài lại.

## Integration test (emulator + API thật)

Luồng chính: xóa dữ liệu → onboarding 13 bước (hồ sơ p01) → tạo tuần → 7 ngày/mâm có tráng miệng → công thức "Cách chúng mình tính" khớp chip → đổi món + Hoàn tác → ăn ngoài + Hoàn tác → Đi chợ (gạo sống, không cơm chín) → Xóa dữ liệu. Ảnh từng bước lưu vào `docs/dev/screens/it-*.png`.

```bash
# 1) API riêng (không đè launchSettings), cổng 5096
dotnet run --project backend/MonNgon.Api --no-launch-profile --urls http://0.0.0.0:5096
# 2) trong mobile/ (cần `adb` trong PATH): chạy test + chụp ảnh từng bước vào docs/dev/screens/it-*.png
tool/run_integration.sh                      # mặc định emulator-5554, http://10.0.2.2:5096
tool/run_integration.sh <device-id> <api-url>
# hoặc chỉ chạy test, không chụp ảnh:
flutter test integration_test/main_flow_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5096
```

Ghi chú:
- Dùng `flutter test`, không dùng `flutter drive`: trên emulator này `flutter drive` đứng ở màn splash ("Flutter Driver extension is taking a long time"). Ảnh được chụp bằng `adb screencap` mỗi khi test in dòng `[it] ảnh: <tên>`.
- Lệnh cài lại app trên thiết bị (xóa dữ liệu app), đừng chạy khi người khác đang thao tác tay trên cùng emulator. Mất ~3,5 phút.
- Emulator ít RAM đôi khi đứng hình giữa chừng (xem `docs/dev/l09-tab-ban-emulator.md`): test quá 10 phút sẽ tự báo lỗi; chạy lại là được (script đã dọn tiến trình nền trước khi chạy).

## Kiểm tra

```bash
flutter analyze        # phải sạch (flutter_lints + strict-casts/inference/raw-types)
flutter test           # unit + widget + test hợp đồng API
```

## Cấu trúc

```
lib/
  main.dart, app.dart, router.dart      # go_router, StatefulShellRoute 3 tab
  config/env.dart                       # base URL theo môi trường
  api/
    api_providers.dart                  # Riverpod: dio, MonNgonApi, healthProvider
    generated/                          # SINH TỰ ĐỘNG, không sửa tay
      models.dart                       # 49 schema OpenAPI → lớp Dart bất biến (fromJson/toJson)
      api_client.dart                   # MonNgonApi (Dio) + ApiException
  features/{shell,plan,shopping,profile}/
  l10n/app_vi.arb                       # chuỗi UI (tiếng Việt); l10n/gen/ là mã sinh
tool/
  gen_client.py                         # openapi.json → lib/api/generated
  capture_fixtures.py                   # chụp phản hồi thật của API → test/fixtures
test/
  api/contract_test.dart                # client khớp openapi.json + đọc được phản hồi thật
  fixtures/                             # JSON chụp từ API thật (p01, seed 1)
```

## Sinh lại client API

Mỗi khi `backend/openapi/openapi.json` đổi (test API tự ghi lại file này):

```bash
python mobile/tool/gen_client.py
dart format mobile/lib/api
cd mobile && flutter test test/api/contract_test.dart      # báo lỗi nếu client lỗi thời
```

Chụp lại fixture từ API đang chạy: `python mobile/tool/capture_fixtures.py`.

### Vì sao không dùng openapi-generator / freezed

Máy dev không có sẵn Java + jar openapi-generator, và `freezed`/`json_serializable` cần `build_runner`. Bộ sinh nhỏ `tool/gen_client.py` (≈300 dòng, chỉ cần Python) sinh trực tiếp model thuần Dart + client Dio, đọc lỏng (trường thiếu → mặc định), không có bước build_runner. Hợp đồng được giữ bằng `test/api/contract_test.dart`: mọi schema/operation/thuộc tính trong `openapi.json` phải có trong mã sinh, và phản hồi thật của API (fixture) phải đọc được và ghi lại đúng.

## Quy ước

- Không hard-code chuỗi trong widget: dùng `AppL10n.of(context)` (ARB `vi`).
- Mọi gọi mạng đi qua `MonNgonApi`; lỗi là `ApiException` (`isNetwork` khi mất mạng, `fieldErrors` khi 400).
- Test widget dùng `test/support/fake_adapter.dart` (Dio adapter giả), không gọi mạng thật.
