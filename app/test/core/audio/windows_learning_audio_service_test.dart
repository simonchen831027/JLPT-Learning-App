import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/audio/learning_audio_service.dart';
import 'package:jlpt_learning_app/core/audio/windows_learning_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('jlpt_learning_app/learning_audio');
  const service = WindowsLearningAudioService();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final capability in LearningAudioCapability.values) {
    test('capability maps ${capability.name}', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getCapability');
        expect(call.arguments, isNull);
        return capability.name;
      });
      expect(await service.getCapability(), capability);
    });
  }

  for (final outcome in LearningAudioResult.values) {
    test('play maps ${outcome.name} and preserves pronunciation', () async {
      const text = 'きょう、にほんごを\nたべる。 カタカナ';
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'play');
        expect(call.arguments, {'text': text, 'languageTag': 'ja-JP'});
        return outcome.name;
      });
      expect(
        await service.play(const LearningAudioRequest(text: text)),
        outcome,
      );
    });
  }

  for (final method in ['getCapability', 'play']) {
    Future<Object> invoke() => method == 'getCapability'
        ? service.getCapability()
        : service.play(const LearningAudioRequest(text: 'きょう'));

    for (final response in <Object?>[
      null,
      1,
      true,
      <String>[],
      {'status': 'failed'},
      'unknown',
      method == 'play' ? 'available' : 'accepted',
    ]) {
      test('$method rejects malformed or impossible $response', () async {
        messenger.setMockMethodCallHandler(channel, (_) async => response);
        await expectLater(invoke(), throwsStateError);
      });
    }

    test('$method preserves missing native registration error', () async {
      await expectLater(invoke(), throwsA(isA<MissingPluginException>()));
    });

    test('$method preserves native protocol error', () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'invalid_arguments');
      });
      await expectLater(
        invoke(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'invalid_arguments',
          ),
        ),
      );
    });
  }
}
