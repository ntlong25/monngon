import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Cấu hình theo môi trường.
///
/// Đặt địa chỉ API khi chạy/build: `--dart-define=API_BASE_URL=https://api.example.com`.
/// Mặc định: Android emulator gọi máy chủ dev qua `10.0.2.2`, nền tảng khác dùng `localhost`.
abstract final class Env {
  static const _override = String.fromEnvironment('API_BASE_URL');

  /// Cổng mặc định của `MonNgon.Api` khi chạy `dotnet run` (xem backend/README.md).
  static const devPort = 5095;

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:$devPort';
    return 'http://localhost:$devPort';
  }
}
