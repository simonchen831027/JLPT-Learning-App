/// 日語教材發音請求；text 由 Application 使用 canonical reading 建立。
final class LearningAudioRequest {
  const LearningAudioRequest({required this.text});

  final String text;
  String get languageTag => 'ja-JP';
}

/// 執行時語音能力，與 Content availability、Furigana 偏好分開。
enum LearningAudioCapability { available, unavailable, disabled, failed }

/// accepted 僅表示服務接受請求，不代表朗讀或學習已完成。
enum LearningAudioResult { accepted, unavailable, disabled, failed }

/// Provider-independent 邊界；未來 adapter 須將預期 provider 失敗轉成
/// failed，不向呼叫端暴露 native types、provider exception 或敏感診斷。
/// 非預期程式錯誤不屬於可恢復的 Audio outcome。
abstract interface class LearningAudioService {
  Future<LearningAudioCapability> getCapability();

  /// Capability 查詢後可能改變；play 仍須回報當下的 typed outcome。
  Future<LearningAudioResult> play(LearningAudioRequest request);
}
