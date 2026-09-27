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
  final version = jsonDecode(result.stdout as String) as Map<String, dynamic>;
  if (version['frameworkVersion'] != expectedFlutter ||
      version['dartSdkVersion'] != '3.13.4') {
    stderr.writeln('需要 Flutter $expectedFlutter / Dart 3.13.4。請先核對 SDK。');
    exitCode = 1;
    return;
  }
  stdout.writeln('SDK 版本符合：Flutter $expectedFlutter / Dart 3.13.4。');
}
