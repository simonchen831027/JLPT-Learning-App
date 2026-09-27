import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final expectedFlutter = File('../.flutter-version').readAsStringSync().trim();
  final result = await Process.run('flutter', [
    '--version',
    '--machine',
  ], runInShell: Platform.isWindows);
  if (result.exitCode != 0) {
    stderr.writeln('無法讀取 Flutter SDK 版本。');
    exitCode = 1;
    return;
  }
  Map<String, dynamic> version;
  try {
    version = parseFlutterVersion(result.stdout as String);
  } on FormatException {
    stderr.writeln('Flutter --version --machine 未輸出有效 JSON。');
    exitCode = 1;
    return;
  }
  if (version['frameworkVersion'] != expectedFlutter ||
      version['dartSdkVersion'] != '3.13.4') {
    stderr.writeln('需要 Flutter $expectedFlutter / Dart 3.13.4。請先核對 SDK。');
    exitCode = 1;
    return;
  }
  stdout.writeln('SDK 版本符合：Flutter $expectedFlutter / Dart 3.13.4。');
}

Map<String, dynamic> parseFlutterVersion(String output) {
  final jsonStart = RegExp(
    r'^[ \t]*[\{\[]',
    multiLine: true,
  ).firstMatch(output);
  if (jsonStart == null) {
    throw const FormatException('找不到 Flutter SDK 版本 JSON。');
  }

  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var index = jsonStart.start; index < output.length; index++) {
    final character = output.codeUnitAt(index);
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (character == 92) {
        escaped = true;
      } else if (character == 34) {
        inString = false;
      }
    } else if (character == 34) {
      inString = true;
    } else if (character == 123 || character == 91) {
      depth++;
    } else if (character == 125 || character == 93) {
      depth--;
      if (depth == 0) {
        final decoded = jsonDecode(
          output.substring(jsonStart.start, index + 1),
        );
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Flutter SDK 版本 JSON 格式錯誤。');
        }
        return decoded;
      }
    }
  }
  throw const FormatException('Flutter SDK 版本 JSON 格式錯誤。');
}
