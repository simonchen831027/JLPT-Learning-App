import 'app_settings.dart';

abstract interface class AppSettingRepository {
  Future<AppSettings> getSettings();
  Future<void> setShowFurigana(bool enabled);
  Future<void> setFeedbackSound(bool enabled);
}
