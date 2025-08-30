/// Scenario-oriented testing utilities for BLoC.
///
/// This library exposes the main `BlocTestMate` API along with helpers for
/// golden-state testing, simple data tables, a tiny test-time registry and
/// commonly used matchers. See the README for usage examples.
library;

export 'src/bloc_test_mate.dart';
export 'src/registry.dart';
export 'src/table.dart';
export 'src/golden_logger.dart';
export 'src/matchers.dart'
    show isA, predicate, emitsInOrderStates, emitsWhere, noMoreStates;
