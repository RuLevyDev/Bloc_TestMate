import 'dart:async';

import 'package:bloc_testmate/bloc_testmate.dart';
import 'package:test/test.dart';

void main() {
  group('emitsInOrderStates', () {
    test('matches correct sequence', () async {
      final stream = Stream.fromIterable([1, 2]);
      await expectLater(stream, emitsInOrderStates([1, 2, noMoreStates()]));
    });

    test('fails for wrong sequence', () async {
      final stream = Stream.fromIterable([1, 2]);
      await expectLater(
        expectLater(stream, emitsInOrderStates([1, 3, noMoreStates()])),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('emitsWhere', () {
    test('matches predicate', () async {
      final stream = Stream.value(42);
      await expectLater(stream, emitsWhere((s) => s == 42));
    });

    test('fails for unmatched predicate', () async {
      final stream = Stream.value(42);
      await expectLater(
        expectLater(stream, emitsWhere((s) => s == 0)),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('noMoreStates', () {
    test('matches empty stream', () async {
      final stream = Stream<int>.empty();
      await expectLater(stream, noMoreStates());
    });

    test('fails when additional states emitted', () async {
      final stream = Stream.fromIterable([1]);
      await expectLater(
        expectLater(stream, noMoreStates()),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
