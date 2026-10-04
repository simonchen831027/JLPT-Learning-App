import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/audio/learning_audio_service.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/domain/learning_audio_use_cases.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';

void main() {
  testWidgets('Furigana OFF and ON retain the same canonical pronunciation', (
    tester,
  ) async {
    final reading = _reading([('今日', 'きょう'), ('です。', null)]);
    final service = _AudioService();
    final play = PlayLearningAudio(service);

    for (final showReadings in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingLine(reading, showReadings: showReadings),
          ),
        ),
      );
      expect(find.text('きょう'), showReadings ? findsOneWidget : findsNothing);
      expect(await play(reading), LearningAudioResult.accepted);
    }

    expect(service.requests.map((request) => request.text), [
      'きょうです。',
      'きょうです。',
    ]);
    expect(reading.segments.first.reading, 'きょう');
  });

  group('canonical pronunciation', () {
    final cases = <(String, List<(String, String?)>, String)>[
      ('single Kanji', [('日', 'ひ')], 'ひ'),
      ('multi-Kanji word', [('日本語', 'にほんご')], 'にほんご'),
      ('contextual 今日', [('今日', 'きょう')], 'きょう'),
      ('different canonical context', [('今日', 'こんにち')], 'こんにち'),
      ('Kanji and okurigana', [('食', 'た'), ('べる', null)], 'たべる'),
      ('surface without reading', [('こんにちは。', null)], 'こんにちは。'),
      (
        'Kana punctuation and whitespace without reading',
        [('こんにちは', null), (' カタカナ', null), ('、。！？\t\n', null)],
        'こんにちは カタカナ、。！？\t\n',
      ),
      (
        'ordered sentence including punctuation and newline',
        [
          ('今日', 'きょう'),
          ('、', null),
          ('日本語', 'にほんご'),
          ('を', null),
          ('勉強', 'べんきょう'),
          ('します。\n', null),
          ('またね。', null),
        ],
        'きょう、にほんごをべんきょうします。\nまたね。',
      ),
    ];
    for (final (name, parts, expected) in cases) {
      test(name, () async {
        final service = _AudioService();
        final result = await PlayLearningAudio(service)(_reading(parts));

        expect(result, LearningAudioResult.accepted);
        expect(service.capabilityCalls, 1);
        expect(service.requests, hasLength(1));
        expect(service.requests.single.text, expected);
        expect(service.requests.single.languageTag, 'ja-JP');
      });
    }

    test(
      'repeated playback preserves canonical reading and segment order',
      () async {
        final reading = _reading([('今日', 'きょう'), ('です。', null)]);
        final originalSegments = reading.segments.toList();
        final service = _AudioService();
        final play = PlayLearningAudio(service);

        await play(reading);
        await play(reading);

        expect(service.requests.map((request) => request.text), [
          'きょうです。',
          'きょうです。',
        ]);
        expect(reading.surface, '今日です。');
        expect(reading.segments, orderedEquals(originalSegments));
        reading.validate();
      },
    );

    final invalidReadings = <String, ReadingText>{
      'empty aggregate': ReadingText(id: 'empty', surface: '', segments: []),
      'surface mismatch': ReadingText(
        id: 'mismatch',
        surface: '今日',
        segments: const [
          ReadingSegment(id: 's', ordinal: 0, surface: '日本語', reading: 'にほんご'),
        ],
      ),
      'unordered segments': ReadingText(
        id: 'unordered',
        surface: '今日です。',
        segments: const [
          ReadingSegment(id: 's1', ordinal: 1, surface: '今日', reading: 'きょう'),
          ReadingSegment(id: 's2', ordinal: 0, surface: 'です。'),
        ],
      ),
      'empty stored reading': ReadingText(
        id: 'empty-reading',
        surface: '今日',
        segments: const [
          ReadingSegment(id: 's', ordinal: 0, surface: '今日', reading: ''),
        ],
      ),
    };
    for (final entry in invalidReadings.entries) {
      test('${entry.key} rejected before service access', () async {
        final service = _AudioService();

        await expectLater(
          PlayLearningAudio(service)(entry.value),
          throwsArgumentError,
        );

        expect(service.capabilityCalls, 0);
        expect(service.requests, isEmpty);
      });
    }

    final missingHanReadings = <String, List<(String, String?)>>{
      'Kanji segment': [('今日', null)],
      'mixed Kana and Kanji segment': [('きょうは日本語です。', null)],
      'missing reading between valid segments': [
        ('今日', 'きょう'),
        ('は', null),
        ('日本語', null),
        ('です。', null),
      ],
      'Han Extension A': [(String.fromCharCode(0x3400), null)],
      'Han compatibility ideograph': [(String.fromCharCode(0xfa11), null)],
      'supplementary Han Extension B': [(String.fromCharCode(0x20000), null)],
      'supplementary Han Extension G': [(String.fromCharCode(0x30000), null)],
    };
    for (final entry in missingHanReadings.entries) {
      test(
        '${entry.key} without canonical reading never reaches service',
        () async {
          final reading = _reading(entry.value);
          final originalSegments = reading.segments.toList();
          final service = _AudioService();
          // 證明失敗來自 Audio guard，不是既有 ReadingText alignment 驗證。
          reading.validate();

          await expectLater(
            PlayLearningAudio(service)(reading),
            throwsArgumentError,
          );

          expect(service.capabilityCalls, 0);
          expect(service.requests, isEmpty);
          expect(reading.segments, orderedEquals(originalSegments));
        },
      );
    }
  });

  group('typed capability and playback outcomes', () {
    for (final capability in LearningAudioCapability.values) {
      test('capability query preserves $capability', () async {
        final service = _AudioService(capability: capability);

        expect(await GetLearningAudioCapability(service)(), capability);
        expect(service.capabilityCalls, 1);
        expect(service.requests, isEmpty);
      });
    }

    final blocked = <LearningAudioCapability, LearningAudioResult>{
      LearningAudioCapability.unavailable: LearningAudioResult.unavailable,
      LearningAudioCapability.disabled: LearningAudioResult.disabled,
      LearningAudioCapability.failed: LearningAudioResult.failed,
    };
    for (final entry in blocked.entries) {
      test('${entry.key} prevents playback without changing content', () async {
        final reading = _reading([('今日', 'きょう')]);
        final segment = reading.segments.single;
        final service = _AudioService(capability: entry.key);

        expect(await PlayLearningAudio(service)(reading), entry.value);
        expect(service.capabilityCalls, 1);
        expect(service.requests, isEmpty);
        expect(reading.surface, '今日');
        expect(reading.segments.single, same(segment));
        expect(segment.reading, 'きょう');
        reading.validate();
      });
    }

    for (final result in LearningAudioResult.values) {
      test(
        'play result $result is preserved after available capability',
        () async {
          final reading = _reading([('日本語', 'にほんご')]);
          final segment = reading.segments.single;
          final service = _AudioService(result: result);

          expect(await PlayLearningAudio(service)(reading), result);
          expect(service.capabilityCalls, 1);
          expect(service.requests, hasLength(1));
          expect(service.requests.single.text, 'にほんご');
          expect(reading.surface, '日本語');
          expect(reading.segments.single, same(segment));
          expect(segment.reading, 'にほんご');
          reading.validate();
        },
      );
    }

    test('unexpected capability programming error is not swallowed', () async {
      final error = StateError('test capability bug');
      final service = _AudioService(capabilityError: error);

      await expectLater(
        GetLearningAudioCapability(service)(),
        throwsA(same(error)),
      );
      await expectLater(
        PlayLearningAudio(service)(_reading([('今日', 'きょう')])),
        throwsA(same(error)),
      );
      expect(service.requests, isEmpty);
    });

    test('unexpected playback programming error is not swallowed', () async {
      final error = StateError('test playback bug');
      final service = _AudioService(playbackError: error);

      await expectLater(
        PlayLearningAudio(service)(_reading([('今日', 'きょう')])),
        throwsA(same(error)),
      );
      expect(service.requests, hasLength(1));
    });
  });
}

ReadingText _reading(List<(String, String?)> parts) => ReadingText(
  id: 'reading',
  surface: parts.map((part) => part.$1).join(),
  segments: [
    for (var index = 0; index < parts.length; index++)
      ReadingSegment(
        id: 'segment-$index',
        ordinal: index,
        surface: parts[index].$1,
        reading: parts[index].$2,
      ),
  ],
);

final class _AudioService implements LearningAudioService {
  _AudioService({
    this.capability = LearningAudioCapability.available,
    this.result = LearningAudioResult.accepted,
    this.capabilityError,
    this.playbackError,
  });

  final LearningAudioCapability capability;
  final LearningAudioResult result;
  final Error? capabilityError;
  final Error? playbackError;
  int capabilityCalls = 0;
  final requests = <LearningAudioRequest>[];

  @override
  Future<LearningAudioCapability> getCapability() async {
    capabilityCalls++;
    if (capabilityError case final error?) throw error;
    return capability;
  }

  @override
  Future<LearningAudioResult> play(LearningAudioRequest request) async {
    requests.add(request);
    if (playbackError case final error?) throw error;
    return result;
  }
}
