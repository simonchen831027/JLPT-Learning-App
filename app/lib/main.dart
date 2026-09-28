import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/database/sqlite_local_store.dart';
import 'core/identity/entity_id_generator.dart';
import 'features/content/data/b0_content_package.dart';
import 'features/content/data/sqlite_content_repository.dart';
import 'features/home/data/local_startup_repository.dart';
import 'features/home/domain/initialize_app.dart';
import 'features/learning/data/sqlite_n5_lesson_repository.dart';
import 'features/learning/domain/n5_lesson_use_cases.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = SqliteLocalStore.platform();
  Future<SqliteContentRepository> openContent() async =>
      SqliteContentRepository(await store.database);
  final repository = LocalStartupRepository(
    store,
    afterInitialize: () async =>
        B0ContentPackage(const EntityIdGenerator())
            .install(await openContent()),
  );
  final lessons = SqliteN5LessonRepository(openContent);
  runApp(
    JlptLearningApp(
      initializeApp: InitializeApp(repository),
      listN5Lessons: ListN5Lessons(lessons),
      getN5Lesson: GetN5Lesson(lessons),
    ),
  );
}
