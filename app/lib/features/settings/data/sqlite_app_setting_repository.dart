import 'package:sqflite_common/sqlite_api.dart';

import '../domain/app_setting_repository.dart';
import '../domain/app_settings.dart';

final class SqliteAppSettingRepository implements AppSettingRepository {
  const SqliteAppSettingRepository(this._database);
  final Database _database;

  @override
  Future<AppSettings> getSettings() async {
    final rows = await _database.query(
      'app_settings',
      columns: ['show_furigana', 'feedback_sound'],
      where: 'singleton = ?',
      whereArgs: [1],
    );
    if (rows.length != 1) throw StateError('App settings row is missing.');
    final row = rows.single;
    return AppSettings(
      showFurigana: row['show_furigana'] == 1,
      feedbackSound: row['feedback_sound'] == 1,
    );
  }

  @override
  Future<void> setShowFurigana(bool enabled) =>
      _setPreference('show_furigana', enabled);

  @override
  Future<void> setFeedbackSound(bool enabled) =>
      _setPreference('feedback_sound', enabled);

  Future<void> _setPreference(String column, bool enabled) async {
    // 僅更新指定欄位，避免以舊 snapshot 覆寫另一個偏好。
    final updated = await _database.update(
      'app_settings',
      {column: enabled ? 1 : 0},
      where: 'singleton = ?',
      whereArgs: [1],
    );
    if (updated != 1) throw StateError('App settings row is missing.');
  }
}
