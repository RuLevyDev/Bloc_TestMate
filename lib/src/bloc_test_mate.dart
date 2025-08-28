import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:bloc_testmate/src/registry.dart';
import 'package:test/test.dart';

typedef Arrange = void Function(TestRegistry get);
typedef Given = List<Object> Function();
typedef When<B> = FutureOr<void> Function(B bloc);
typedef Hook = FutureOr<void> Function();

/// Test helper orientado a escenarios para BLoC.
///
/// Ejemplo:
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

  /// Define un escenario de test en 1-2 líneas.
  ///
  /// - [arrange]: sobrescribe/añade fakes para este caso.
  /// - [given]: eventos previos (se añaden antes del `when`).
  /// - [when]: acción a ejecutar sobre el bloc.
  /// - [expectStates]: lista de estados o matchers esperados (bloc_test).
  /// - [expectInitialState]: matcher para verificar el estado inicial.
  /// - [errors]: lista de errores esperados (bloc_test).
  /// - [setUp]: hook opcional antes de cada escenario.
  /// - [tearDown]: hook opcional después de cada escenario.
  /// - [wait]: delay opcional antes de aserciones.
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
    void Function(B bloc)? verify,
    Duration? wait,
  }) {
    final a = _arrange;
    final f = _factory;
    if (f == null) {
      throw StateError('You must call factory() before adding scenarios');
    }

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
        if (expectInitialState != null) {
          expect(bloc.state, expectInitialState);
        }
        final events = given?.call() ?? const [];
        for (final e in events) {
          // Estos warnings aparecen porque llamamos a add() desde test helpers.
          // Los silenciamos a nivel de analyzer.
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          bloc.add(e);
        }
        if (when != null) {
          await when(bloc);
        }
      },
      wait: wait,
      expect: () => expectStates ?? const [],
      errors: errors == null ? null : () => errors,
      verify: verify,
      tearDown: () async {
        await _tearDown?.call();
        await tearDown?.call();
      },
    );
  }

  /// Agrupa escenarios bajo un `group()` de package:test
  void group(String name, void Function() body) {
    group(name, body);
  }
}
