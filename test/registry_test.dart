import 'package:bloc_testmate/bloc_testmate.dart';
import 'package:test/test.dart';

void main() {
  test('unregister removes type', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    reg.unregister<int>();
    expect(() => reg<int>(), throwsStateError);
  });

  test('clear removes all', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    reg.register<String>('hi');
    reg.clear();
    expect(() => reg<int>(), throwsStateError);
    expect(() => reg<String>(), throwsStateError);
  });

  test('duplicate registration throws unless override', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    expect(() => reg.register<int>(2), throwsStateError);
    reg.register<int>(2, override: true);
    expect(reg<int>(), 2);
  });

  test('scopes nest correctly', () {
    final reg = TestRegistry();
    reg.register<int>(1);
    reg.pushScope();
    reg.register<int>(2);
    expect(reg<int>(), 2);
    reg.popScope();
    expect(reg<int>(), 1);
  });

  test('lazy async dependencies resolve once', () async {
    final reg = TestRegistry();
    var count = 0;
    reg.registerLazy<int>(() async {
      count++;
      return 42;
    });
    expect(() => reg<int>(), throwsStateError);
    final v1 = await reg.callAsync<int>();
    final v2 = await reg.callAsync<int>();
    expect(v1, 42);
    expect(v2, 42);
    expect(count, 1);
    expect(reg<int>(), 42);
  });
}
