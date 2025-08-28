import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

/// Records serialized states emitted by a [BlocBase] for golden comparison.
class GoldenLogger<S> {
  /// Subscribes to [bloc] and stores the initial and subsequent states.
  ///
  /// The subscription listens to `bloc.stream` so every state change is
  /// captured and serialized for later comparison.
  GoldenLogger(BlocBase<S> bloc) {
    _states.add(_serialize(bloc.state));
    _subscription = bloc.stream.listen((s) {
      _states.add(_serialize(s));
    });
  }

  final List<dynamic> _states = [];
  late final StreamSubscription<S> _subscription;

  dynamic _serialize(Object? state) {
    try {
      return jsonDecode(jsonEncode(state));
    } catch (_) {
      return state.runtimeType.toString();
    }
  }

  /// Compares recorded states against the JSON [path] golden file.
  ///
  /// The golden file must contain a JSON array where each element is the
  /// serialized representation of a state in the order it was emitted. This
  /// should match the result of `_serialize` for each state, for example:
  ///
  /// ```json
  /// [
  ///   {"status": "initial"},
  ///   {"status": "loaded", "data": 42}
  /// ]
  /// ```
  ///
  /// This method cancels the internal subscription once comparison is
  /// complete.
  void expectMatch(String path) {
    final encoder = const JsonEncoder.withIndent('  ');
    final actual = encoder.convert(_states);
    final file = File(path);
    if (!file.existsSync()) {
      fail('Missing golden file: $path');
    }
    final expected = encoder.convert(jsonDecode(file.readAsStringSync()));
    try {
      expect(actual, expected);
    } finally {
      unawaited(_subscription.cancel());
    }
  }

  /// Cancels the internal subscription.
  ///
  /// `expectMatch` cancels the subscription automatically. Call this only if
  /// the logger is created but `expectMatch` is never invoked.
  Future<void> dispose() => _subscription.cancel();
}
