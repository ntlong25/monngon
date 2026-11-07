import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageMigrator', () {
    test('kho trống → đặt phiên bản hiện tại', () async {
      final s = MemoryStore();
      expect(await const StorageMigrator().migrate(s), MigrationOutcome.fresh);
      expect(s.read(StoreKeys.schemaVersion), '$kStorageSchemaVersion');
    });

    test('đúng phiên bản → giữ nguyên dữ liệu', () async {
      final s = MemoryStore({
        StoreKeys.schemaVersion: '$kStorageSchemaVersion',
        StoreKeys.swapCount: '3',
      });
      expect(
        await const StorageMigrator().migrate(s),
        MigrationOutcome.upToDate,
      );
      expect(s.read(StoreKeys.swapCount), '3');
    });

    test('phiên bản cũ → chạy lần lượt từng migration', () async {
      final order = <int>[];
      final s = MemoryStore({
        StoreKeys.schemaVersion: '1',
        StoreKeys.swapCount: '2',
      });
      final m = StorageMigrator(
        target: 3,
        migrations: [
          Migration(
            from: 1,
            run: (st) async {
              order.add(1);
              await st.write('renamed', st.read(StoreKeys.swapCount)!);
            },
          ),
          Migration(from: 2, run: (st) async => order.add(2)),
        ],
      );
      expect(await m.migrate(s), MigrationOutcome.migrated);
      expect(order, [1, 2]);
      expect(s.read('renamed'), '2');
      expect(s.read(StoreKeys.schemaVersion), '3');
    });

    test('dữ liệu cũ chưa có phiên bản được coi là v0', () async {
      var ran = false;
      final s = MemoryStore({'profile': '{}'});
      final m = StorageMigrator(
        target: 1,
        migrations: [Migration(from: 0, run: (_) async => ran = true)],
      );
      expect(await m.migrate(s), MigrationOutcome.migrated);
      expect(ran, isTrue);
      expect(s.read(StoreKeys.schemaVersion), '1');
    });

    test('phiên bản mới hơn app (hạ cấp) → xoá dữ liệu để khỏi hỏng', () async {
      final s = MemoryStore({
        StoreKeys.schemaVersion: '99',
        StoreKeys.profile: '{"x":1}',
      });
      expect(
        await const StorageMigrator().migrate(s),
        MigrationOutcome.resetFromFuture,
      );
      expect(s.read(StoreKeys.profile), isNull);
      expect(s.read(StoreKeys.schemaVersion), '$kStorageSchemaVersion');
    });

    test('thiếu bước migration → bắt đầu lại, không ném lỗi', () async {
      final s = MemoryStore({
        StoreKeys.schemaVersion: '1',
        StoreKeys.profile: '{}',
      });
      final m = StorageMigrator(target: 3, migrations: const []);
      expect(await m.migrate(s), MigrationOutcome.migrated);
      expect(s.read(StoreKeys.profile), isNull);
      expect(s.read(StoreKeys.schemaVersion), '3');
    });
  });

  group('JsonStore', () {
    test('JSON hỏng → null, không ném lỗi', () {
      final s = MemoryStore({'k': '{không phải json'});
      expect(s.readJson('k'), isNull);
    });

    test('ghi rồi đọc lại', () async {
      final s = MemoryStore();
      await s.writeJson('k', {
        'a': [1, 2],
      });
      expect(s.readJson('k'), {
        'a': [1, 2],
      });
    });
  });

  group('SharedPrefsStore', () {
    test('ghi/đọc/xoá và liệt kê khóa, chỉ thấy khóa của app', () async {
      SharedPreferences.setMockInitialValues({'other': 'x'});
      final store = SharedPrefsStore(await SharedPreferences.getInstance());
      await store.write('a', '1');
      await store.write('b', '2');
      expect(store.read('a'), '1');
      expect(store.keys.toSet(), {'a', 'b'});
      await store.delete('a');
      expect(store.read('a'), isNull);
    });

    test(
      'tắt rồi mở lại (đọc lại SharedPreferences) vẫn còn dữ liệu',
      () async {
        SharedPreferences.setMockInitialValues({});
        final first = SharedPrefsStore(await SharedPreferences.getInstance());
        await first.write('profile', '{"age":40}');
        final second = SharedPrefsStore(await SharedPreferences.getInstance());
        expect(second.read('profile'), '{"age":40}');
      },
    );
  });
}
