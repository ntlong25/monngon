import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Adapter Dio giả cho test: trả JSON đã đăng ký theo (method, đường dẫn).
class FakeAdapter implements HttpClientAdapter {
  final _routes = <String, (Object?, int)>{};
  final requests = <RequestOptions>[];

  /// Nếu true, mọi yêu cầu lỗi kết nối (giả lập mất mạng).
  bool failWithConnectionError = false;

  /// Độ trễ giả cho mỗi phản hồi (kiểm thử trạng thái đang tải).
  Duration delay = Duration.zero;

  void on(String method, String path, Object? json, {int status = 200}) {
    _routes['$method $path'] = (json, status);
  }

  final _dynamic = <String, Object? Function(RequestOptions)>{};

  /// Phản hồi tính theo nội dung yêu cầu (ví dụ: dạng rút gọn khác dạng đầy đủ). Ưu tiên hơn [on].
  void onRequest(
    String method,
    String path,
    Object? Function(RequestOptions options) build,
  ) {
    _dynamic['$method $path'] = build;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (failWithConnectionError) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final key = '${options.method} ${options.uri.path}';
    final build = _dynamic[key];
    if (build != null) {
      return ResponseBody.fromString(
        jsonEncode(build(options)),
        200,
        headers: _h,
      );
    }
    final route = _routes[key];
    if (route == null) {
      return ResponseBody.fromString('{"title":"not found"}', 404, headers: _h);
    }
    return ResponseBody.fromString(jsonEncode(route.$1), route.$2, headers: _h);
  }

  static const _h = {
    Headers.contentTypeHeader: ['application/json'],
  };

  @override
  void close({bool force = false}) {}
}
