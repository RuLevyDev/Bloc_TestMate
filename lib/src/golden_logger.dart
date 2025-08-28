import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

class GoldenLogger<S> {
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
}
