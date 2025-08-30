import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

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

  // Use POSIX-style patterns to ensure cross-platform matching (esp. on Windows)
  final posixContext = p.Context(style: p.Style.posix);
  final includeGlobs = include.map((pat) => Glob(pat, context: posixContext)).toList();
  final excludeGlobs = exclude.map((pat) => Glob(pat, context: posixContext)).toList();

  final results = <BlocInfo>[];
  final files = root.listSync(recursive: true).whereType<File>().where((f) {
    if (!f.path.endsWith('.dart')) return false;
    final relative = p.relative(f.path, from: rootDir);
    // Normalize to POSIX separators for glob matching
    final relPosix = relative.split(Platform.pathSeparator).join('/');
    final isIncluded = includeGlobs.isEmpty ||
        includeGlobs.any((g) => g.matches(relPosix));
    final isExcluded = excludeGlobs.any((g) => g.matches(relPosix));
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
