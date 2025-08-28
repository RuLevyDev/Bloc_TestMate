import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:bloc_testmate/src/registry.dart';
import 'package:bloc_testmate/src/golden_logger.dart';
import 'package:test/test.dart' as test;

typedef Arrange = void Function(TestRegistry get);
typedef Given = List<Object> Function();
typedef When<B> = FutureOr<void> Function(B bloc);
typedef Hook = FutureOr<void> Function();

/// Scenario-oriented test helper for BLoC.
///
/// Example:
/// ```dart
/// final mate = BlocTestMate<LoginBloc, LoginState>()
///   .arrange((get) => get.register<AuthRepo>(FakeAuthRepo()))
///   .factory((get) => LoginBloc(get<AuthRepo>()));
/// ```

class BlocTestMate<B extends Bloc<Object?, S>, S> {
  Arrange? _arrange;
  B Function(TestRegistry get)? _factory;
  Hook? _setUp;
  Hook? _tearDown;

  BlocTestMate<B, S> arrange(Arrange a) {
    _arrange = a;
    return this;
  }

  BlocTestMate<B, S> factory(B Function(TestRegistry get) f) {
    _factory = f;
    return this;
  }

  BlocTestMate<B, S> setUp(Hook h) {
    _setUp = h;
    return this;
  }

  BlocTestMate<B, S> tearDown(Hook h) {
    _tearDown = h;
    return this;
  }

  /// Defines a test scenario in 1–2 lines.
  ///
  /// - [arrange]: override or add fakes for this case.
  /// - [given]: pre-events added before `when`.
  /// - [when]: action to execute on the bloc.
  /// - [expectStates]: list of expected states or matchers (`bloc_test`).
  /// - [expectInitialState]: matcher to verify the initial state.
  /// - [errors]: list of expected errors (`bloc_test`).
  /// - [setUp]: optional hook before each scenario.
  /// - [tearDown]: optional hook after each scenario.
  /// - [wait]: optional delay before assertions.
  /// - [golden]: optional JSON file under `test/goldens/` used for
  ///   golden-state comparison.
  void scenario(
    String description, {
    Arrange? arrange,
    Given? given,
    When<B>? when,
    List<dynamic>? expectStates,
    dynamic expectInitialState,
    Iterable<dynamic>? errors,
    Hook? setUp,
    Hook? tearDown,
    FutureOr<void> Function(B bloc)? verify,
    Duration? wait,
    String? golden,
  }) {
    final a = _arrange;
    final f = _factory;
    if (f == null) {
      throw StateError('You must call factory() before adding scenarios');
    }
    GoldenLogger<S>? logger;

    blocTest<B, S>(
      description,
      setUp: () async {
        await _setUp?.call();
        await setUp?.call();
      },
      build: () {
        final reg = TestRegistry();
        a?.call(reg);
        arrange?.call(reg);
        return f(reg);
      },
      act: (bloc) async {
        if (golden != null) {
          logger = GoldenLogger<S>(bloc);
        }
        if (expectInitialState != null) {
          test.expect(bloc.state, expectInitialState);
        }
        final events = given?.call() ?? const [];
        for (final e in events) {
          bloc.add(e);
        }
        if (when != null) {
          await when(bloc);
        }
      },
      wait: wait,
      expect: expectStates == null ? null : () => expectStates,
      errors: errors == null ? null : () => errors,
      verify: (bloc) async {
        await verify?.call(bloc);
        if (golden != null) {
          logger!.expectMatch('test/goldens/$golden');
        }
      },
      tearDown: () async {
        await _tearDown?.call();
        await tearDown?.call();
      },
    );
  }

  /// Groups scenarios under a `group()` from package:test.
  void group(String name, void Function() body) {
    test.group(name, body);
  }
}
