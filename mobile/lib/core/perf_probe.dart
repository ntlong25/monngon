import 'dart:developer' as developer;
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/widgets.dart';

/// Đo thời gian mở tab (T-092, mục tiêu ≤ 300 ms). Chỉ bật khi build với `--dart-define=PERF_PROBE=true`;
/// mặc định tắt và không tốn gì.
///
/// Mỗi lần đổi tab in ra logcat một dòng: `PERF tab=<chỉ số> tap_to_pixels=<ms> build=<ms> raster=<ms>`,
/// trong đó `tap_to_pixels` là từ lúc bấm tab tới khi khung hình đầu tiên vẽ xong.
abstract final class PerfProbe {
  static const enabled = bool.fromEnvironment('PERF_PROBE');

  static int? _tab;
  static int _markMicros = 0;
  static bool _installed = false;

  static void markTab(int index) {
    if (!enabled) return;
    if (!_installed) {
      _installed = true;
      WidgetsBinding.instance.addTimingsCallback(_onTimings);
    }
    _tab = index;
    _markMicros = developer.Timeline.now;
  }

  static void _onTimings(List<FrameTiming> timings) {
    final tab = _tab;
    if (tab == null) return;
    for (final t in timings) {
      if (t.timestampInMicroseconds(FramePhase.buildStart) < _markMicros) {
        continue;
      }
      final done = t.timestampInMicroseconds(FramePhase.rasterFinish);
      debugPrint(
        'PERF tab=$tab '
        'tap_to_pixels=${((done - _markMicros) / 1000).toStringAsFixed(1)}ms '
        'build=${t.buildDuration.inMicroseconds / 1000}ms '
        'raster=${t.rasterDuration.inMicroseconds / 1000}ms',
      );
      _tab = null;
      return;
    }
  }
}
