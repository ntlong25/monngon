import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/providers.dart';
import 'state/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = SharedPrefsStore(await SharedPreferences.getInstance());
  await const StorageMigrator().migrate(store);
  runApp(
    ProviderScope(
      overrides: [storeProvider.overrideWithValue(store)],
      child: const FitProApp(),
    ),
  );
}
