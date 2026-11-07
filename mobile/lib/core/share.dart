import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Chia sẻ văn bản qua share sheet của hệ điều hành (US-4.1 AC5). Tách thành interface để test thay thế được.
abstract interface class ShareController {
  Future<void> shareText(String text, {String? subject});
}

class PluginShare implements ShareController {
  const PluginShare();

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}

final shareProvider = Provider<ShareController>((_) => const PluginShare());
