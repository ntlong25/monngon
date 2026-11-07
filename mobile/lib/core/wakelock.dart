import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Giữ màn hình luôn sáng khi đang nấu (US-3.2 AC4). Tách thành interface để test thay thế được.
abstract interface class WakelockController {
  Future<void> enable();
  Future<void> disable();
}

class PluginWakelock implements WakelockController {
  const PluginWakelock();

  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } on Object {
      // Nền tảng không hỗ trợ: bỏ qua, không ảnh hưởng việc xem công thức.
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // như trên
    }
  }
}

final wakelockProvider = Provider<WakelockController>(
  (_) => const PluginWakelock(),
);

/// Bật wakelock khi widget vào cây, tắt khi rời đi (kể cả khi bị thay thế).
class KeepAwake extends ConsumerStatefulWidget {
  const KeepAwake({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<KeepAwake> createState() => _KeepAwakeState();
}

class _KeepAwakeState extends ConsumerState<KeepAwake> {
  late final WakelockController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(wakelockProvider);
    _controller.enable();
  }

  @override
  void dispose() {
    _controller.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
