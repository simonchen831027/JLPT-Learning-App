import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_sdk.dart' as sdk;

void main() {
  test('parses machine JSON after Flutter bootstrap output', () {
    const output = '''
Resolving dependencies...
{
  "frameworkVersion": "3.47.5",
  "dartSdkVersion": "3.13.4"
}
''';

    final version = sdk.parseFlutterVersion(output);
    expect(version['frameworkVersion'], '3.47.5');
    expect(version['dartSdkVersion'], '3.13.4');
  });

  test('ignores output after machine JSON', () {
    const output = '''
Resolving dependencies...
{"frameworkVersion":"3.47.5","dartSdkVersion":"3.13.4"}
Some trailing output
''';

    final version = sdk.parseFlutterVersion(output);
    expect(version['frameworkVersion'], '3.47.5');
    expect(version['dartSdkVersion'], '3.13.4');
  });

  test('fails when machine JSON is missing', () {
    expect(
      () => sdk.parseFlutterVersion('Resolving dependencies...'),
      throwsFormatException,
    );
  });

  test('fails when machine JSON is malformed', () {
    expect(
      () => sdk.parseFlutterVersion('Resolving dependencies...\n{invalid}'),
      throwsFormatException,
    );
  });

  test('fails when machine JSON is not an object', () {
    expect(
      () => sdk.parseFlutterVersion('Resolving dependencies...\n[]'),
      throwsFormatException,
    );
  });
}
