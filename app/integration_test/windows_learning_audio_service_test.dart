import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jlpt_learning_app/core/audio/learning_audio_service.dart';
import 'package:jlpt_learning_app/core/audio/windows_learning_audio_service.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/domain/learning_audio_use_cases.dart';

// 需 Windows 與已安裝日語 voice；不加入一般跨平台 Unit CI。
// accepted 不是可聽見／播放完畢的證據。離線須由 Developer 手動斷網執行。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Windows production channel accepts canonical readings and replacement',
    (tester) async {
      const service = WindowsLearningAudioService();
      final play = PlayLearningAudio(service);
      for (var round = 0; round < 6; round++) {
        expect(
          await service.getCapability(),
          LearningAudioCapability.available,
        );
        for (final (surface, pronunciation) in [
          ('日本語', 'にほんご'),
          ('今日', 'きょう'),
          ('食べる', 'たべる'),
        ]) {
          expect(
            await play(
              ReadingText(
                id: 'fixture',
                surface: surface,
                segments: [
                  ReadingSegment(
                    id: 'segment',
                    ordinal: 0,
                    surface: surface,
                    reading: pronunciation,
                  ),
                ],
              ),
            ),
            LearningAudioResult.accepted,
          );
        }
      }
      // 同時到達的 method 也各自完成，並以 replacement 維持單一 playback。
      expect(
        await Future.wait([
          service.play(const LearningAudioRequest(text: 'にほんご')),
          service.play(const LearningAudioRequest(text: 'きょう')),
          service.play(const LearningAudioRequest(text: 'たべる')),
        ]),
        everyElement(LearningAudioResult.accepted),
      );
    },
    skip: !Platform.isWindows,
  );

  testWidgets(
    'Windows rejects protocol defects without disguising provider failure',
    (tester) async {
      const channel = MethodChannel('jlpt_learning_app/learning_audio');
      for (final payload in <Object?>[
        null,
        'にほんご',
        {'text': 123, 'languageTag': 'ja-JP'},
        {'text': 'にほんご', 'languageTag': 'en-US'},
        {'text': '', 'languageTag': 'ja-JP'},
      ]) {
        await expectLater(
          channel.invokeMethod<Object?>('play', payload),
          throwsA(
            isA<PlatformException>().having(
              (error) => error.code,
              'code',
              'invalid_arguments',
            ),
          ),
        );
      }
      await expectLater(
        channel.invokeMethod<Object?>('getCapability', 'unexpected'),
        throwsA(isA<PlatformException>()),
      );
      await expectLater(
        channel.invokeMethod<Object?>('notAnAudioOperation'),
        throwsA(isA<MissingPluginException>()),
      );
      expect(
        await const WindowsLearningAudioService().getCapability(),
        LearningAudioCapability.available,
      );
    },
    skip: !Platform.isWindows,
  );
}
