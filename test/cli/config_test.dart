import 'dart:io';

import 'package:bloc_testmate/src/cli/config.dart';
import 'package:test/test.dart';

void main() {
  test('loads configuration from yaml file', () async {
    final tempDir = await Directory.systemTemp.createTemp();
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final configFile = File('${tempDir.path}/bloc_testmate.yaml');
    await configFile.writeAsString('''
include:
  - lib/**
exclude:
  - lib/generated/**
output: custom_test
''');

    final config = CliConfig.fromFile(configFile.path);
    expect(config.include, ['lib/**']);
    expect(config.exclude, ['lib/generated/**']);
    expect(config.output, 'custom_test');
  });
}
