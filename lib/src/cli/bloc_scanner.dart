import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:path/path.dart' as p;
import 'package:bloc_testmate/src/cli/glob_utils.dart';

/// Holds basic information about a discovered Bloc class.
class BlocInfo {
  BlocInfo({required this.name, required this.path});

  /// Class name of the bloc.
  final String name;

  /// Absolute path to the file where the bloc is defined.
  final String path;
}

/// Scans [rootDir] recursively for Dart files and returns the classes that
/// extend `Bloc<_, _>`. [include] and [exclude] are glob patterns applied to
/// paths relative to [rootDir].
List<BlocInfo> scan(
  String rootDir, {
  List<String> include = const ['**/*.dart'],
  List<String> exclude = const [],
}) {
  final root = Directory(rootDir);
  if (!root.existsSync()) {
    return const [];
  }

  // Build Globs with a POSIX context for consistent cross-platform behavior.
  final includeGlobs = include.map(GlobUtils.glob).toList();
  final excludeGlobs = exclude.map(GlobUtils.glob).toList();

  final results = <BlocInfo>[];
  final files = root.listSync(recursive: true).whereType<File>().where((f) {
    if (!f.path.endsWith('.dart')) return false;
    final relative = p.relative(f.path, from: rootDir);
    final isIncluded =
        includeGlobs.isEmpty || GlobUtils.matchesAny(includeGlobs, relative);
    final isExcluded = GlobUtils.matchesAny(excludeGlobs, relative);
    return isIncluded && !isExcluded;
  });

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
