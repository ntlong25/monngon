import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Kho khóa–giá trị chuỗi. Đọc đồng bộ (đã nạp sẵn), ghi bất đồng bộ.
abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Iterable<String> get keys;
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'fitpro.';

  @override
  String? read(String key) => _prefs.getString('$_prefix$key');

  @override
  Future<void> write(String key, String value) =>
      _prefs.setString('$_prefix$key', value);

  @override
  Future<void> delete(String key) => _prefs.remove('$_prefix$key');

  @override
  Iterable<String> get keys => _prefs
      .getKeys()
      .where((k) => k.startsWith(_prefix))
      .map((k) => k.substring(_prefix.length));
}

/// Kho trong bộ nhớ — dùng cho test.
class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, String>? initial]) : data = {...?initial};

  final Map<String, String> data;

  @override
  String? read(String key) => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);

  @override
  Iterable<String> get keys => data.keys;
}

/// Các khóa lưu trữ.
abstract final class StoreKeys {
  static const schemaVersion = 'schema_version';
  static const onboarding = 'onboarding';
  static const profile = 'profile';
  static const preferences = 'preferences';
  static const currentPlan = 'plan.current';
  static const savedPlans = 'plan.saved';
  static const shopping = 'shopping';
  static const cooked = 'cooked_steps';
  static const swapCount = 'swap_count';
  static const reference = 'cache.reference';
  /// Chỉ tiêu mỗi ngày đã tính gần nhất kèm hồ sơ dùng để tính (D-QA-09): tab Bạn đọc lại khi offline.
  static const targets = 'cache.targets';
  static const ingredientNames = 'ingredient_names';
  static const blockedNames = 'blocked_names';
}

/// Phiên bản schema lưu trữ hiện tại. Tăng khi đổi dạng dữ liệu và thêm [Migration] tương ứng.
const int kStorageSchemaVersion = 1;

/// Một bước nâng cấp dữ liệu đã lưu từ [from] lên `from + 1`. Chạy trên bản đọc thô của kho.
class Migration {
  const Migration({required this.from, required this.run});

  final int from;
  final Future<void> Function(KeyValueStore store) run;
}

/// Danh sách migration của app (hiện chưa có: v1 là bản đầu).
const List<Migration> kMigrations = [];

/// Kết quả [StorageMigrator.migrate].
enum MigrationOutcome { fresh, upToDate, migrated, resetFromFuture }

/// Đảm bảo dữ liệu trong kho khớp [kStorageSchemaVersion] trước khi provider đọc.
///
///  - Kho trống → đặt phiên bản hiện tại.
///  - Phiên bản cũ hơn → chạy lần lượt các migration.
///  - Phiên bản MỚI hơn app (hạ cấp app) → không đọc nổi, xoá dữ liệu app để tránh hỏng.
class StorageMigrator {
  const StorageMigrator({
    this.target = kStorageSchemaVersion,
    this.migrations = kMigrations,
  });

  final int target;
  final List<Migration> migrations;

  Future<MigrationOutcome> migrate(KeyValueStore store) async {
    final raw = store.read(StoreKeys.schemaVersion);
    final stored = int.tryParse(raw ?? '');
    if (raw == null) {
      final hasData = store.keys.any((k) => k != StoreKeys.schemaVersion);
      // Dữ liệu có sẵn nhưng chưa có phiên bản → coi là v0 để migration xử lý.
      if (hasData && target > 0 && migrations.any((m) => m.from == 0)) {
        return _runFrom(store, 0);
      }
      await store.write(StoreKeys.schemaVersion, '$target');
      return MigrationOutcome.fresh;
    }
    if (stored == null || stored > target) {
      await _wipe(store);
      await store.write(StoreKeys.schemaVersion, '$target');
      return MigrationOutcome.resetFromFuture;
    }
    if (stored == target) return MigrationOutcome.upToDate;
    return _runFrom(store, stored);
  }

  Future<MigrationOutcome> _runFrom(KeyValueStore store, int from) async {
    for (var v = from; v < target; v++) {
      final step = migrations.where((m) => m.from == v);
      if (step.isEmpty) {
        // Thiếu bước nâng cấp: an toàn nhất là bắt đầu lại.
        await _wipe(store);
        break;
      }
      await step.first.run(store);
      await store.write(StoreKeys.schemaVersion, '${v + 1}');
    }
    await store.write(StoreKeys.schemaVersion, '$target');
    return MigrationOutcome.migrated;
  }

  Future<void> _wipe(KeyValueStore store) async {
    for (final k in store.keys.toList()) {
      await store.delete(k);
    }
  }
}

/// Tiện ích đọc/ghi JSON an toàn: dữ liệu hỏng → trả null thay vì làm app lỗi.
extension JsonStore on KeyValueStore {
  Object? readJson(String key) {
    final s = read(key);
    if (s == null) return null;
    try {
      return jsonDecode(s);
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Object? value) =>
      write(key, jsonEncode(value));
}
