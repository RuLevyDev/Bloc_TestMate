import 'dart:io';

import 'package:args/args.dart';
import 'package:bloc_testmate/src/cli/bloc_scanner.dart';
import 'package:bloc_testmate/src/cli/config.dart';
import 'package:bloc_testmate/src/cli/test_generator.dart';

Future<void> main(List<String> arguments) async {
  final testmateParser = ArgParser()
    ..addOption(
      'config',
      defaultsTo: 'bloc_testmate.yaml',
      help: 'Path to the configuration file.',
    );

  final parser = ArgParser()..addCommand('testmate', testmateParser);

  late ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('Usage: generate testmate [--config <path>]');
    return;
  }

  if (argResults.command?.name == 'testmate') {
    final configPath = argResults.command!['config'] as String;
    final config = CliConfig.fromFile(configPath);

    final blocs = scan(
      Directory.current.path,
      include: config.include,
      exclude: config.exclude,
    );

    for (final bloc in blocs) {
      await generate(bloc, testDirectory: config.output);
    }
  } else {
    stdout.writeln('Usage: generate testmate [--config <path>]');
  }
}
