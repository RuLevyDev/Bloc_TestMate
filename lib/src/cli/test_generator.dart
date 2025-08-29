import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'bloc_scanner.dart';

/// Generates a basic test file for the given [bloc] using [BlocTestMate].
///
/// The generated file will be placed under `test/` with placeholders for
/// events and states. Two scenarios are included: one for a successful
/// outcome and another that expects an error.
Future<void> generate(BlocInfo bloc, {String testDirectory = 'test'}) async {
  final snake = _toSnakeCase(bloc.name);
  final testFile = File('${_normalize(testDirectory)}/${snake}_test.dart');
  await testFile.create(recursive: true);

  final importPath = _relativePath(bloc.path, testFile.parent.path);
  final stateType = _stateType(bloc);

  final content =
      '''import 'package:bloc_testmate/bloc_testmate.dart';
import '$importPath';

void main() {
  final mate = BlocTestMate<${bloc.name}, $stateType>()
      .factory((get) => ${bloc.name}(/* TODO: dependencies */));

  mate.scenario(
    'success scenario',
    when: (bloc) => bloc.add(/* TODO: success event */),
    expectStates: [
      /* TODO: expected success states */
    ],
  );

  mate.scenario(
    'error scenario',
    when: (bloc) => bloc.add(/* TODO: error event */),
    errors: [
      /* TODO: expected error */
    ],
  );
}
''';

  await testFile.writeAsString(content);
}

String _stateType(BlocInfo bloc) {
  final parsed = parseFile(
    path: bloc.path,
    featureSet: FeatureSet.latestLanguageVersion(),
  );
  final unit = parsed.unit;
  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration &&
        declaration.name.lexeme == bloc.name) {
      final extendsClause = declaration.extendsClause;
      if (extendsClause == null) {
        break;
      }
      final NamedType superclass = extendsClause.superclass;
      final args = superclass.typeArguments?.arguments;
      if (args != null && args.length == 2) {
        return args[1].toSource();
      }
    }
  }
  return 'dynamic';
}

String _toSnakeCase(String input) {
  final regex = RegExp('(?<=[a-z0-9])[A-Z]');
  return input
      .replaceAllMapped(regex, (m) => '_${m.group(0)!.toLowerCase()}')
      .toLowerCase();
}

String _relativePath(String targetPath, String fromDir) {
  List<String> segments(Uri uri) =>
      uri.pathSegments.where((s) => s.isNotEmpty).toList();

  final fromSegments = segments(Directory(fromDir).absolute.uri);
  final targetSegments = segments(File(targetPath).absolute.uri);

  var i = 0;
  while (i < fromSegments.length &&
      i < targetSegments.length &&
      fromSegments[i] == targetSegments[i]) {
    i++;
  }

  final up = List<String>.filled(fromSegments.length - i, '..');
  final down = targetSegments.sublist(i).join('/');
  return [...up, down].join('/');
}

String _normalize(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;
