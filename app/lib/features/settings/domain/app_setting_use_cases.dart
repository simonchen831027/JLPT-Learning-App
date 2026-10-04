import 'app_setting_repository.dart';
import 'app_settings.dart';

final class GetAppSettings {
  const GetAppSettings(this._repository);
  final AppSettingRepository _repository;

  Future<AppSettings> call() => _repository.getSettings();
}

final class SetShowFurigana {
  const SetShowFurigana(this._repository);
  final AppSettingRepository _repository;

  Future<void> call(bool enabled) => _repository.setShowFurigana(enabled);
}

final class SetFeedbackSound {
  const SetFeedbackSound(this._repository);
  final AppSettingRepository _repository;

  Future<void> call(bool enabled) => _repository.setFeedbackSound(enabled);
}
