typedef Getter = T Function<T>();

/// Minimal type-based registry to share dependencies in tests.
///
/// Create one per scenario and register fakes or mocks with [register].
/// Use [unregister] or [clear] to avoid leaking state between scenarios.
class TestRegistry {
  final _map = <Type, Object?>{};

  /// Register an [instance] for type [T].
  void register<T>(T instance) {
    _map[T] = instance as Object?;
  }

  /// Remove the registration for type [T].
  ///
  /// Useful when overriding dependencies or isolating scenarios.
  void unregister<T>() {
    _map.remove(T);
  }

  /// Retrieve the instance registered for type [T].
  ///
  /// Throws a [StateError] if nothing was registered for `T`.
  T call<T>() {
    final value = _map[T];
    if (value == null) {
      throw StateError('No instance registered for type $T');
    }
    return value as T;
  }

  /// Remove all registrations.
  ///
  /// Call between scenarios to ensure isolation.
  void clear() => _map.clear();
}
