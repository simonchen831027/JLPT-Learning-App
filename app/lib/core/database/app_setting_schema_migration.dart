import 'schema_migration.dart';

final appSettingSchemaMigration = SchemaMigration(
  version: 4,
  name: 'phase_1_app_settings',
  statements: [
    // singleton 是內部儲存位置，不是 learner / Content Entity ID。
    '''CREATE TABLE app_settings (
      singleton INTEGER PRIMARY KEY NOT NULL CHECK (singleton = 1),
      show_furigana INTEGER NOT NULL DEFAULT 1 CHECK (show_furigana IN (0, 1)),
      feedback_sound INTEGER NOT NULL DEFAULT 1 CHECK (feedback_sound IN (0, 1))
    )''',
    'INSERT INTO app_settings (singleton) VALUES (1)',
  ],
);
