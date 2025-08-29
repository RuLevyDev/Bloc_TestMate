import 'package:test/test.dart';
/// Matcher utilities for bloc state streams.

export 'package:test/test.dart' show isA, predicate;

/// Matches a stream of states that emits each item from [expected] in order.
///
/// [expected] should contain concrete state instances or [Matcher] objects
/// from `package:test`. To ensure the stream completes, include
/// [noMoreStates] as the last matcher.
///  The matcher fails if the stream emits a different sequence.
StreamMatcher emitsInOrderStates(List<dynamic> expected) =>
    emitsInOrder(expected);

/// Matches the next state emitted by a stream that satisfies [test].
///
/// The [test] function receives the emitted state and should return `true`
/// when it matches the desired condition.
///  The matcher completes once a matching state is emitted and fails otherwise.
StreamMatcher emitsWhere(bool Function(dynamic) test) => emits(predicate(test));

/// Matches a stream which emits no further states and then closes.
///
/// Use to assert that a stream has finished emitting states:
/// The matcher fails if additional states are emitted or the stream never
/// completes.
StreamMatcher noMoreStates() => emitsDone;
