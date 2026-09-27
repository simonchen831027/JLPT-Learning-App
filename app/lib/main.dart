import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/database/sqlite_local_store.dart';
import 'features/home/data/local_startup_repository.dart';
import 'features/home/domain/initialize_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = SqliteLocalStore.platform();
  final repository = LocalStartupRepository(store);
  runApp(JlptLearningApp(initializeApp: InitializeApp(repository)));
}
