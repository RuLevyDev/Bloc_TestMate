import 'dart:io';

import 'package:yaml/yaml.dart';

/// Configuration for the CLI.
class CliConfig {
  CliConfig({
    required this.include,
    required this.exclude,
    required this.output,
  });

  /// Glob patterns for files to include.
  final List<String> include;

  /// Glob patterns for files to exclude.
  final List<String> exclude;

  /// Directory where generated tests should be placed.
  final String output;

  /// Loads configuration from a YAML [filePath].
  factory CliConfig.fromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return CliConfig(include: const [], exclude: const [], output: 'test');
    }
    final raw = loadYaml(file.readAsStringSync());
    if (raw is YamlMap) {
      final include = raw['include'] is YamlList
          ? List<String>.from(raw['include'] as YamlList)
          : <String>[];
      final exclude = raw['exclude'] is YamlList
          ? List<String>.from(raw['exclude'] as YamlList)
          : <String>[];
      final output = raw['output'] as String? ?? 'test';
      return CliConfig(include: include, exclude: exclude, output: output);
    }
    return CliConfig(include: const [], exclude: const [], output: 'test');
  }
}
