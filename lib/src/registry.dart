typedef Getter = T Function<T>();

class TestRegistry {
  final _map = <Type, Object?>{};

  void register<T>(T instance) {
    _map[T] = instance as Object?;
  }

  T call<T>() {
    final value = _map[T];
    if (value == null) {
      throw StateError('No instance registered for type $T');
    }
    return value as T;
  }
}
