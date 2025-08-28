import 'dart:async';

typedef Getter = T Function<T>();

/// Minimal type-based registry to share dependencies in tests.
///
/// Create one per scenario and register fakes or mocks with [register].
/// Use [unregister] or [clear] to avoid leaking state between scenarios.
class TestRegistry {
  final List<Map<Type, Object?>> _stack = [{}];

  Map<Type, Object?> get _current => _stack.last;

  /// Register an [instance] for type [T].
  ///
  /// Throws a [StateError] if the type is already registered in the current
  /// scope unless [override] is set to `true`.
  void register<T>(T instance, {bool override = false}) {
    if (!override && _current.containsKey(T)) {
      throw StateError('Type $T is already registered in this scope');
    }
    _current[T] = instance as Object?;
  }

  /// Register a lazy [builder] for type [T].
  ///
  /// The builder is executed the first time the dependency is requested via
  /// [callAsync] and its result cached for subsequent lookups. A [StateError]
  /// is thrown if the type is already registered unless [override] is `true`.
  void registerLazy<T>(
    FutureOr<T> Function() builder, {
    bool override = false,
  }) {
    if (!override && _current.containsKey(T)) {
      throw StateError('Type $T is already registered in this scope');
    }
    _current[T] = _LazyEntry<T>(builder);
  }

  /// Remove the registration for type [T] from the current scope.
  ///
  /// Useful when overriding dependencies or isolating scenarios.
  void unregister<T>() {
    _current.remove(T);
  }

  /// Retrieve the instance registered for type [T].
  ///
  /// Throws a [StateError] if nothing was registered for `T`.
  T call<T>() {
    for (var i = _stack.length - 1; i >= 0; i--) {
      final scope = _stack[i];
      if (!scope.containsKey(T)) continue;
      final value = scope[T];
      if (value is _LazyEntry<T>) {
        final resolved = value.instance;
        if (resolved != null) {
          return resolved;
        }
        throw StateError(
          'Async dependency for type $T has not been resolved. Use callAsync.',
        );
      }
      return value as T;
    }
    throw StateError('No instance registered for type $T');
  }

  /// Retrieve an async dependency registered via [registerLazy].
  ///
  /// If the dependency was registered directly with [register], the value is
  /// returned wrapped in a [Future].
  Future<T> callAsync<T>() async {
    for (var i = _stack.length - 1; i >= 0; i--) {
      final scope = _stack[i];
      if (!scope.containsKey(T)) continue;
      final value = scope[T];
      if (value is _LazyEntry<T>) {
        return value.get();
      }
      return value as T;
    }
    throw StateError('No instance registered for type $T');
  }

  /// Remove all registrations from the current scope.
  ///
  /// Call between scenarios to ensure isolation.
  void clear() => _current.clear();

  /// Start a new nested scope.
  void pushScope() => _stack.add({});

  /// Dispose the current scope, returning to the previous one.
  void popScope() {
    if (_stack.length == 1) {
      throw StateError('Cannot pop root scope');
    }
    _stack.removeLast();
  }
}

class _LazyEntry<T> {
  _LazyEntry(this._builder);

  final FutureOr<T> Function() _builder;

  T? _value;
  Future<T>? _future;

  Future<T> get() {
    if (_value != null) return Future.value(_value as T);
    final result = _builder();
    if (result is Future<T>) {
      return _future ??= result
          .then((v) => _value = v)
          .then((_) => _value as T);
    } else {
      _value = result;
      return Future.value(result);
    }
  }

  T? get instance => _value;
}
