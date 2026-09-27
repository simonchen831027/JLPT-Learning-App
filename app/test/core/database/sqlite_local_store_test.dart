import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';

void main() {
  sqfliteFfiInit();

  test(
    'concurrent startup shares one open and close permits reopening',
    () async {
      final pending = Completer<Database>();
      var calls = 0;
      final store = SqliteLocalStore(
        openDatabase: () {
          calls++;
          return pending.future;
        },
      );
      final first = store.initialize();
      final second = store.initialize();
      expect(calls, 1);
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      pending.complete(database);
      await Future.wait([first, second]);
      await store.close();
      expect(database.isOpen, isFalse);
    },
  );

  test(
    'failed opening is not cached and the next attempt can recover',
    () async {
      var calls = 0;
      final store = SqliteLocalStore(
        openDatabase: () async {
          calls++;
          if (calls == 1) throw StateError('test failure');
          return databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
        },
      );
      addTearDown(store.close);
      await expectLater(store.initialize(), throwsStateError);
      await store.initialize();
      expect(calls, 2);
      await store.close();
      await store.initialize();
      expect(calls, 3);
    },
  );
}
