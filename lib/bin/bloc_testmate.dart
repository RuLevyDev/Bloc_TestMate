import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) {
  final generateParser = ArgParser()
    ..addOption('path', defaultsTo: 'lib/', help: 'Root directory to analyze.');

  final parser = ArgParser()..addCommand('generate', generateParser);

  late ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('Usage: bloc_testmate generate [--path <path>]');
    return;
  }

  if (argResults.command?.name == 'generate') {
    final path = argResults.command!['path'] as String;
    // Generation logic will be implemented here.
    stdout.writeln('Generating for $path');
  } else {
    stdout.writeln('Usage: bloc_testmate generate [--path <path>]');
  }
}
