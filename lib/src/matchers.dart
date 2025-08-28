import 'package:test/test.dart';

export 'package:test/test.dart' show isA, predicate;

/// Matches a stream of states which emits [expected] in order.
///
/// Each entry in [expected] may be a concrete value or another matcher. The
/// matcher fails if the stream emits a different sequence.
StreamMatcher emitsInOrderStates(List<dynamic> expected) =>
    emitsInOrder(expected);

/// Matches the next state from a stream that satisfies [test].
StreamMatcher emitsWhere(bool Function(dynamic) test) => emits(predicate(test));

/// Matches a stream which emits no further states and completes.
StreamMatcher noMoreStates() => emitsDone;
