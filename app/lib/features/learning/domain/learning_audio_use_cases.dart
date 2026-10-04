import '../../../core/audio/learning_audio_service.dart';
import '../../content/domain/content_models.dart';

final class GetLearningAudioCapability {
  const GetLearningAudioCapability(this._service);
  final LearningAudioService _service;

  Future<LearningAudioCapability> call() => _service.getCapability();
}

final class PlayLearningAudio {
  const PlayLearningAudio(this._service);
  final LearningAudioService _service;
  static final _han = RegExp(r'\p{Script=Han}', unicode: true);

  Future<LearningAudioResult> call(ReadingText reading) async {
    reading.validate();
    final request = LearningAudioRequest(
      text: reading.segments.map(_pronunciation).join(),
    );

    switch (await _service.getCapability()) {
      case LearningAudioCapability.unavailable:
        return LearningAudioResult.unavailable;
      case LearningAudioCapability.disabled:
        return LearningAudioResult.disabled;
      case LearningAudioCapability.failed:
        return LearningAudioResult.failed;
      case LearningAudioCapability.available:
        return _service.play(request);
    }
  }

  static String _pronunciation(ReadingSegment segment) {
    final canonicalReading = segment.reading;
    if (canonicalReading != null) return canonicalReading;
    // 含 Han 的 surface 不可交給 TTS 猜讀音；只限制 Audio input，
    // 不改變 Content 的 canonical ReadingText contract。
    if (_han.hasMatch(segment.surface)) {
      throw ArgumentError('Canonical reading is required for Han text.');
    }
    return segment.surface;
  }
}
