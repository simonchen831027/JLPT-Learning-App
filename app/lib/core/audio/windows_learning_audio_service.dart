import 'package:flutter/services.dart';

import 'learning_audio_service.dart';

/// Windows production adapter；channel 與 codec 僅為私有傳輸協定。
/// 預期 OS 失敗由原生端回傳 typed outcome；接線／協定錯誤繼續拋出。
final class WindowsLearningAudioService implements LearningAudioService {
  const WindowsLearningAudioService();

  static const _channel = MethodChannel('jlpt_learning_app/learning_audio');

  @override
  Future<LearningAudioCapability> getCapability() async {
    final response = await _channel.invokeMethod<Object?>('getCapability');
    return switch (response) {
      'available' => LearningAudioCapability.available,
      'unavailable' => LearningAudioCapability.unavailable,
      'disabled' => LearningAudioCapability.disabled,
      'failed' => LearningAudioCapability.failed,
      _ => throw StateError('Invalid Learning Audio capability response.'),
    };
  }

  @override
  Future<LearningAudioResult> play(LearningAudioRequest request) async {
    final response = await _channel.invokeMethod<Object?>('play', {
      'text': request.text,
      'languageTag': request.languageTag,
    });
    return switch (response) {
      'accepted' => LearningAudioResult.accepted,
      'unavailable' => LearningAudioResult.unavailable,
      'disabled' => LearningAudioResult.disabled,
      'failed' => LearningAudioResult.failed,
      _ => throw StateError('Invalid Learning Audio playback response.'),
    };
  }
}
