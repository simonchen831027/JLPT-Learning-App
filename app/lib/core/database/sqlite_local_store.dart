import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'local_store.dart';
import 'migration_runner.dart';
import 'migrations.dart';

class SqliteLocalStore implements LocalStore {
  SqliteLocalStore({required this.openDatabase});

  factory SqliteLocalStore.platform() {
    return SqliteLocalStore(
      openDatabase: () async {
        final DatabaseFactory factory;
        if (Platform.isWindows) {
          sqfliteFfiInit();
          factory = databaseFactoryFfi;
        } else if (Platform.isAndroid || Platform.isIOS) {
          factory = mobile.databaseFactory;
        } else {
          throw UnsupportedError('Unsupported application platform.');
        }
        final directory = await getApplicationSupportDirectory();
        await directory.create(recursive: true);
        return MigrationRunner(appMigrations)
            .open(factory, path.join(directory.path, 'jlpt_learning.sqlite3'));
      },
    );
  }

  final Future<Database> Function() openDatabase;
  Future<Database>? _opening;

  @override
  Future<void> initialize() async {
    final opening = _opening ??= openDatabase();
    try {
      await opening;
    } catch (_) {
      if (identical(_opening, opening)) _opening = null;
      rethrow;
    }
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) {
      final database = await opening;
      await database.close();
    }
  }
}
