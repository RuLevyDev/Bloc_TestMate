import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Holds basic information about a discovered Bloc class.
class BlocInfo {
  BlocInfo({required this.name, required this.path});

  /// Class name of the bloc.
  final String name;

  /// Absolute path to the file where the bloc is defined.
  final String path;
}

/// Scans [rootDir] recursively for Dart files and returns the classes that
/// extend `Bloc<_, _>`.
List<BlocInfo> scan(String rootDir) {
  final root = Directory(rootDir);
  if (!root.existsSync()) {
    return const [];
  }

  final results = <BlocInfo>[];
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    final parsed = parseFile(
      path: file.path,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    final unit = parsed.unit;
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final extendsClause = declaration.extendsClause;
        if (extendsClause == null) {
          continue;
        }
        final NamedType superclass = extendsClause.superclass;
        if (superclass.name.lexeme == 'Bloc') {
          results.add(BlocInfo(name: declaration.name.lexeme, path: file.path));
        }
      }
    }
  }

  return results;
}
