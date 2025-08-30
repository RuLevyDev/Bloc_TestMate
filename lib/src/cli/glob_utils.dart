import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Utilities to perform cross-platform glob matching against relative paths.
class GlobUtils {
  GlobUtils._();

  /// Use POSIX-style context so patterns like `**/*.dart` behave consistently
  /// across platforms.
  static final p.Context posix = p.Context(style: p.Style.posix);

  /// Build a [Glob] using the POSIX context for consistent behavior.
  static Glob glob(String pattern) => Glob(pattern, context: posix);

  /// Normalize a relative path to POSIX separators.
  static String toPosix(String relativePath) =>
      relativePath.split(Platform.pathSeparator).join('/');

  /// Generate candidate paths to improve intuitive matching for root-level files.
  ///
  /// Some glob patterns like `**/*.dart` or `**/name.dart` typically match
  /// files in subdirectories but not root-level files (with no '/').
  /// This returns the original [relPosix] and, when there is no directory
  /// component, also returns a dummy `x/<file>` path so `**/` matches.
  static Iterable<String> candidates(String relPosix) sync* {
    yield relPosix;
    if (!relPosix.contains('/')) {
      yield 'x/$relPosix';
    }
  }

  /// Returns true if any [globs] match the given relative path (in platform
  /// separators). Internally normalizes and tries extra candidates as needed.
  static bool matchesAny(Iterable<Glob> globs, String relativePath) {
    final relPosix = toPosix(relativePath);
    for (final g in globs) {
      for (final c in candidates(relPosix)) {
        if (g.matches(c)) return true;
      }
    }
    return false;
  }
}
